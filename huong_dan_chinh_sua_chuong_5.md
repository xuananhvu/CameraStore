# Hướng dẫn chi tiết chỉnh sửa Chương 5 - Xây dựng hệ thống

## 1. Mục tiêu sửa Chương 5

Chương 5 không nên chỉ là phần chụp giao diện. Chương này cần chứng minh rằng thiết kế ở Chương 3 và Chương 4 đã được hiện thực thành hệ thống chạy được.

Chuỗi trình bày nên là:

> Thiết kế → Module/API → Giao diện → Dữ liệu → Kết quả chạy Use Case

Người chấm cần thấy rõ:

| Câu hỏi | Chương 5 cần trả lời |
|---|---|
| Use Case ở Chương 3 đã được làm chưa? | Có bảng mapping Use Case → giao diện/API |
| CSDL ở Chương 4 có được dùng không? | Có nêu bảng dữ liệu bị tác động |
| Giao diện này dùng để làm gì? | Có actor, Use Case, nghiệp vụ liên quan |
| Hệ thống chạy ra kết quả gì? | Có test case/kịch bản chạy và kết quả |
| Có đúng thiết kế không? | Có mô tả Controller/Service/Table tương ứng |

---

## 2. Cấu trúc Chương 5 nên sửa lại

Có thể giữ tên chương:

> **CHƯƠNG 5. Xây dựng hệ thống**

Nhưng bên trong nên chỉnh thành:

```text
5.1 Môi trường và công cụ phát triển
5.2 Ánh xạ từ thiết kế sang cài đặt
5.3 Thiết kế giao diện hệ thống
5.4 Chạy thử các Use Case chính
5.5 Đánh giá kết quả hiện thực hóa
```

---

## 3. Sửa mục 5.1 - Môi trường và công cụ phát triển

### 3.1. Mục tiêu của 5.1

Không chỉ liệt kê công nghệ, mà cần nói rõ hệ thống được xây dựng bằng gì, chạy ở đâu, chia thành những phần nào và mỗi công nghệ đảm nhận vai trò gì.

### 3.2. Bảng môi trường phát triển nên bổ sung

| Thành phần | Công cụ / Công nghệ | Vai trò |
|---|---|---|
| Hệ điều hành phát triển | Windows / Linux | Môi trường lập trình và kiểm thử |
| Frontend | React, Vite, TypeScript | Xây dựng SPA giao diện người dùng |
| UI Framework | TailwindCSS | Thiết kế giao diện responsive |
| State Management | Zustand | Quản lý trạng thái phía client |
| HTTP Client | Axios | Gửi request tới backend API |
| Backend | Node.js, Express, TypeScript | Xử lý logic nghiệp vụ |
| Validation | Zod | Kiểm tra dữ liệu đầu vào |
| Database | Supabase PostgreSQL | Lưu trữ dữ liệu hệ thống |
| Authentication | Supabase Auth, JWT | Xác thực và phân quyền |
| Deploy Frontend | Vercel | Triển khai giao diện |
| Deploy Backend | Render | Triển khai API server |

### 3.3. Bảng cấu trúc module cài đặt

| Module | Thành phần chính | Use Case liên quan |
|---|---|---|
| `system-auth` | AuthController, AuthService | UC01-UC05 |
| `profile-logs` | ProfileController, ProfileService | UC06-UC07 |
| `inventory` | CategoryService, CameraModelService, EquipmentService | UC08-UC12 |
| `rentals-pos` | BookingController, BookingService | UC13-UC17 |
| `finance` | TransactionController, TransactionService | UC18 |
| `banmayfilm` | SaleProductService, SaleOrderService | UC19-UC22 |
| `customer-crm` | CustomerService | UC22-UC23 |
| `expenses` | ExpenseService | UC24 |
| `feedbacks` | FeedbackService | UC25 |
| `reporting` | ReportingService | UC26-UC27 |

### 3.4. Quy trình chạy hệ thống

Có thể thêm đoạn sau:

