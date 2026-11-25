<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $status = trim($_GET['status'] ?? '');
    if (!empty($status) && $status !== 'Semua') {
        $stmt = $db->prepare("SELECT * FROM pengingat WHERE user_id = ? AND status = ? ORDER BY tanggal_pengingat ASC, jam_pengingat ASC");
        $stmt->execute([$userId, $status]);
    } else {
        $stmt = $db->prepare("SELECT * FROM pengingat WHERE user_id = ? ORDER BY tanggal_pengingat ASC, jam_pengingat ASC");
        $stmt->execute([$userId]);
    }
    $items = $stmt->fetchAll();

    jsonResponse(true, "Daftar pengingat berhasil diambil.", $items);
} elseif ($method === 'POST') {
    $data = getRequestData();
    $action = $data['action'] ?? '';

    if ($action === 'toggle_status') {
        $id = (int)($data['id'] ?? 0);
        $status = trim($data['status'] ?? 'Selesai');
        $stmt = $db->prepare("UPDATE pengingat SET status = ? WHERE id = ? AND user_id = ?");
        $stmt->execute([$status, $id, $userId]);
        jsonResponse(true, "Status pengingat berhasil diperbarui.", ["id" => $id, "status" => $status]);
    }

    $judul = trim($data['judul'] ?? '');
    $tipe = trim($data['tipe'] ?? 'Umum');
    $tanggal = trim($data['tanggal_pengingat'] ?? date('Y-m-d'));
    $jam = trim($data['jam_pengingat'] ?? '08:00:00');
    $status = trim($data['status'] ?? 'Aktif');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($judul) || empty($tanggal)) {
        jsonResponse(false, "Judul dan tanggal pengingat wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO pengingat (user_id, judul, tipe, tanggal_pengingat, jam_pengingat, status, catatan) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$userId, $judul, $tipe, $tanggal, $jam, $status, $catatan]);
    $newId = (int)$db->lastInsertId();

    $fetch = $db->prepare("SELECT * FROM pengingat WHERE id = ?");
    $fetch->execute([$newId]);

    jsonResponse(true, "Pengingat berhasil ditambahkan.", $fetch->fetch(), 201);
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID pengingat tidak valid.", null, 400);
    }

    $judul = trim($data['judul'] ?? '');
    $tipe = trim($data['tipe'] ?? 'Umum');
    $tanggal = trim($data['tanggal_pengingat'] ?? date('Y-m-d'));
    $jam = trim($data['jam_pengingat'] ?? '08:00:00');
    $status = trim($data['status'] ?? 'Aktif');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($judul) || empty($tanggal)) {
        jsonResponse(false, "Judul dan tanggal pengingat wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("UPDATE pengingat SET judul = ?, tipe = ?, tanggal_pengingat = ?, jam_pengingat = ?, status = ?, catatan = ? WHERE id = ? AND user_id = ?");
    $stmt->execute([$judul, $tipe, $tanggal, $jam, $status, $catatan, $id, $userId]);

    $fetch = $db->prepare("SELECT * FROM pengingat WHERE id = ?");
    $fetch->execute([$id]);

    jsonResponse(true, "Pengingat berhasil diperbarui.", $fetch->fetch());
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID pengingat tidak valid.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM pengingat WHERE id = ? AND user_id = ?");
    $stmt->execute([$id, $userId]);

    jsonResponse(true, "Pengingat berhasil dihapus.", ["id" => $id]);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
