<?php
require_once __DIR__ . '/../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    $userId = getAuthUserId();
    $method = $_SERVER['REQUEST_METHOD'];

    if ($method === 'GET') {
        $stmt = $db->prepare("SELECT * FROM perbandingan_anggaran WHERE user_id = ? ORDER BY nama_kebutuhan ASC, harga_penawaran ASC");
        $stmt->execute([$userId]);
        $items = $stmt->fetchAll();

        // Summary comparison
        $sum = $db->prepare("SELECT 
            COUNT(*) AS total_perbandingan,
            COALESCE(AVG(harga_penawaran), 0) AS rata_penawaran,
            COALESCE(MIN(harga_penawaran), 0) AS termurah,
            COALESCE(MAX(harga_penawaran), 0) AS termahal
            FROM perbandingan_anggaran WHERE user_id = ?");
        $sum->execute([$userId]);
        $summary = $sum->fetch();

        jsonResponse(true, "Data perbandingan berhasil diambil.", [
            "items" => $items,
            "summary" => $summary
        ]);
    } elseif ($method === 'POST') {
        $data = getRequestData();
        $namaKebutuhan = trim($data['nama_kebutuhan'] ?? '');
        $namaVendor = trim($data['nama_vendor'] ?? '');
        $penawaran = (float)($data['harga_penawaran'] ?? 0);
        $estimasi = (float)($data['estimasi_biaya'] ?? 0);
        $aktual = (float)($data['harga_aktual'] ?? 0);
        $selisih = $estimasi - $penawaran; // Selisih estimasi vs penawaran
        $catatan = trim($data['catatan'] ?? '');

        if (empty($namaKebutuhan) || empty($namaVendor)) {
            jsonResponse(false, "Nama kebutuhan dan nama vendor wajib diisi.", null, 400);
        }

        $stmt = $db->prepare("INSERT INTO perbandingan_anggaran (user_id, nama_kebutuhan, nama_vendor, harga_penawaran, estimasi_biaya, harga_aktual, selisih_harga, catatan) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$userId, $namaKebutuhan, $namaVendor, $penawaran, $estimasi, $aktual, $selisih, $catatan]);
        $newId = (int)$db->lastInsertId();

        $fetch = $db->prepare("SELECT * FROM perbandingan_anggaran WHERE id = ?");
        $fetch->execute([$newId]);

        jsonResponse(true, "Perbandingan harga berhasil ditambahkan.", $fetch->fetch(), 201);
    } elseif ($method === 'PUT') {
        $data = getRequestData();
        $id = (int)($data['id'] ?? 0);
        if ($id <= 0) {
            jsonResponse(false, "ID perbandingan tidak valid.", null, 400);
        }

        $namaKebutuhan = trim($data['nama_kebutuhan'] ?? '');
        $namaVendor = trim($data['nama_vendor'] ?? '');
        $penawaran = (float)($data['harga_penawaran'] ?? 0);
        $estimasi = (float)($data['estimasi_biaya'] ?? 0);
        $aktual = (float)($data['harga_aktual'] ?? 0);
        $selisih = $estimasi - $penawaran;
        $catatan = trim($data['catatan'] ?? '');

        if (empty($namaKebutuhan) || empty($namaVendor)) {
            jsonResponse(false, "Nama kebutuhan dan nama vendor wajib diisi.", null, 400);
        }

        $stmt = $db->prepare("UPDATE perbandingan_anggaran SET nama_kebutuhan = ?, nama_vendor = ?, harga_penawaran = ?, estimasi_biaya = ?, harga_aktual = ?, selisih_harga = ?, catatan = ? WHERE id = ? AND user_id = ?");
        $stmt->execute([$namaKebutuhan, $namaVendor, $penawaran, $estimasi, $aktual, $selisih, $catatan, $id, $userId]);

        $fetch = $db->prepare("SELECT * FROM perbandingan_anggaran WHERE id = ?");
        $fetch->execute([$id]);

        jsonResponse(true, "Perbandingan harga berhasil diperbarui.", $fetch->fetch());
    } elseif ($method === 'DELETE') {
        $data = getRequestData();
        $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
        if ($id <= 0) {
            jsonResponse(false, "ID perbandingan tidak valid.", null, 400);
        }

        $stmt = $db->prepare("DELETE FROM perbandingan_anggaran WHERE id = ? AND user_id = ?");
        $stmt->execute([$id, $userId]);

        jsonResponse(true, "Perbandingan harga berhasil dihapus.", ["id" => $id]);
    } else {
        jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
    }
} catch (Throwable $e) {
    jsonResponse(false, "Terjadi kesalahan pada server: " . $e->getMessage(), null, 500);
}
