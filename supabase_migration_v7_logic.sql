-- Migration v7: Functions, Triggers, and Permissions for CameraStore DB
-- Run this script in your Supabase SQL Editor

SET search_path TO oltp_store;

-- =========================================================================
-- 1. UTILITY & BUSINESS FUNCTIONS
-- =========================================================================

-- A. Recalculate Booking Rent Fee
CREATE OR REPLACE FUNCTION oltp_store.recalculate_booking_fee(p_booking_id INTEGER)
RETURNS VOID AS $$
DECLARE
    v_start_date TIMESTAMP;
    v_end_date TIMESTAMP;
    v_rent_price NUMERIC;
    v_days INTEGER;
BEGIN
    SELECT start_date, end_date INTO v_start_date, v_end_date 
    FROM oltp_store.bookings WHERE id = p_booking_id;
    
    IF v_start_date IS NULL OR v_end_date IS NULL THEN
        RETURN;
    END IF;
    
    -- Find the daily rental price of the camera product
    SELECT p.rent_price_per_day INTO v_rent_price
    FROM oltp_store.booking_equipments be
    JOIN oltp_store.equipments e ON e.id = be.equipment_id
    JOIN oltp_store.products p ON p.id = e.product_id
    WHERE be.booking_id = p_booking_id
    LIMIT 1;
    
    IF v_rent_price IS NULL THEN
        RETURN;
    END IF;
    
    v_days := EXTRACT(DAY FROM (v_end_date::timestamp - v_start_date::timestamp))::integer + 1;
    IF v_days <= 0 THEN
        v_days := 1;
    END IF;
    
    UPDATE oltp_store.bookings
    SET total_rent_fee = v_days * v_rent_price
    WHERE id = p_booking_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- B. Calculate Cancellation Fee
CREATE OR REPLACE FUNCTION oltp_store.calculate_cancellation_fee_v2(p_booking_id INTEGER)
RETURNS JSONB AS $$
DECLARE
    v_start_date TIMESTAMP;
    v_deposit VARCHAR;
    v_deposit_numeric NUMERIC;
    v_days_diff INTEGER;
    v_fee NUMERIC;
    v_refund NUMERIC;
