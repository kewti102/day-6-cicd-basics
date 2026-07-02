# Part E — Failure Scenarios

## 1. Khi pipeline thất bại ở step push, làm sao retry nhanh không build lại?

Nếu image đã được build thành công nhưng pipeline thất bại ở bước **push**, không cần build lại từ đầu.

Có thể:

* Sử dụng **cache của Docker Buildx** (`cache-from` và `cache-to`) để tái sử dụng các layer đã build.
* Chạy lại riêng job hoặc workflow bằng **Re-run failed jobs** trên GitHub Actions.
* Trong trường hợp pipeline được thiết kế tách riêng bước **build** và **push**, chỉ cần chạy lại bước push thay vì thực hiện lại toàn bộ quá trình build.

Điều này giúp tiết kiệm thời gian và tài nguyên của CI.

---

## 2. Cách debug một job chỉ fail trên runner nhưng không tái hiện được ở máy local?

Có thể áp dụng các cách sau:

* Xem chi tiết log của từng step trên GitHub Actions.
* Thêm các lệnh debug như:

  ```bash
  pwd
  ls -la
  env
  node --version
  docker version
  ```
* Kiểm tra sự khác biệt giữa môi trường local và GitHub Runner (hệ điều hành, phiên bản Node.js, Docker, biến môi trường,...).
* Chạy workflow bằng công cụ **act** để mô phỏng GitHub Actions trên máy local.
* Kiểm tra lại các Secret, Permission và Environment của repository.

---

## 3. So sánh `needs`, `if` và `concurrency`

### `needs`

* Dùng để tạo quan hệ phụ thuộc giữa các job.
* Job chỉ chạy khi các job được chỉ định trong `needs` hoàn thành thành công.

Ví dụ:

```yaml
test:
  needs: lint
```

---

### `if`

* Dùng để quyết định có chạy job hoặc step hay không.
* Điều kiện được đánh giá tại thời điểm workflow chạy.

Ví dụ:

```yaml
if: github.ref == 'refs/heads/main'
```

---

### `concurrency`

* Giới hạn số workflow hoặc job chạy đồng thời.
* Nếu có workflow mới thuộc cùng một nhóm (`group`), workflow cũ có thể bị hủy.

Ví dụ:

```yaml
concurrency:
  group: deploy-production
  cancel-in-progress: true
```

Điều này giúp tránh nhiều lần deploy cùng lúc lên một môi trường.

---

## 4. Tại sao nên dùng OIDC để xác thực AWS thay vì Static Access Key?

OIDC (OpenID Connect) là cơ chế xác thực hiện đại giữa GitHub Actions và AWS.

Ưu điểm:

* Không cần lưu AWS Access Key trong GitHub Secrets.
* AWS cấp **temporary credentials** cho mỗi lần workflow chạy.
* Giảm nguy cơ lộ khóa truy cập.
* Credentials tự động hết hạn sau một khoảng thời gian ngắn.
* Dễ quản lý và tuân thủ các tiêu chuẩn bảo mật.

Ngược lại, Static Access Key:

* Là khóa cố định.
* Có nguy cơ bị lộ hoặc bị sử dụng trái phép.
* Cần thay đổi (rotate) định kỳ.
* Khó quản lý hơn khi có nhiều repository hoặc nhiều môi trường.
