<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$data = getRequestData();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, "Metode HTTP tidak diizinkan. Gunakan POST.", null, 405);
}

$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');

if (empty($email) || empty($password)) {
    jsonResponse(false, "Email dan kata sandi wajib diisi.", null, 400);
}

$stmt = $db->prepare("SELECT id, nama_lengkap, email, password, foto FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password'])) {
    jsonResponse(false, "Email atau kata sandi salah. Silakan coba lagi.", null, 401);
}

// Cek apakah data pasangan sudah diisi
$pasanganStmt = $db->prepare("SELECT * FROM pasangan WHERE user_id = ? LIMIT 1");
$pasanganStmt->execute([$user['id']]);
$pasangan = $pasanganStmt->fetch();

// Pastikan dokumen administrasi default terisi
seedDefaultDocuments($db, (int)$user['id']);

// Sediakan token autentikasi yang dapat didecode oleh getAuthUserId
$token = base64_encode($user['id'] . ":" . time() . ":" . bin2hex(random_bytes(16)));

jsonResponse(true, "Login berhasil. Selamat datang di TALENTA EVENT ORGANIZER!", [
    "token" => $token,
    "user" => [
        "id" => (int)$user['id'],
        "nama_lengkap" => $user['nama_lengkap'],
        "email" => $user['email'],
        "foto" => $user['foto']
    ],
    "has_pasangan" => $pasangan ? true : false,
    "pasangan" => $pasangan ?: null
]);