```text
Quy trình chạy hệ thống trong môi trường phát triển gồm:
1. Cài đặt dependencies cho frontend và backend.
2. Cấu hình biến môi trường kết nối Supabase.
3. Khởi động backend API server.
4. Khởi động frontend React/Vite.
5. Đăng nhập bằng tài khoản thử nghiệm để kiểm tra các phân hệ.
```

Lưu ý: Không ghi mật khẩu thật. Nếu cần nhắc tài khoản, chỉ ghi “tài khoản thử nghiệm trong môi trường phát triển”.

---

## 4. Sửa mục 5.2 - Ánh xạ từ thiết kế sang cài đặt

### 4.1. Mục tiêu của 5.2

Đây là phần quan trọng nhất cần bổ sung. Mục 5.2 phải chứng minh rằng nội dung thiết kế ở Chương 3 và Chương 4 đã được hiện thực.

Nên đổi tên mục 5.2 thành:

> **5.2 Ánh xạ từ thiết kế sang cài đặt**

hoặc:

> **5.2 Quy trình chuyển đổi từ thiết kế sang cài đặt**

### 4.2. Bảng mapping Use Case → Module → API → Database

| Use Case | Chức năng | Module cài đặt | API chính | Bảng dữ liệu liên quan |
|---|---|---|---|---|
| UC01 | Đăng ký tài khoản nhân viên | `system-auth` | `POST /api/auth/register` | `users` |
| UC02 | Đăng nhập | `system-auth` | `POST /api/auth/login` | `users`, Supabase Auth |
| UC04 | Kích hoạt / vô hiệu hóa tài khoản | `system-auth` | `PUT /api/auth/users/:id/status` | `users` |
| UC08 | Quản lý danh mục | `inventory` | API category | `categories` |
| UC09 | Quản lý dòng máy thuê | `inventory` | API camera model | `camera_models` |
| UC10 | Quản lý thiết bị vật lý | `inventory` | API equipment | `equipments`, `maintenance_logs` |
| UC12 | Nhập kho thuê | `inventory` | API rental import | `rental_imports`, `equipments`, `products` |
| UC13 | Tạo đặt lịch thuê | `rentals-pos` | `POST /api/bookings` | `bookings`, `booking_equipments`, `equipments` |
| UC14 | Check-in bàn giao | `rentals-pos` | `POST /api/bookings/:id/checkin` | `bookings`, `booking_equipments`, `equipments` |
| UC15 | Check-out quyết toán cọc | `finance` | `POST /api/transactions/settle` | `bookings`, `transactions`, `equipments` |
| UC16 | Hủy booking | `rentals-pos` | `POST /api/bookings/:id/cancel` | `bookings`, `equipments` |
| UC17 | Gia hạn thuê | `rentals-pos` | `POST /api/bookings/:id/extend` | `bookings`, `booking_equipments` |
| UC18 | Quản lý giao dịch | `finance` | API transactions | `transactions` |
| UC19 | Quản lý sản phẩm bán lẻ | `banmayfilm` | API sale products | `sale_products` |
| UC20 | Nhập kho bán lẻ | `banmayfilm` | API sale imports | `sale_imports`, `sale_products` |
| UC21 | Tạo đơn POS | `banmayfilm` | API sale orders | `sale_orders`, `sale_products`, `transactions` |
| UC22 | Quản lý khách hàng mua | `customer-crm` | API sale customers | `sale_customers`, `customers` |
| UC23 | Quản lý khách hàng thuê | `customer-crm` | API rental customers | `customers` |
| UC24 | Quản lý chi phí | `expenses` | API expenses | `expenses` |
| UC25 | Ghi nhận phản hồi | `feedbacks` | API feedbacks | `feedbacks` |
| UC26 | Báo cáo doanh thu | `reporting` | API reports | `transactions`, `bookings`, `sale_orders` |
| UC27 | Lịch sử đơn hàng | `reporting` | API history | `bookings`, `sale_orders`, `orders` |

Với endpoint chưa chắc chắn, có thể ghi trung tính như “API tạo đơn POS”, “API báo cáo doanh thu”, sau đó kiểm tra code rồi điền endpoint cụ thể.

