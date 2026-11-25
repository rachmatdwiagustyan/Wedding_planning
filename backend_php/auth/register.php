<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$data = getRequestData();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, "Metode HTTP tidak diizinkan. Gunakan POST.", null, 405);
}

$nama = trim($data['nama_lengkap'] ?? '');
$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');
$konfirmasi = trim($data['konfirmasi_password'] ?? '');

if (empty($nama) || empty($email) || empty($password)) {
    jsonResponse(false, "Harap lengkapi semua kolom pendaftaran.", null, 400);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(false, "Format alamat email tidak valid.", null, 400);
}

if (strlen($password) < 6) {
    jsonResponse(false, "Kata sandi minimal harus 6 karakter.", null, 400);
}

if (!empty($konfirmasi) && $password !== $konfirmasi) {
    jsonResponse(false, "Konfirmasi kata sandi tidak cocok.", null, 400);
}

// Cek apakah email sudah terdaftar
$checkStmt = $db->prepare("SELECT id FROM users WHERE email = ?");
$checkStmt->execute([$email]);
if ($checkStmt->fetch()) {
    jsonResponse(false, "Email sudah terdaftar. Silakan gunakan email lain atau login.", null, 409);
}

$hashedPassword = password_hash($password, PASSWORD_BCRYPT);
$insertStmt = $db->prepare("INSERT INTO users (nama_lengkap, email, password) VALUES (?, ?, ?)");

try {
    $insertStmt->execute([$nama, $email, $hashedPassword]);
    $userId = (int)$db->lastInsertId();

    // Otomatis masukkan 18 dokumen administrasi standar untuk akun baru
    seedDefaultDocuments($db, $userId);

    // Otomatis masukkan vendor contoh bawaan per kategori untuk akun baru
    seedDefaultVendors($db, $userId);

    // Otomatis buat pengingat awal
    try {
        $initPengingat = $db->prepare("INSERT INTO pengingat (user_id, judul, tipe, tanggal_pengingat, jam_pengingat, catatan) VALUES (?, ?, ?, CURDATE() + INTERVAL 30 DAY, '09:00:00', ?)");
        $initPengingat->execute([$userId, "Lengkapi Berkas KUA & Administrasi", "Administrasi", "Pastikan seluruh dokumen N1-N5 dan KTP saksi sudah disiapkan."]);
    } catch (Exception $e) {}

    jsonResponse(true, "Registrasi berhasil! Silakan masuk menggunakan akun baru Anda.", [
        "user" => [
            "id" => $userId,
            "nama_lengkap" => $nama,
            "email" => $email
        ]
    ], 201);
} catch (PDOException $e) {
    if ($e->getCode() == 23000 || strpos($e->getMessage(), 'Duplicate entry') !== false) {
        jsonResponse(false, "Email sudah terdaftar. Silakan gunakan email lain atau login.", null, 409);
    } else {
        jsonResponse(false, "Pendaftaran akun gagal. Silakan periksa kembali data Anda atau coba beberapa saat lagi.", null, 500);
    }
}
