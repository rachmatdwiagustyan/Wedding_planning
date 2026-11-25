-- ==============================================================
-- DATABASE TALENTA EVENT ORGANIZER
-- Tagline: "Every Moment, Beautifully Planned."
-- ==============================================================

CREATE DATABASE IF NOT EXISTS `talenta_event_organizer` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `talenta_event_organizer`;

-- 1. Tabel users
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `nama_lengkap` VARCHAR(150) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `foto` VARCHAR(255) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabel pasangan
CREATE TABLE IF NOT EXISTS `pasangan` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nama_wanita` VARCHAR(150) NOT NULL,
    `nama_pria` VARCHAR(150) NOT NULL,
    `foto_pasangan` VARCHAR(255) NULL,
    `tanggal_pernikahan` DATE NOT NULL,
    `lokasi_pernikahan` VARCHAR(150) NOT NULL,
    `alamat_acara` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_pasangan_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabel anggaran
CREATE TABLE IF NOT EXISTS `anggaran` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `kategori` VARCHAR(100) NOT NULL,
    `nama_kebutuhan` VARCHAR(200) NOT NULL,
    `nama_vendor` VARCHAR(200) NULL DEFAULT '',
    `estimasi_biaya` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `biaya_aktual` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `status_pembayaran` VARCHAR(50) DEFAULT 'Belum Dibayar',
    `penanggung_jawab` VARCHAR(100) DEFAULT 'Keduanya',
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_anggaran_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabel daftar_kebutuhan
CREATE TABLE IF NOT EXISTS `daftar_kebutuhan` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nama_barang` VARCHAR(200) NOT NULL,
    `kategori` VARCHAR(100) NOT NULL,
    `jumlah` INT NOT NULL DEFAULT 1,
    `harga_satuan` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `total_harga` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `penanggung_jawab` ENUM('Calon Pengantin Wanita', 'Calon Pengantin Pria', 'Keduanya') DEFAULT 'Keduanya',
    `status_pembelian` ENUM('Belum Dibeli', 'Sudah Dibeli') DEFAULT 'Belum Dibeli',
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_kebutuhan_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabel perbandingan_anggaran
CREATE TABLE IF NOT EXISTS `perbandingan_anggaran` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nama_kebutuhan` VARCHAR(200) NOT NULL,
    `nama_vendor` VARCHAR(200) NOT NULL,
    `harga_penawaran` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `estimasi_biaya` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `harga_aktual` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `selisih_harga` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_perbandingan_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Tabel dokumen_administrasi
CREATE TABLE IF NOT EXISTS `dokumen_administrasi` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nomor_dokumen` INT NOT NULL DEFAULT 1,
    `nama_dokumen` VARCHAR(255) NOT NULL,
    `penanggung_jawab` ENUM('Calon Pengantin Wanita', 'Calon Pengantin Pria', 'Keduanya') DEFAULT 'Keduanya',
    `status_kelengkapan` VARCHAR(50) DEFAULT 'Belum Disiapkan',
    `tanggal_disiapkan` DATE NULL,
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_dokumen_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Tabel jadwal_kegiatan
CREATE TABLE IF NOT EXISTS `jadwal_kegiatan` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nama_kegiatan` VARCHAR(200) NOT NULL,
    `tanggal` DATE NOT NULL,
    `jam_mulai` TIME NOT NULL,
    `jam_selesai` TIME NOT NULL,
    `lokasi` VARCHAR(255) NOT NULL,
    `penanggung_jawab` ENUM('Calon Pengantin Wanita', 'Calon Pengantin Pria', 'Keduanya') DEFAULT 'Keduanya',
    `status_selesai` TINYINT(1) DEFAULT 0,
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_jadwal_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Tabel daftar_tamu
CREATE TABLE IF NOT EXISTS `daftar_tamu` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nama_tamu` VARCHAR(200) NOT NULL,
    `nomor_telepon` VARCHAR(50) NULL,
    `kategori` VARCHAR(100) NOT NULL DEFAULT 'Keluarga',
    `jumlah_orang` INT NOT NULL DEFAULT 1,
    `alamat` TEXT NULL,
    `status_undangan` ENUM('Belum Diundang', 'Sudah Diundang') DEFAULT 'Belum Diundang',
    `konfirmasi_kehadiran` ENUM('Belum Konfirmasi', 'Hadir', 'Tidak Hadir') DEFAULT 'Belum Konfirmasi',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_tamu_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Tabel vendor
CREATE TABLE IF NOT EXISTS `vendor` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nama_vendor` VARCHAR(200) NOT NULL,
    `kategori` VARCHAR(100) NOT NULL,
    `nomor_telepon` VARCHAR(50) NULL,
    `alamat` TEXT NULL,
    `harga_penawaran` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `status_pemesanan` VARCHAR(50) DEFAULT 'Belum Dipesan',
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_vendor_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Tabel tugas_pernikahan
CREATE TABLE IF NOT EXISTS `tugas_pernikahan` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `nama_tugas` VARCHAR(255) NOT NULL,
    `kategori` VARCHAR(100) NOT NULL,
    `tenggat_waktu` DATE NOT NULL,
    `penanggung_jawab` ENUM('Calon Pengantin Wanita', 'Calon Pengantin Pria', 'Keduanya') DEFAULT 'Keduanya',
    `status` VARCHAR(50) DEFAULT 'Belum Selesai',
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_tugas_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Tabel catatan
CREATE TABLE IF NOT EXISTS `catatan` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `judul` VARCHAR(200) NOT NULL,
    `isi` TEXT NOT NULL,
    `kategori` VARCHAR(100) NOT NULL DEFAULT 'Umum',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_catatan_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Tabel pengingat
CREATE TABLE IF NOT EXISTS `pengingat` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `judul` VARCHAR(255) NOT NULL,
    `tipe` VARCHAR(100) NOT NULL DEFAULT 'Tenggat Waktu',
    `tanggal_pengingat` DATE NOT NULL,
    `jam_pengingat` TIME NOT NULL DEFAULT '08:00:00',
    `status` ENUM('Aktif', 'Selesai') DEFAULT 'Aktif',
    `catatan` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_pengingat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