### 4.3. Bảng mapping thiết kế UML → cài đặt

| Thành phần thiết kế | Thành phần cài đặt | Ghi chú |
|---|---|---|
| Actor Admin | Role `ADMIN` | Có quyền quản trị tài khoản, báo cáo |
| Actor Nhân viên thuê | Role `NHANVIENTHUE` | Thao tác booking, check-in/out |
| Actor Nhân viên bán | Role `NHANVIENBAN` | Thao tác POS và kho bán |
| Boundary class | React Page / Component | Form nhập liệu, bảng danh sách |
| Control class | Controller / Service | Xử lý request và nghiệp vụ |
| Entity class | PostgreSQL Table | Lưu trữ dữ liệu lâu dài |
| Activity diagram thuê máy | Booking workflow | Tạo booking → check-in → check-out |
| Sequence diagram POS | Sale order flow | Tạo đơn → trừ kho → ghi giao dịch |
| ERD | Supabase schema | Các bảng và quan hệ dữ liệu |

### 4.4. Đoạn văn mẫu cho 5.2

```text
Dựa trên các mô hình phân tích và thiết kế đã trình bày ở Chương 3 và Chương 4, nhóm tiến hành hiện thực hóa hệ thống theo hướng use-case driven. Mỗi Use Case được ánh xạ thành một hoặc nhiều API endpoint ở tầng backend, đồng thời tương ứng với các giao diện thao tác ở tầng frontend và các bảng dữ liệu ở tầng database.

Về mặt kiến trúc, các màn hình React đóng vai trò là lớp biên tiếp nhận thao tác từ người dùng; các Controller và Service trong backend đóng vai trò lớp điều khiển xử lý nghiệp vụ; các bảng PostgreSQL trong Supabase đóng vai trò lớp thực thể lưu trữ dữ liệu. Cách tổ chức này giúp đảm bảo sự nhất quán giữa mô hình BCE trong thiết kế và cấu trúc cài đặt thực tế của hệ thống.
```

---

## 5. Sửa mục 5.3 - Thiết kế giao diện hệ thống

### 5.1. Vấn đề hiện tại

Báo cáo đang có nhiều ảnh giao diện. Đây là điểm tốt. Tuy nhiên, mỗi ảnh cần được gắn với:

- Actor nào dùng?
- Use Case nào?
- API nào?
- Dữ liệu nào?
- Kết quả thao tác là gì?

Nếu không, ảnh chỉ là minh họa UI, chưa chứng minh hiện thực Use Case.

### 5.2. Mẫu viết cho mỗi giao diện

Mỗi mục 5.3.x nên theo format:

```text
Giao diện này phục vụ cho tác nhân ...
Các Use Case liên quan gồm ...
Dữ liệu được lấy từ các bảng ...
Các thao tác chính gồm ...
Khi người dùng thực hiện thao tác, frontend gửi request tới ...
Kết quả sau xử lý là ...
```

### 5.3. Ví dụ: Giao diện Đăng nhập

```text
Giao diện Đăng nhập phục vụ cho tất cả các tác nhân trong hệ thống gồm Admin, Nhân viên cho thuê và Nhân viên bán hàng. Giao diện này hiện thực UC02 - Đăng nhập hệ thống.

Người dùng nhập email/tên đăng nhập và mật khẩu. Sau khi bấm nút đăng nhập, frontend gửi request tới API đăng nhập của backend. Backend xác thực thông tin qua Supabase Auth, sau đó truy vấn bảng users để lấy vai trò và trạng thái tài khoản. Nếu tài khoản hợp lệ và đang hoạt động, hệ thống trả về access token và điều hướng người dùng tới màn hình tương ứng với vai trò.
```

| Thành phần | Nội dung |
|---|---|
| Actor | Admin, NHANVIENTHUE, NHANVIENBAN |
| Use Case | UC02 |
| API | `POST /api/auth/login` |
| Bảng dữ liệu | `users`, Supabase Auth |
| Kết quả | Đăng nhập thành công và phân quyền giao diện |

### 5.4. Ví dụ: Giao diện Lập đơn thuê