BEGIN
    SELECT start_date, deposit_fee INTO v_start_date, v_deposit
    FROM oltp_store.bookings WHERE id = p_booking_id;

    IF v_start_date IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Booking not found');
    END IF;

    -- Convert deposit to numeric safely
    BEGIN
        v_deposit_numeric := v_deposit::numeric;
    EXCEPTION WHEN OTHERS THEN
        v_deposit_numeric := 0;
    END;

    v_days_diff := EXTRACT(DAY FROM (v_start_date::date - CURRENT_DATE::date))::integer;

    IF v_days_diff >= 2 THEN
        -- Full refund
        v_fee := 0;
        v_refund := v_deposit_numeric;
    ELSIF v_days_diff >= 1 THEN
        -- 50% deposit penalty
        v_fee := v_deposit_numeric * 0.5;
        v_refund := v_deposit_numeric * 0.5;
    ELSE
        -- 100% deposit penalty (no refund)
        v_fee := v_deposit_numeric;
        v_refund := 0;
    END IF;

    RETURN json_build_object(
        'success', true,
        'days_before_start', v_days_diff,
        'deposit_amount', v_deposit_numeric,
        'cancellation_fee', v_fee,
        'refund_amount', v_refund
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- C. Settle Deposit on Checkout
CREATE OR REPLACE FUNCTION oltp_store.settle_deposit_on_checkout_v2(
    p_booking_id INTEGER,
    p_is_damaged BOOLEAN,
    p_damage_charge NUMERIC,
    p_notes TEXT
) RETURNS JSONB AS $$
DECLARE
    v_booking oltp_store.bookings%ROWTYPE;
    v_equipment_id INTEGER;
    v_overdue_days INTEGER;
    v_overdue_charge NUMERIC := 0;
    v_total_deduction NUMERIC := 0;
    v_refund_amount NUMERIC := 0;
    v_penalty_amount NUMERIC := 0;
    v_deposit_numeric NUMERIC := 0;
BEGIN
    SELECT * INTO v_booking FROM oltp_store.bookings WHERE id = p_booking_id;
    IF v_booking.id IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Booking not found');
    END IF;

    -- Get equipment ID for this booking
    SELECT equipment_id INTO v_equipment_id
    FROM oltp_store.booking_equipments
    WHERE booking_id = p_booking_id
    LIMIT 1;

    -- Convert deposit to numeric safely
    BEGIN
        v_deposit_numeric := v_booking.deposit_fee::numeric;
    EXCEPTION WHEN OTHERS THEN
        v_deposit_numeric := 0;
    END;

    -- Calculate overdue charge (1.5x daily rent fee per overdue day)
    IF CURRENT_DATE > v_booking.end_date::date THEN
        v_overdue_days := CURRENT_DATE - v_booking.end_date::date;
        v_overdue_charge := (v_booking.total_rent_fee / (v_booking.end_date::date - v_booking.start_date::date + 1)) * 1.5 * v_overdue_days;
    END IF;

    v_total_deduction := v_overdue_charge;
    IF p_is_damaged THEN
        v_total_deduction := v_total_deduction + p_damage_charge;
    END IF;

    -- If total deductions are less than deposit, refund the rest
    IF v_deposit_numeric >= v_total_deduction THEN
        v_refund_amount := v_deposit_numeric - v_total_deduction;
    ELSE
        -- Deduction exceeds deposit, user owes additional penalty/surcharge
        v_penalty_amount := v_total_deduction - v_deposit_numeric;
        v_refund_amount := 0;
    END IF;

    -- Perform checkout state update
    UPDATE oltp_store.bookings
    SET booking_status = 'CHECKED_OUT', checkout_date = now()
    WHERE id = p_booking_id;

    -- If damaged, set equipment status to DAMAGED
    IF p_is_damaged THEN
        UPDATE oltp_store.equipments SET status = 'DAMAGED' WHERE id = v_equipment_id;
    ELSE
        UPDATE oltp_store.equipments SET status = 'AVAILABLE' WHERE id = v_equipment_id;
    END IF;

    -- Create refund or penalty transactions
    IF v_refund_amount > 0 THEN
        INSERT INTO oltp_store.transactions (id, booking_id, user_id, type, amount, status, payment_method, notes)
        VALUES (gen_random_uuid(), p_booking_id, v_booking.customer_id, 'REFUND', v_refund_amount, 'COMPLETED', 'BANK_TRANSFER', 'Refund of security deposit after checkout deduction');
    END IF;

    IF v_overdue_charge > 0 THEN
        INSERT INTO oltp_store.transactions (id, booking_id, user_id, type, amount, status, payment_method, notes)
        VALUES (gen_random_uuid(), p_booking_id, v_booking.customer_id, 'PENALTY', v_overdue_charge, 'COMPLETED', 'BANK_TRANSFER', 'Overdue penalty charge');
    END IF;

    IF p_is_damaged AND p_damage_charge > 0 THEN
        INSERT INTO oltp_store.transactions (id, booking_id, user_id, type, amount, status, payment_method, notes)
        VALUES (gen_random_uuid(), p_booking_id, v_booking.customer_id, 'SURCHARGE', p_damage_charge, 'COMPLETED', 'BANK_TRANSFER', 'Damage surcharge fee');
    END IF;

    RETURN json_build_object(
        'success', true,
        'overdue_days', COALESCE(v_overdue_days, 0),
        'overdue_charge', v_overdue_charge,
        'damage_charge', CASE WHEN p_is_damaged THEN p_damage_charge ELSE 0 END,
        'total_deduction', v_total_deduction,
        'refund_amount', v_refund_amount,
        'penalty_owed', v_penalty_amount
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- =========================================================================
-- 2. BUSINESS TRIGGERS
-- =========================================================================

-- A. Bookings Validation Trigger
CREATE OR REPLACE FUNCTION oltp_store.fn_bookings_auto_calc_and_validate()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate dates
    IF NEW.end_date < NEW.start_date THEN
        RAISE EXCEPTION 'Ngày kết thúc không được nhỏ hơn ngày bắt đầu';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_bookings_auto_calc_and_validate ON oltp_store.bookings;
CREATE TRIGGER trg_bookings_auto_calc_and_validate
BEFORE INSERT OR UPDATE OF start_date, end_date ON oltp_store.bookings
FOR EACH ROW EXECUTE FUNCTION oltp_store.fn_bookings_auto_calc_and_validate();


-- B. Sync Equipment Status on Booking
CREATE OR REPLACE FUNCTION oltp_store.sync_equipment_status_on_booking()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.booking_status = 'CHECKED_IN' THEN
        UPDATE oltp_store.equipments
        SET status = 'RENTED'
        WHERE id IN (
            SELECT equipment_id 
            FROM oltp_store.booking_equipments 
            WHERE booking_id = NEW.id
        );
    ELSIF NEW.booking_status IN ('CHECKED_OUT', 'CANCELED', 'CANCELLED') THEN
        UPDATE oltp_store.equipments
        SET status = 'AVAILABLE'
        WHERE id IN (
            SELECT equipment_id 
            FROM oltp_store.booking_equipments 
            WHERE booking_id = NEW.id
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_sync_equipment_status_on_booking ON oltp_store.bookings;
CREATE TRIGGER trg_sync_equipment_status_on_booking
AFTER UPDATE OF booking_status ON oltp_store.bookings
FOR EACH ROW EXECUTE FUNCTION oltp_store.sync_equipment_status_on_booking();


-- C. Sale Orders Stock Sync Trigger
CREATE OR REPLACE FUNCTION oltp_store.fn_sale_orders_stock_sync()
RETURNS TRIGGER AS $$
DECLARE
    v_avail INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT available_stock INTO v_avail FROM oltp_store.sale_products WHERE id = NEW.product_id;
        IF v_avail < NEW.quantity THEN
            RAISE EXCEPTION 'Sản phẩm không đủ số lượng trong kho. Số lượng hiện tại: %', v_avail;
        END IF;

        UPDATE oltp_store.sale_products
        SET available_stock = available_stock - NEW.quantity,
            total_stock = total_stock - NEW.quantity
        WHERE id = NEW.product_id;

    ELSIF TG_OP = 'UPDATE' THEN
        -- If order status transitions to CANCELLED, restore the stock level
        IF OLD.status <> 'CANCELLED' AND NEW.status = 'CANCELLED' THEN
            UPDATE oltp_store.sale_products
            SET available_stock = available_stock + OLD.quantity,
                total_stock = total_stock + OLD.quantity
            WHERE id = OLD.product_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sale_orders_stock_sync ON oltp_store.sale_orders;
CREATE TRIGGER trg_sale_orders_stock_sync
BEFORE INSERT OR UPDATE OF status ON oltp_store.sale_orders
FOR EACH ROW EXECUTE FUNCTION oltp_store.fn_sale_orders_stock_sync();


-- =========================================================================
-- 3. PERMISSIONS & ROLE GRANTS
-- =========================================================================

-- Create Roles safely
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'nhanvienban') THEN
        CREATE ROLE nhanvienban;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'nhanvienthue') THEN
        CREATE ROLE nhanvienthue;
    END IF;
END
$$;

-- Revoke default public access to ensure security
REVOKE ALL ON SCHEMA oltp_store FROM public, nhanvienban, nhanvienthue;

-- Grant Schema Usages
GRANT USAGE ON SCHEMA oltp_store TO nhanvienban, nhanvienthue;

-- nhanvienban (Sales Staff) Grants
GRANT SELECT, INSERT, UPDATE ON oltp_store.sale_products TO nhanvienban;
GRANT SELECT, INSERT, UPDATE ON oltp_store.sale_orders TO nhanvienban;
GRANT SELECT, INSERT, UPDATE ON oltp_store.sale_customers TO nhanvienban;
GRANT SELECT, INSERT, UPDATE ON oltp_store.transactions TO nhanvienban;
GRANT SELECT, INSERT, UPDATE ON oltp_store.expenses TO nhanvienban;
GRANT SELECT, INSERT, UPDATE ON oltp_store.feedbacks TO nhanvienban;
GRANT SELECT, INSERT, UPDATE ON oltp_store.customers TO nhanvienban;
GRANT SELECT ON oltp_store.users TO nhanvienban;

-- nhanvienthue (Rentals Staff) Grants
GRANT SELECT, INSERT, UPDATE ON oltp_store.products TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.equipments TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.bookings TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.booking_equipments TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.categories TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.camera_models TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.customers TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.maintenance_logs TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.transactions TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.expenses TO nhanvienthue;
GRANT SELECT, INSERT, UPDATE ON oltp_store.feedbacks TO nhanvienthue;
GRANT SELECT ON oltp_store.users TO nhanvienthue;

-- Grant serial sequence generation privileges
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA oltp_store TO nhanvienban, nhanvienthue;


-- =========================================================================
-- 4. ROW-LEVEL SECURITY (RLS) POLICIES FOR SUPABASE
-- =========================================================================

-- Enable RLS
ALTER TABLE oltp_store.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE oltp_store.sale_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE oltp_store.transactions ENABLE ROW LEVEL SECURITY;

-- Dynamic role verification function
CREATE OR REPLACE FUNCTION oltp_store.get_current_role()
RETURNS VARCHAR AS $$
DECLARE
    v_role VARCHAR;
BEGIN
    IF current_setting('request.jwt.claims', true) IS NOT NULL THEN
        SELECT role INTO v_role FROM oltp_store.users WHERE id = auth.uid();
        RETURN COALESCE(v_role, 'CUSTOMER');
    ELSE
        RETURN 'ADMIN'; -- Default to admin for direct PG execution/migrations
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bookings RLS policies
DROP POLICY IF EXISTS "Admins have full access on bookings" ON oltp_store.bookings;
CREATE POLICY "Admins have full access on bookings" ON oltp_store.bookings
    FOR ALL USING (oltp_store.get_current_role() = 'ADMIN');

DROP POLICY IF EXISTS "Rental staff can manage bookings" ON oltp_store.bookings;
CREATE POLICY "Rental staff can manage bookings" ON oltp_store.bookings
    FOR ALL USING (oltp_store.get_current_role() = 'NHANVIENTHUE');

DROP POLICY IF EXISTS "Customers can view their own bookings" ON oltp_store.bookings;
CREATE POLICY "Customers can view their own bookings" ON oltp_store.bookings
    FOR SELECT USING (customer_id = auth.uid());

-- Sale Orders RLS policies
DROP POLICY IF EXISTS "Admins have full access on sale_orders" ON oltp_store.sale_orders;
CREATE POLICY "Admins have full access on sale_orders" ON oltp_store.sale_orders
    FOR ALL USING (oltp_store.get_current_role() = 'ADMIN');

DROP POLICY IF EXISTS "Sales staff can manage sale_orders" ON oltp_store.sale_orders;
CREATE POLICY "Sales staff can manage sale_orders" ON oltp_store.sale_orders
    FOR ALL USING (oltp_store.get_current_role() = 'NHANVIENBAN');

DROP POLICY IF EXISTS "Customers can view their own sale_orders" ON oltp_store.sale_orders;
CREATE POLICY "Customers can view their own sale_orders" ON oltp_store.sale_orders
    FOR SELECT USING (customer_id = auth.uid());
