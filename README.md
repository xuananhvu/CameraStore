# Film Camera Store - Local Setup

Ứng dụng quản lý cửa hàng cho thuê & bán máy ảnh film (Backend API Express.js + Frontend React/Vite + Supabase Database).

## 🚀 Khởi động nhanh (Localhost)

Cần chạy đồng thời cả Backend và Frontend ở 2 terminal riêng biệt:

### 1. Khởi chạy Backend
```bash
cd backend-v2
npm install
npm run dev
```
*   Backend chạy tại: **http://localhost:3002**

### 2. Khởi chạy Frontend
```bash
cd frontend
npm install
npm run dev
```
*   Frontend chạy tại: **http://localhost:3000** (hoặc port được cấp trên local)

---

## ⚙️ Cấu hình môi trường (.env)

### Backend (`backend-v2/.env`)
```env
PORT=3002
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
JWT_SECRET=super-secret-jwt-key
NODE_ENV=development
```

### Frontend (`frontend/.env`)
```env
VITE_API_BASE_URL=http://localhost:3002/api
```

---

## 💾 Thiết lập Cơ sở dữ liệu (Supabase)

Dự án sử dụng **Supabase CLI** để quản lý migrations. Các tệp tin migrations được lưu tại thư mục [supabase/migrations](file:///d:/dowload%202/2025.2/PTTKHT%20BTL/CameraStore/supabase/migrations).

Để đồng bộ schema cơ sở dữ liệu lên Supabase cá nhân của bạn:

1. Đăng nhập Supabase CLI:
   ```bash
   supabase login
   ```
2. Liên kết với project của bạn:
   ```bash
   supabase link --project-ref <your-project-ref>
   ```
3. Đẩy cấu trúc bảng (migrations) lên database:
   ```bash
   supabase db push
   ```
4. (Tùy chọn) Chạy seed dữ liệu mẫu:
   ```bash
   supabase db reset
   ```
