<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $filterDate = $_GET['tanggal'] ?? null;
    if ($filterDate) {
        $stmt = $db->prepare("SELECT * FROM jadwal_kegiatan WHERE user_id = ? AND tanggal = ? ORDER BY jam_mulai ASC");
        $stmt->execute([$userId, $filterDate]);
    } else {
        $stmt = $db->prepare("SELECT * FROM jadwal_kegiatan WHERE user_id = ? ORDER BY tanggal ASC, jam_mulai ASC");
        $stmt->execute([$userId]);
    }
    $items = $stmt->fetchAll();

    jsonResponse(true, "Daftar jadwal kegiatan berhasil diambil.", $items);
} elseif ($method === 'POST') {
    $data = getRequestData();
    $action = $data['action'] ?? '';

    if ($action === 'toggle_status') {
        $id = (int)($data['id'] ?? 0);
        $status = (int)($data['status_selesai'] ?? 1);
        $stmt = $db->prepare("UPDATE jadwal_kegiatan SET status_selesai = ? WHERE id = ? AND user_id = ?");
        $stmt->execute([$status, $id, $userId]);
        jsonResponse(true, "Status jadwal berhasil diperbarui.", ["id" => $id, "status_selesai" => $status]);
    }

    $nama = trim($data['nama_kegiatan'] ?? '');
    $tanggal = trim($data['tanggal'] ?? '');
    $jamMulai = trim($data['jam_mulai'] ?? '09:00:00');
    $jamSelesai = trim($data['jam_selesai'] ?? '11:00:00');
    $lokasi = trim($data['lokasi'] ?? '');
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = (int)($data['status_selesai'] ?? 0);
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama) || empty($tanggal) || empty($lokasi)) {
        jsonResponse(false, "Nama kegiatan, tanggal, dan lokasi wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO jadwal_kegiatan (user_id, nama_kegiatan, tanggal, jam_mulai, jam_selesai, lokasi, penanggung_jawab, status_selesai, catatan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$userId, $nama, $tanggal, $jamMulai, $jamSelesai, $lokasi, $pj, $status, $catatan]);
    $newId = (int)$db->lastInsertId();

    $fetch = $db->prepare("SELECT * FROM jadwal_kegiatan WHERE id = ?");
    $fetch->execute([$newId]);

    jsonResponse(true, "Jadwal kegiatan berhasil ditambahkan.", $fetch->fetch(), 201);
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID jadwal tidak valid.", null, 400);
    }

    $nama = trim($data['nama_kegiatan'] ?? '');
    $tanggal = trim($data['tanggal'] ?? '');
    $jamMulai = trim($data['jam_mulai'] ?? '09:00:00');
    $jamSelesai = trim($data['jam_selesai'] ?? '11:00:00');
    $lokasi = trim($data['lokasi'] ?? '');
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = (int)($data['status_selesai'] ?? 0);
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama) || empty($tanggal) || empty($lokasi)) {
        jsonResponse(false, "Nama kegiatan, tanggal, dan lokasi wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("UPDATE jadwal_kegiatan SET nama_kegiatan = ?, tanggal = ?, jam_mulai = ?, jam_selesai = ?, lokasi = ?, penanggung_jawab = ?, status_selesai = ?, catatan = ? WHERE id = ? AND user_id = ?");
    $stmt->execute([$nama, $tanggal, $jamMulai, $jamSelesai, $lokasi, $pj, $status, $catatan, $id, $userId]);

    $fetch = $db->prepare("SELECT * FROM jadwal_kegiatan WHERE id = ?");
    $fetch->execute([$id]);

    jsonResponse(true, "Jadwal kegiatan berhasil diperbarui.", $fetch->fetch());
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID jadwal tidak valid.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM jadwal_kegiatan WHERE id = ? AND user_id = ?");
    $stmt->execute([$id, $userId]);

    jsonResponse(true, "Jadwal kegiatan berhasil dihapus.", ["id" => $id]);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
