<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $status = trim($_GET['status'] ?? '');
    if (!empty($status) && $status !== 'Semua') {
        $stmt = $db->prepare("SELECT * FROM tugas_pernikahan WHERE user_id = ? AND status = ? ORDER BY tenggat_waktu ASC");
        $stmt->execute([$userId, $status]);
    } else {
        $stmt = $db->prepare("SELECT * FROM tugas_pernikahan WHERE user_id = ? ORDER BY tenggat_waktu ASC");
        $stmt->execute([$userId]);
    }
    $items = $stmt->fetchAll();

    // Summary
    $sum = $db->prepare("SELECT 
        COUNT(*) AS total_tugas,
        COALESCE(SUM(CASE WHEN status = 'Selesai' THEN 1 ELSE 0 END), 0) AS total_selesai,
        COALESCE(SUM(CASE WHEN status = 'Sedang Dikerjakan' THEN 1 ELSE 0 END), 0) AS total_proses,
        COALESCE(SUM(CASE WHEN status = 'Belum Selesai' THEN 1 ELSE 0 END), 0) AS total_belum
        FROM tugas_pernikahan WHERE user_id = ?");
    $sum->execute([$userId]);
    $summary = $sum->fetch();
    $total = (int)$summary['total_tugas'];
    $selesai = (int)$summary['total_selesai'];
    $persen = $total > 0 ? round(($selesai / $total) * 100) : 0;

    jsonResponse(true, "Daftar tugas berhasil diambil.", [
        "items" => $items,
        "total" => $total,
        "selesai" => $selesai,
        "proses" => (int)$summary['total_proses'],
        "belum" => (int)$summary['total_belum'],
        "persentase" => $persen
    ]);
} elseif ($method === 'POST') {
    $data = getRequestData();
    $action = $data['action'] ?? '';

    if ($action === 'toggle_status') {
        $id = (int)($data['id'] ?? 0);
        $status = trim($data['status'] ?? 'Selesai');
        $stmt = $db->prepare("UPDATE tugas_pernikahan SET status = ? WHERE id = ? AND user_id = ?");
        $stmt->execute([$status, $id, $userId]);
        jsonResponse(true, "Status tugas berhasil diperbarui.", ["id" => $id, "status" => $status]);
    }

    $nama = trim($data['nama_tugas'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Umum');
    $tenggat = trim($data['tenggat_waktu'] ?? date('Y-m-d'));
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = trim($data['status'] ?? 'Belum Selesai');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama tugas wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO tugas_pernikahan (user_id, nama_tugas, kategori, tenggat_waktu, penanggung_jawab, status, catatan) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$userId, $nama, $kategori, $tenggat, $pj, $status, $catatan]);
    $newId = (int)$db->lastInsertId();

    $fetch = $db->prepare("SELECT * FROM tugas_pernikahan WHERE id = ?");
    $fetch->execute([$newId]);

    jsonResponse(true, "Tugas berhasil ditambahkan.", $fetch->fetch(), 201);
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID tugas tidak valid.", null, 400);
    }

    $nama = trim($data['nama_tugas'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Umum');
    $tenggat = trim($data['tenggat_waktu'] ?? date('Y-m-d'));
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = trim($data['status'] ?? 'Belum Selesai');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama tugas wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("UPDATE tugas_pernikahan SET nama_tugas = ?, kategori = ?, tenggat_waktu = ?, penanggung_jawab = ?, status = ?, catatan = ? WHERE id = ? AND user_id = ?");
    $stmt->execute([$nama, $kategori, $tenggat, $pj, $status, $catatan, $id, $userId]);

    $fetch = $db->prepare("SELECT * FROM tugas_pernikahan WHERE id = ?");
    $fetch->execute([$id]);

    jsonResponse(true, "Tugas berhasil diperbarui.", $fetch->fetch());
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID tugas tidak valid.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM tugas_pernikahan WHERE id = ? AND user_id = ?");
    $stmt->execute([$id, $userId]);

    jsonResponse(true, "Tugas berhasil dihapus.", ["id" => $id]);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
