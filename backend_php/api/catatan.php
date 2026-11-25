<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $kategori = trim($_GET['kategori'] ?? '');
    if (!empty($kategori) && $kategori !== 'Semua') {
        $stmt = $db->prepare("SELECT * FROM catatan WHERE user_id = ? AND kategori = ? ORDER BY created_at DESC");
        $stmt->execute([$userId, $kategori]);
    } else {
        $stmt = $db->prepare("SELECT * FROM catatan WHERE user_id = ? ORDER BY created_at DESC");
        $stmt->execute([$userId]);
    }
    $items = $stmt->fetchAll();

    jsonResponse(true, "Daftar catatan berhasil diambil.", $items);
} elseif ($method === 'POST') {
    $data = getRequestData();
    $judul = trim($data['judul'] ?? '');
    $isi = trim($data['isi'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Umum');

    if (empty($judul) || empty($isi)) {
        jsonResponse(false, "Judul dan isi catatan wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO catatan (user_id, judul, isi, kategori) VALUES (?, ?, ?, ?)");
    $stmt->execute([$userId, $judul, $isi, $kategori]);
    $newId = (int)$db->lastInsertId();

    $fetch = $db->prepare("SELECT * FROM catatan WHERE id = ?");
    $fetch->execute([$newId]);

    jsonResponse(true, "Catatan berhasil ditambahkan.", $fetch->fetch(), 201);
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID catatan tidak valid.", null, 400);
    }

    $judul = trim($data['judul'] ?? '');
    $isi = trim($data['isi'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Umum');

    if (empty($judul) || empty($isi)) {
        jsonResponse(false, "Judul dan isi catatan wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("UPDATE catatan SET judul = ?, isi = ?, kategori = ? WHERE id = ? AND user_id = ?");
    $stmt->execute([$judul, $isi, $kategori, $id, $userId]);

    $fetch = $db->prepare("SELECT * FROM catatan WHERE id = ?");
    $fetch->execute([$id]);

    jsonResponse(true, "Catatan berhasil diperbarui.", $fetch->fetch());
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID catatan tidak valid.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM catatan WHERE id = ? AND user_id = ?");
    $stmt->execute([$id, $userId]);

    jsonResponse(true, "Catatan berhasil dihapus.", ["id" => $id]);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
