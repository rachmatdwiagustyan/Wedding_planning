<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Ambil data user beserta pasangan
    $stmt = $db->prepare("SELECT id, nama_lengkap, email, foto, created_at FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonResponse(false, "Pengguna tidak ditemukan.", null, 404);
    }

    $pStmt = $db->prepare("SELECT * FROM pasangan WHERE user_id = ? LIMIT 1");
    $pStmt->execute([$userId]);
    $pasangan = $pStmt->fetch();

    jsonResponse(true, "Data profil berhasil dimuat.", [
        "user" => $user,
        "pasangan" => $pasangan ?: null
    ]);
} elseif ($method === 'POST' || $method === 'PUT') {
    $data = getRequestData();
    $nama = trim($data['nama_lengkap'] ?? '');
    $email = trim($data['email'] ?? '');
    $password = trim($data['password'] ?? '');
    $foto = trim($data['foto'] ?? '');

    if (empty($nama) || empty($email)) {
        jsonResponse(false, "Nama lengkap dan email tidak boleh kosong.", null, 400);
    }

    // Pastikan email tidak dipakai user lain
    $check = $db->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
    $check->execute([$email, $userId]);
    if ($check->fetch()) {
        jsonResponse(false, "Email sudah digunakan oleh akun lain.", null, 409);
    }

    if (!empty($password)) {
        if (strlen($password) < 6) {
            jsonResponse(false, "Kata sandi minimal 6 karakter.", null, 400);
        }
        $hashed = password_hash($password, PASSWORD_BCRYPT);
        $update = $db->prepare("UPDATE users SET nama_lengkap = ?, email = ?, password = ?, foto = ? WHERE id = ?");
        $update->execute([$nama, $email, $hashed, $foto, $userId]);
    } else {
        $update = $db->prepare("UPDATE users SET nama_lengkap = ?, email = ?, foto = ? WHERE id = ?");
        $update->execute([$nama, $email, $foto, $userId]);
    }

    // Ambil data terbaru
    $stmt = $db->prepare("SELECT id, nama_lengkap, email, foto FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $updatedUser = $stmt->fetch();

    jsonResponse(true, "Profil berhasil diperbarui.", ["user" => $updatedUser]);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
