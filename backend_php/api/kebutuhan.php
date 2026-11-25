<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $kategori = $_GET['kategori'] ?? null;
    if ($kategori && $kategori !== 'Semua') {
        $stmt = $db->prepare("SELECT * FROM daftar_kebutuhan WHERE user_id = ? AND kategori = ? ORDER BY created_at DESC");
        $stmt->execute([$userId, $kategori]);
    } else {
        $stmt = $db->prepare("SELECT * FROM daftar_kebutuhan WHERE user_id = ? ORDER BY created_at DESC");
        $stmt->execute([$userId]);
    }
    $items = $stmt->fetchAll();

    // Summary
    $sum = $db->prepare("SELECT 
        COUNT(*) AS total_item,
        COALESCE(SUM(total_harga), 0) AS grand_total,
        COALESCE(SUM(CASE WHEN status_pembelian = 'Sudah Dibeli' THEN 1 ELSE 0 END), 0) AS total_dibeli,
        COALESCE(SUM(CASE WHEN status_pembelian = 'Sudah Dibeli' THEN total_harga ELSE 0 END), 0) AS total_terbeli
        FROM daftar_kebutuhan WHERE user_id = ?");
    $sum->execute([$userId]);
    $summary = $sum->fetch();

    jsonResponse(true, "Daftar kebutuhan berhasil diambil.", [
        "items" => $items,
        "total_item" => (int)$summary['total_item'],
        "grand_total" => (float)$summary['grand_total'],
        "total_dibeli" => (int)$summary['total_dibeli'],
        "total_terbeli" => (float)$summary['total_terbeli']
    ]);
} elseif ($method === 'POST') {
    $data = getRequestData();
    $action = $data['action'] ?? '';

    // Check if toggle status action
    if ($action === 'toggle_status') {
        $id = (int)($data['id'] ?? 0);
        $status = trim($data['status_pembelian'] ?? 'Sudah Dibeli');
        $stmt = $db->prepare("UPDATE daftar_kebutuhan SET status_pembelian = ? WHERE id = ? AND user_id = ?");
        $stmt->execute([$status, $id, $userId]);
        jsonResponse(true, "Status kebutuhan berhasil diperbarui.", ["id" => $id, "status_pembelian" => $status]);
    }

    $nama = trim($data['nama_barang'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Umum');
    $jumlah = max(1, (int)($data['jumlah'] ?? 1));
    $hargaSatuan = (float)($data['harga_satuan'] ?? 0);
    $totalHarga = $jumlah * $hargaSatuan;
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = trim($data['status_pembelian'] ?? 'Belum Dibeli');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama barang wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO daftar_kebutuhan (user_id, nama_barang, kategori, jumlah, harga_satuan, total_harga, penanggung_jawab, status_pembelian, catatan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$userId, $nama, $kategori, $jumlah, $hargaSatuan, $totalHarga, $pj, $status, $catatan]);
    $newId = (int)$db->lastInsertId();

    $fetch = $db->prepare("SELECT * FROM daftar_kebutuhan WHERE id = ?");
    $fetch->execute([$newId]);

    jsonResponse(true, "Kebutuhan berhasil ditambahkan.", $fetch->fetch(), 201);
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID kebutuhan tidak valid.", null, 400);
    }

    $nama = trim($data['nama_barang'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Umum');
    $jumlah = max(1, (int)($data['jumlah'] ?? 1));
    $hargaSatuan = (float)($data['harga_satuan'] ?? 0);
    $totalHarga = $jumlah * $hargaSatuan;
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = trim($data['status_pembelian'] ?? 'Belum Dibeli');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama barang wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("UPDATE daftar_kebutuhan SET nama_barang = ?, kategori = ?, jumlah = ?, harga_satuan = ?, total_harga = ?, penanggung_jawab = ?, status_pembelian = ?, catatan = ? WHERE id = ? AND user_id = ?");
    $stmt->execute([$nama, $kategori, $jumlah, $hargaSatuan, $totalHarga, $pj, $status, $catatan, $id, $userId]);

    $fetch = $db->prepare("SELECT * FROM daftar_kebutuhan WHERE id = ?");
    $fetch->execute([$id]);

    jsonResponse(true, "Kebutuhan berhasil diperbarui.", $fetch->fetch());
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID kebutuhan tidak valid.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM daftar_kebutuhan WHERE id = ? AND user_id = ?");
    $stmt->execute([$id, $userId]);

    jsonResponse(true, "Kebutuhan berhasil dihapus.", ["id" => $id]);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
