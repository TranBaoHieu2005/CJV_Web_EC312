-- migration_v1_schema.sql

-- Đặt charset và storage engine
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
-- Sử dụng engine InnoDB để hỗ trợ khóa ngoại (FOREIGN KEY)
-- ==================================================================================

-- 1. Bảng Người dùng (users) - [Lan Anh chịu trách nhiệm chính]
CREATE TABLE `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(15),
  `level_id` INT(11) DEFAULT 1, -- Liên kết với bảng membership_levels
  `points` INT(11) DEFAULT 0,    -- Điểm tích lũy hiện tại
  `is_admin` TINYINT(1) DEFAULT 0, -- 1: Admin, 0: User
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Bảng Phim (movies) - [Hiếu chịu trách nhiệm chính]
CREATE TABLE `movies` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `duration` INT(11), -- tính bằng phút
  `release_date` DATE,
  `end_date` DATE,     -- Ngày kết thúc chiếu
  `poster_url` VARCHAR(255),
  `trailer_url` VARCHAR(255),
  `rating` DECIMAL(2, 1) DEFAULT 0.0,
  `status` ENUM('now_showing', 'coming_soon', 'ended') DEFAULT 'coming_soon'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Bảng Rạp (cinemas) - [Hiếu chịu trách nhiệm chính]
CREATE TABLE `cinemas` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `address` VARCHAR(255),
  `city` VARCHAR(50) NOT NULL,
  `phone` VARCHAR(15)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Bảng Phòng chiếu (rooms) - [Hiếu chịu trách nhiệm chính]
CREATE TABLE `rooms` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `cinema_id` INT(11) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `capacity` INT(11) NOT NULL,
  `type` VARCHAR(50), -- Ví dụ: 2D, 3D, IMAX, VIP
  CONSTRAINT `fk_room_cinema` FOREIGN KEY (`cinema_id`) REFERENCES `cinemas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Bảng Suất chiếu (showtimes) - [Hân chịu trách nhiệm chính]
CREATE TABLE `showtimes` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `movie_id` INT(11) NOT NULL,
  `room_id` INT(11) NOT NULL,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NOT NULL,
  `price_base` DECIMAL(10, 0) NOT NULL, -- Giá vé cơ sở (chưa áp dụng khuyến mãi)
  CONSTRAINT `fk_showtime_movie` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`),
  CONSTRAINT `fk_showtime_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Bảng Đơn hàng (orders) - [Ngân chịu trách nhiệm chính]
CREATE TABLE `orders` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT(11), -- NULL nếu là khách vãng lai
  `total_amount` DECIMAL(10, 0) NOT NULL,
  `voucher_code` VARCHAR(50), -- Mã voucher được áp dụng
  `discount_amount` DECIMAL(10, 0) DEFAULT 0,
  `payment_method` VARCHAR(50), -- Ví dụ: VNPAY, MOMO, Cash
  `status` ENUM('pending', 'paid', 'canceled', 'refunded') NOT NULL DEFAULT 'pending',
  `order_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Bảng Chi tiết vé (tickets) - [Ngân chịu trách nhiệm chính]
CREATE TABLE `tickets` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT(11) NOT NULL,
  `showtime_id` INT(11) NOT NULL,
  `seat_code` VARCHAR(10) NOT NULL, -- Ví dụ: A1, B10
  `ticket_price` DECIMAL(10, 0) NOT NULL, -- Giá vé sau khi đã áp dụng khuyến mãi (nếu có)
  `type` VARCHAR(50), -- Ví dụ: Người lớn, Trẻ em, Sinh viên
  CONSTRAINT `fk_ticket_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_ticket_showtime` FOREIGN KEY (`showtime_id`) REFERENCES `showtimes` (`id`),
  UNIQUE KEY `unique_seat_showtime` (`showtime_id`, `seat_code`) -- Ghế không thể đặt trùng trong cùng 1 suất
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Bảng Voucher (vouchers) - [Lan Anh/Phương Nghi chịu trách nhiệm]
CREATE TABLE `vouchers` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(50) UNIQUE NOT NULL,
  `description` VARCHAR(255),
  `type` ENUM('percentage', 'fixed_amount', 'free_ticket') NOT NULL,
  `value` DECIMAL(10, 2) NOT NULL, -- Giá trị giảm (%, VNĐ, hoặc số lượng vé)
  `usage_limit` INT(11) DEFAULT 1, -- Giới hạn số lần sử dụng
  `expiry_date` DATE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bổ sung: Bảng phụ cho Thành viên và Khuyến mãi
-- 9. Bảng Cấp độ Thành viên (membership_levels)
CREATE TABLE `membership_levels` (
  `id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL,
  `min_points` INT(11) DEFAULT 0, -- Điểm tối thiểu để đạt cấp độ này
  `discount_rate` DECIMAL(4, 2) DEFAULT 0.00 -- % giảm giá cố định cho cấp độ
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Khôi phục trạng thái kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;