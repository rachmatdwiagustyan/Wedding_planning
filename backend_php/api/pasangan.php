<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $db->prepare("SELECT * FROM pasangan WHERE user_id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $pasangan = $stmt->fetch();
    jsonResponse(true, "Data pasangan berhasil diambil.", $pasangan ?: null);
} elseif ($method === 'POST' || $method === 'PUT') {
    $data = getRequestData();
    $namaWanita = trim($data['nama_wanita'] ?? '');
    $namaPria = trim($data['nama_pria'] ?? '');
    $fotoPasangan = trim($data['foto_pasangan'] ?? '');
    $tanggalPernikahan = trim($data['tanggal_pernikahan'] ?? '');
    $lokasiPernikahan = trim($data['lokasi_pernikahan'] ?? '');
    $alamatAcara = trim($data['alamat_acara'] ?? '');

    if (empty($namaWanita) || empty($namaPria) || empty($tanggalPernikahan) || empty($lokasiPernikahan)) {
        jsonResponse(false, "Harap lengkapi nama calon pengantin, tanggal, dan lokasi pernikahan.", null, 400);
    }

    // Cek apakah data pasangan sudah ada
    $check = $db->prepare("SELECT id FROM pasangan WHERE user_id = ? LIMIT 1");
    $check->execute([$userId]);
    $existing = $check->fetch();

    if ($existing) {
        $update = $db->prepare("UPDATE pasangan SET nama_wanita = ?, nama_pria = ?, foto_pasangan = ?, tanggal_pernikahan = ?, lokasi_pernikahan = ?, alamat_acara = ? WHERE user_id = ?");
        $update->execute([$namaWanita, $namaPria, $fotoPasangan, $tanggalPernikahan, $lokasiPernikahan, $alamatAcara, $userId]);
        $pasanganId = $existing['id'];
        $message = "Identitas pasangan berhasil diperbarui.";
    } else {
        $insert = $db->prepare("INSERT INTO pasangan (user_id, nama_wanita, nama_pria, foto_pasangan, tanggal_pernikahan, lokasi_pernikahan, alamat_acara) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $insert->execute([$userId, $namaWanita, $namaPria, $fotoPasangan, $tanggalPernikahan, $lokasiPernikahan, $alamatAcara]);
        $pasanganId = (int)$db->lastInsertId();
        $message = "Identitas pasangan berhasil disimpan.";
    }

    $stmt = $db->prepare("SELECT * FROM pasangan WHERE id = ?");
    $stmt->execute([$pasanganId]);
    $result = $stmt->fetch();

    jsonResponse(true, $message, $result);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