```text
Giao diện Lập đơn thuê là giao diện trọng tâm của phân hệ cho thuê thiết bị, phục vụ tác nhân Nhân viên cho thuê. Giao diện này hiện thực các Use Case UC13 - Tạo đặt lịch thuê, UC14 - Check-in bàn giao, UC15 - Check-out quyết toán cọc, UC16 - Hủy booking và UC17 - Gia hạn thuê.

Khi tạo đơn thuê mới, nhân viên chọn khách hàng, dòng máy, thời gian thuê và các thông tin đặt cọc. Hệ thống kiểm tra tính hợp lệ của khoảng thời gian thuê, tìm thiết bị vật lý khả dụng không bị trùng lịch, sau đó tự động gán thiết bị cho booking. Sau khi tạo thành công, dữ liệu được ghi vào bảng bookings và booking_equipments, đồng thời trạng thái thiết bị trong bảng equipments được cập nhật.
```

| Thành phần | Nội dung |
|---|---|
| Actor | NHANVIENTHUE |
| Use Case | UC13, UC14, UC15, UC16, UC17 |
| API chính | `POST /api/bookings`, `POST /api/bookings/:id/checkin`, `POST /api/transactions/settle` |
| Bảng dữ liệu | `customers`, `camera_models`, `equipments`, `bookings`, `booking_equipments`, `transactions` |
| Kết quả | Tạo booking, bàn giao, nhận trả máy và quyết toán cọc |

### 5.5. Ví dụ: Giao diện POS bán hàng

```text
Giao diện Lập đơn bán hàng phục vụ tác nhân Nhân viên bán hàng. Giao diện này hiện thực UC21 - Tạo đơn bán hàng POS. Nhân viên chọn sản phẩm, nhập số lượng và xác nhận thanh toán. Hệ thống kiểm tra tồn kho của sản phẩm bán lẻ, tạo đơn bán hàng, cập nhật tồn kho và ghi nhận giao dịch tài chính tương ứng.
```

| Thành phần | Nội dung |
|---|---|
| Actor | NHANVIENBAN |
| Use Case | UC21 |
| API | API tạo đơn bán hàng POS |
| Bảng dữ liệu | `sale_products`, `sale_orders`, `transactions` |
| Kết quả | Đơn bán được tạo, tồn kho giảm, giao dịch được ghi nhận |

### 5.6. Ví dụ: Giao diện Kho máy cho thuê

```text
Giao diện Kho máy cho thuê hiện thực các Use Case UC09 - Quản lý dòng máy ảnh thuê và UC10 - Quản lý thiết bị vật lý. Giao diện cho phép nhân viên xem danh sách dòng máy, tình trạng từng thiết bị theo serial number và cập nhật trạng thái thiết bị như AVAILABLE, RENTED, MAINTENANCE hoặc DAMAGED.
```

| Thành phần | Nội dung |
|---|---|
| Actor | Admin, NHANVIENTHUE |
| Use Case | UC09, UC10 |
| API | API camera models, API equipments |
| Bảng dữ liệu | `camera_models`, `equipments`, `maintenance_logs` |
| Kết quả | Quản lý dòng máy và trạng thái thiết bị vật lý |

---

## 6. Sửa mục 5.4 - Chạy thử các Use Case chính

### 6.1. Vấn đề hiện tại

Mục 5.4 hiện đang giống mô tả chức năng hoặc mô tả giao diện, chưa phải chạy thử.

Cần đổi thành:

> Nhóm tiến hành chạy thử các Use Case trọng tâm với dữ liệu đầu vào, thao tác thực hiện, kết quả mong đợi và kết quả thực tế.

### 6.2. Cấu trúc nên dùng cho 5.4

```text
5.4 Chạy thử các Use Case chính
5.4.1 Kịch bản UC02 - Đăng nhập hệ thống
5.4.2 Kịch bản UC13 - Tạo đặt lịch thuê thiết bị
5.4.3 Kịch bản UC14 - Check-in bàn giao thiết bị
5.4.4 Kịch bản UC15 - Check-out và quyết toán cọc
5.4.5 Kịch bản UC21 - Tạo đơn bán hàng POS
5.4.6 Kịch bản UC26 - Xem báo cáo doanh thu
5.4.7 Tổng hợp kết quả chạy thử
```

Không cần chạy sâu cả 27 UC. Nên chọn 6-8 UC chính.

---

## 7. Mẫu chi tiết cho từng kịch bản chạy Use Case

### 7.1. UC02 - Đăng nhập hệ thống

| Thành phần | Nội dung |
|---|---|
| Use Case | UC02 - Đăng nhập |
| Actor | Admin / Nhân viên |
| Tiền điều kiện | Tài khoản đã tồn tại và đang hoạt động |
| Dữ liệu đầu vào | Email/tên đăng nhập, mật khẩu |
| Thao tác | Nhập thông tin và bấm đăng nhập |
| Kết quả mong đợi | Hệ thống xác thực thành công, chuyển tới dashboard |
| Kết quả thực tế | Đăng nhập thành công, giao diện hiển thị theo vai trò |
| Trạng thái | Đạt |

```text
Nhóm tiến hành kiểm thử UC02 bằng tài khoản thử nghiệm trong môi trường phát triển. Sau khi nhập thông tin đăng nhập hợp lệ, hệ thống gửi request xác thực tới backend. Backend kiểm tra thông tin qua Supabase Auth và truy vấn bảng users để lấy vai trò người dùng. Kết quả cho thấy người dùng đăng nhập thành công và được điều hướng tới giao diện phù hợp với quyền hạn.
```

### 7.2. UC13 - Tạo đặt lịch thuê thiết bị

| Thành phần | Nội dung |
|---|---|
| Use Case | UC13 - Tạo đặt lịch thuê thiết bị |
| Actor | NHANVIENTHUE |
| Tiền điều kiện | Nhân viên đã đăng nhập; khách hàng tồn tại; dòng máy còn thiết bị khả dụng |
| Dữ liệu đầu vào | Khách hàng, dòng máy, ngày thuê, ngày trả, tiền cọc |
| Thao tác | Nhân viên tạo booking mới |
| Kết quả mong đợi | Booking được tạo ở trạng thái `PENDING`; thiết bị rảnh được tự động gán |
| Bảng bị tác động | `bookings`, `booking_equipments`, `equipments` |
| Kết quả thực tế | Hệ thống tạo đơn thuê và hiển thị trong danh sách |
| Trạng thái | Đạt |

```text
Ở kịch bản UC13, nhân viên cho thuê nhập thông tin khách hàng, chọn dòng máy cần thuê và khoảng thời gian thuê. Khi xác nhận tạo đơn, hệ thống thực hiện kiểm tra xung đột lịch thuê bằng cách đối chiếu các bản ghi trong booking_equipments và bookings. Nếu tìm được thiết bị vật lý khả dụng, hệ thống tạo bản ghi booking mới, tạo liên kết thiết bị trong booking_equipments và cập nhật trạng thái thiết bị tương ứng. Kết quả chạy thử cho thấy đơn thuê được tạo thành công và xuất hiện trong danh sách lịch sử thuê.
```

| Trường hợp ngoại lệ | Kết quả mong đợi |
|---|---|
| Chọn khoảng thời gian đã có thiết bị bị đặt hết | Hệ thống báo không còn thiết bị khả dụng |
| Ngày trả trước ngày thuê | Hệ thống báo dữ liệu không hợp lệ |
| Thiếu khách hàng | Hệ thống yêu cầu chọn khách hàng |

### 7.3. UC14 - Check-in bàn giao thiết bị

| Thành phần | Nội dung |
|---|---|
| Use Case | UC14 - Check-in bàn giao thiết bị |
| Actor | NHANVIENTHUE |
| Tiền điều kiện | Booking đang ở trạng thái `PENDING` hoặc `CONFIRMED` |
| Dữ liệu đầu vào | Booking ID, phụ kiện bàn giao, tình trạng thiết bị |
| Thao tác | Nhân viên bấm Check-in |
| Kết quả mong đợi | Booking chuyển sang `CHECKED_IN`, ghi nhận thời điểm bàn giao |
| Bảng bị tác động | `bookings`, `booking_equipments`, `equipments` |
| Trạng thái | Đạt |

```text
Với UC14, nhân viên chọn một đơn thuê đã được tạo và thực hiện thao tác Check-in. Hệ thống kiểm tra trạng thái hiện tại của booking, sau đó ghi nhận thời điểm bàn giao, nhân viên bàn giao và tình trạng thiết bị khi giao đi. Thông tin phụ kiện kèm theo được lưu vào bản ghi liên kết giữa booking và thiết bị. Sau khi xử lý thành công, đơn thuê chuyển sang trạng thái CHECKED_IN.
```

### 7.4. UC15 - Check-out và quyết toán cọc

| Thành phần | Nội dung |
|---|---|
| Use Case | UC15 - Check-out / Tất toán |
| Actor | NHANVIENTHUE |
| Tiền điều kiện | Booking đang ở trạng thái `CHECKED_IN` |
| Dữ liệu đầu vào | Giờ trả, tình trạng hư hỏng, phí hư hỏng, ghi chú |
| Thao tác | Nhân viên xác nhận trả máy |
| Kết quả mong đợi | Tính tiền thuê, phụ phí, tiền hoàn cọc; thiết bị về `AVAILABLE` |
| Bảng bị tác động | `bookings`, `transactions`, `equipments` |
| Trạng thái | Đạt |

```text
Ở kịch bản UC15, nhân viên thực hiện nhận lại thiết bị từ khách hàng và nhập thông tin trả máy. Hệ thống tính tiền thuê cơ bản dựa trên số ngày thuê, kiểm tra giờ trả thực tế để tính phụ phí quá giờ nếu có, đồng thời khấu trừ phí hư hỏng vào tiền cọc. Sau khi tất toán, booking được cập nhật trạng thái CHECKED_OUT, thiết bị vật lý được đưa về trạng thái AVAILABLE và giao dịch hoàn cọc hoặc khấu trừ được ghi nhận trong bảng transactions.
```

| Giờ trả thực tế | Kết quả xử lý |
|---|---|
| Trước hoặc bằng 22:00 | Không tính phụ phí |
| 22:01 - 22:30 | Phụ thu `50\%` đơn giá thuê ngày |
| Sau 22:30 | Phụ thu `100\%` đơn giá thuê ngày |

Lưu ý khi viết LaTeX: phải viết `50\%`, `100\%`.

### 7.5. UC21 - Tạo đơn bán hàng POS

| Thành phần | Nội dung |
|---|---|
| Use Case | UC21 - Tạo đơn bán hàng POS |
| Actor | NHANVIENBAN |
| Tiền điều kiện | Nhân viên đã đăng nhập; sản phẩm còn tồn kho |
| Dữ liệu đầu vào | Sản phẩm, số lượng, phương thức thanh toán |
| Thao tác | Nhân viên tạo đơn bán |
| Kết quả mong đợi | Đơn bán được tạo, tồn kho giảm, giao dịch được ghi nhận |
| Bảng bị tác động | `sale_orders`, `sale_products`, `transactions` |
| Trạng thái | Đạt |

```text
Trong kịch bản UC21, nhân viên bán hàng chọn sản phẩm bán lẻ, nhập số lượng và xác nhận thanh toán. Hệ thống kiểm tra tồn kho khả dụng của sản phẩm. Nếu số lượng tồn kho đủ, hệ thống tạo đơn bán hàng, cập nhật tồn kho và ghi nhận giao dịch doanh thu. Nếu tồn kho không đủ, hệ thống hiển thị thông báo lỗi và không tạo đơn.
```

| Trường hợp ngoại lệ | Kết quả mong đợi |
|---|---|
| Số lượng bán lớn hơn tồn kho | Không cho tạo đơn, báo thiếu hàng |
| Chưa chọn sản phẩm | Báo thiếu thông tin |
| Thanh toán thất bại | Không ghi nhận đơn hoàn tất |

### 7.6. UC26 - Xem báo cáo doanh thu

| Thành phần | Nội dung |
|---|---|
| Use Case | UC26 - Báo cáo doanh thu |
| Actor | Admin |
| Tiền điều kiện | Admin đã đăng nhập |
| Dữ liệu đầu vào | Khoảng thời gian lọc |
| Thao tác | Chọn ngày/tháng/năm và xem báo cáo |
| Kết quả mong đợi | Hệ thống hiển thị doanh thu thuê, doanh thu bán, chi phí, lợi nhuận |
| Bảng dữ liệu | `transactions`, `bookings`, `sale_orders`, `expenses` |
| Trạng thái | Đạt |

```text
Ở kịch bản UC26, quản trị viên truy cập giao diện báo cáo và chọn khoảng thời gian cần thống kê. Hệ thống tổng hợp dữ liệu từ các giao dịch thuê máy, bán hàng POS và chi phí vận hành để hiển thị doanh thu, chi phí và lợi nhuận tương ứng. Kết quả chạy thử cho thấy báo cáo được cập nhật theo bộ lọc thời gian và hỗ trợ quản lý theo dõi tình hình kinh doanh.
```

---

## 8. Bảng tổng hợp kết quả chạy thử ở cuối 5.4

| UC | Tên Use Case | Giao diện kiểm thử | Kết quả chính | Trạng thái |
|---|---|---|---|---|
| UC02 | Đăng nhập | Giao diện đăng nhập | Đăng nhập và phân quyền thành công | Đạt |
| UC13 | Tạo booking | Lập đơn thuê | Tạo đơn và gán thiết bị | Đạt |
| UC14 | Check-in | Lập đơn thuê | Cập nhật trạng thái bàn giao | Đạt |
| UC15 | Check-out | Lịch sử thuê / Tất toán | Tính phí và hoàn cọc | Đạt |
| UC21 | Tạo đơn POS | Lập đơn bán hàng | Tạo đơn và trừ kho | Đạt |
| UC26 | Báo cáo doanh thu | Dashboard / Báo cáo | Hiển thị doanh thu theo thời gian | Đạt |

Có thể thêm bảng ghi chú thực tế hơn:

| UC | Tên Use Case | Kết quả | Ghi chú |
|---|---|---|---|
| UC13 | Tạo booking | Đạt | Cần kiểm thử thêm trường hợp nhiều người đặt đồng thời |
| UC15 | Check-out | Đạt | Cần kiểm tra thêm các mốc phụ phí |
| UC21 | POS | Đạt | Cần thống nhất schema đơn nhiều sản phẩm |

---

## 9. Thêm mục 5.5 - Đánh giá kết quả hiện thực hóa

Nội dung mẫu:

```text
Qua quá trình hiện thực hóa và chạy thử các Use Case chính, hệ thống đã bước đầu đáp ứng các yêu cầu nghiệp vụ cốt lõi đã phân tích. Các luồng quan trọng như đăng nhập, tạo booking, bàn giao thiết bị, tất toán trả máy, tạo đơn bán hàng POS và xem báo cáo doanh thu đã được cài đặt và kiểm thử ở mức chức năng.

Kết quả chạy thử cho thấy mô hình kiến trúc 3 tầng được áp dụng nhất quán: frontend đảm nhiệm giao diện tương tác, backend xử lý logic nghiệp vụ và database lưu trữ dữ liệu. Các thao tác nghiệp vụ chính đều có sự thay đổi dữ liệu tương ứng trong các bảng liên quan, thể hiện sự liên kết giữa thiết kế cơ sở dữ liệu ở Chương 4 và phần cài đặt thực tế.

Tuy nhiên, việc kiểm thử hiện tại chủ yếu tập trung vào các kịch bản chức năng cơ bản. Hệ thống vẫn cần được bổ sung kiểm thử tự động, kiểm thử đồng thời đối với nghiệp vụ đặt lịch thuê và kiểm thử tải để đánh giá độ ổn định khi vận hành thực tế.
```

---

## 10. Các lỗi cần tránh khi sửa Chương 5

### 10.1. Không biến Chương 5 thành gallery ảnh

Sai:

```text
Hình 5.3 là giao diện lập đơn bán hàng.
```

Đúng:

```text
Hình 5.3 là giao diện lập đơn bán hàng, hiện thực UC21. Nhân viên bán hàng chọn sản phẩm, nhập số lượng và xác nhận thanh toán. Sau khi xử lý, hệ thống tạo bản ghi đơn bán, cập nhật tồn kho và ghi nhận giao dịch doanh thu.
```

### 10.2. Không dùng từ “Usecase” lung tung

Nên thống nhất:

- “Use Case” trong tiêu đề.
- “ca sử dụng” nếu muốn Việt hóa.
- Không dùng lúc “Usecase”, lúc “Use case”, lúc “usecase”.

### 10.3. Không ghi endpoint nếu chưa chắc

Nếu chưa chắc endpoint, ghi trung tính:

```text
API tạo đơn thuê
API check-in booking
API tất toán giao dịch
```

Sau khi kiểm tra code mới đổi thành endpoint cụ thể.

### 10.4. Không ghi tài khoản thật

Đổi:

```text
Đăng nhập bằng admin/admin123
```

Thành:

```text
Đăng nhập bằng tài khoản quản trị thử nghiệm trong môi trường phát triển.
```

### 10.5. Không khẳng định đã kiểm thử toàn bộ nếu chưa có bằng chứng

Đổi:

```text
Hệ thống đã kiểm thử đầy đủ toàn bộ chức năng.
```

Thành:

```text
Nhóm đã chạy thử các Use Case trọng tâm để kiểm tra tính đúng đắn của các luồng nghiệp vụ chính.
```

---

## 11. Bố cục cuối cùng nên có cho Chương 5

```text
CHƯƠNG 5. Xây dựng hệ thống

5.1 Môi trường và công cụ phát triển
    5.1.1 Môi trường phát triển
    5.1.2 Công nghệ sử dụng
    5.1.3 Cấu trúc module hệ thống

5.2 Ánh xạ từ thiết kế sang cài đặt
    5.2.1 Ánh xạ mô hình 3 tầng/BCE sang cài đặt
    5.2.2 Ánh xạ Use Case sang module, API và bảng dữ liệu

5.3 Thiết kế giao diện hệ thống
    5.3.1 Giao diện Đăng nhập
    5.3.2 Giao diện Tổng quan
    5.3.3 Giao diện Lập đơn thuê
    5.3.4 Giao diện Kho máy cho thuê
    5.3.5 Giao diện Lập đơn bán hàng
    5.3.6 Giao diện Kho hàng bán
    5.3.7 Giao diện Khách hàng
    5.3.8 Giao diện Báo cáo
    5.3.9 Giao diện Quản trị hệ thống

5.4 Chạy thử các Use Case chính
    5.4.1 UC02 - Đăng nhập hệ thống
    5.4.2 UC13 - Tạo đặt lịch thuê thiết bị
    5.4.3 UC14 - Check-in bàn giao thiết bị
    5.4.4 UC15 - Check-out và quyết toán cọc
    5.4.5 UC21 - Tạo đơn bán hàng POS
    5.4.6 UC26 - Xem báo cáo doanh thu
    5.4.7 Tổng hợp kết quả chạy thử

5.5 Đánh giá kết quả hiện thực hóa
```

---

## 12. Ưu tiên sửa nhanh

Nếu thời gian ít, làm 4 việc này là đủ nâng chất lượng Chương 5 rõ nhất:

1. Thêm bảng **Use Case → Module → API → Bảng dữ liệu** ở mục 5.2.
2. Với mỗi giao diện chính, thêm bảng nhỏ: **Actor → UC → API → Database → Kết quả**.
3. Sửa mục 5.4 thành **test case chạy thử**, có input, expected result, actual result.
4. Thêm mục 5.5 đánh giá kết quả và giới hạn kiểm thử.

Làm xong 4 việc này, Chương 5 sẽ giống “hiện thực hóa và cài đặt hệ thống” hơn nhiều, không còn là phần chụp màn hình đơn thuần.
