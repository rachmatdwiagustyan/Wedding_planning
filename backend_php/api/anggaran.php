<?php
require_once __DIR__ . '/../config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    $userId = getAuthUserId();
    $method = $_SERVER['REQUEST_METHOD'];

    // Pastikan kolom nama_vendor ada pada tabel anggaran
    try {
        $checkCol = $db->query("SHOW COLUMNS FROM `anggaran` LIKE 'nama_vendor'");
        if ($checkCol->rowCount() === 0) {
            $db->exec("ALTER TABLE `anggaran` ADD COLUMN `nama_vendor` VARCHAR(200) NULL DEFAULT '' AFTER `nama_kebutuhan`");
        }
    } catch (Throwable $ignored) {}

    if ($method === 'GET') {
        // Ambil single data jika id disertakan
        if (isset($_GET['id'])) {
            $stmt = $db->prepare("SELECT * FROM anggaran WHERE id = ? AND user_id = ?");
            $stmt->execute([(int)$_GET['id'], $userId]);
            $item = $stmt->fetch();
            if (!$item) {
                jsonResponse(false, "Data anggaran tidak ditemukan.", null, 404);
            }
            jsonResponse(true, "Data anggaran berhasil diambil.", $item);
        } else {
            $kategori = trim($_GET['kategori'] ?? '');
            if (!empty($kategori) && $kategori !== 'Semua') {
                $stmt = $db->prepare("SELECT * FROM anggaran WHERE user_id = ? AND kategori = ? ORDER BY id DESC");
                $stmt->execute([$userId, $kategori]);
            } else {
                $stmt = $db->prepare("SELECT * FROM anggaran WHERE user_id = ? ORDER BY id DESC");
                $stmt->execute([$userId]);
            }
            $list = $stmt->fetchAll();

            // Hitung ringkasan total estimasi dan aktual untuk user ini
            $sumStmt = $db->prepare("SELECT 
                COALESCE(SUM(estimasi_biaya), 0) AS total_estimasi,
                COALESCE(SUM(biaya_aktual), 0) AS total_aktual
                FROM anggaran WHERE user_id = ?");
            $sumStmt->execute([$userId]);
            $summary = $sumStmt->fetch();
            $totalEstimasi = (float)($summary['total_estimasi'] ?? 0);
            $totalAktual = (float)($summary['total_aktual'] ?? 0);

            jsonResponse(true, "Daftar anggaran berhasil diambil.", [
                "items" => $list,
                "total_estimasi" => $totalEstimasi,
                "total_aktual" => $totalAktual,
                "selisih" => $totalEstimasi - $totalAktual
            ]);
        }
    } elseif ($method === 'POST') {
        $data = getRequestData();
        $kategori = trim($data['kategori'] ?? 'Lainnya');
        $namaKebutuhan = trim($data['nama_kebutuhan'] ?? '');
        $namaVendor = trim($data['nama_vendor'] ?? '');
        $estimasi = (float)($data['estimasi_biaya'] ?? 0);
        $aktual = (float)($data['biaya_aktual'] ?? 0);
        $status = trim($data['status_pembayaran'] ?? 'Belum Dibayar');
        $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
        $catatan = trim($data['catatan'] ?? '');

        if (empty($namaKebutuhan)) {
            jsonResponse(false, "Nama kebutuhan wajib diisi.", null, 400);
        }

        $stmt = $db->prepare("INSERT INTO anggaran (user_id, kategori, nama_kebutuhan, nama_vendor, estimasi_biaya, biaya_aktual, status_pembayaran, penanggung_jawab, catatan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$userId, $kategori, $namaKebutuhan, $namaVendor, $estimasi, $aktual, $status, $pj, $catatan]);
        $newId = (int)$db->lastInsertId();

        $fetch = $db->prepare("SELECT * FROM anggaran WHERE id = ?");
        $fetch->execute([$newId]);

        jsonResponse(true, "Anggaran berhasil ditambahkan.", $fetch->fetch(), 201);
    } elseif ($method === 'PUT') {
        $data = getRequestData();
        $id = (int)($data['id'] ?? 0);
        if ($id <= 0) {
            jsonResponse(false, "ID anggaran tidak valid.", null, 400);
        }

        $kategori = trim($data['kategori'] ?? 'Lainnya');
        $namaKebutuhan = trim($data['nama_kebutuhan'] ?? '');
        $namaVendor = trim($data['nama_vendor'] ?? '');
        $estimasi = (float)($data['estimasi_biaya'] ?? 0);
        $aktual = (float)($data['biaya_aktual'] ?? 0);
        $status = trim($data['status_pembayaran'] ?? 'Belum Dibayar');
        $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
        $catatan = trim($data['catatan'] ?? '');

        if (empty($namaKebutuhan)) {
            jsonResponse(false, "Nama kebutuhan wajib diisi.", null, 400);
        }

        $stmt = $db->prepare("UPDATE anggaran SET kategori = ?, nama_kebutuhan = ?, nama_vendor = ?, estimasi_biaya = ?, biaya_aktual = ?, status_pembayaran = ?, penanggung_jawab = ?, catatan = ? WHERE id = ? AND user_id = ?");
        $stmt->execute([$kategori, $namaKebutuhan, $namaVendor, $estimasi, $aktual, $status, $pj, $catatan, $id, $userId]);

        $fetch = $db->prepare("SELECT * FROM anggaran WHERE id = ?");
        $fetch->execute([$id]);

        jsonResponse(true, "Anggaran berhasil diperbarui.", $fetch->fetch());
    } elseif ($method === 'DELETE') {
        $data = getRequestData();
        $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
        if ($id <= 0) {
            jsonResponse(false, "ID anggaran tidak valid.", null, 400);
        }

        $stmt = $db->prepare("DELETE FROM anggaran WHERE id = ? AND user_id = ?");
        $stmt->execute([$id, $userId]);

        jsonResponse(true, "Anggaran berhasil dihapus.", ["id" => $id]);
    } else {
        jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
    }
} catch (Throwable $e) {
    jsonResponse(false, "Terjadi kesalahan pada server: " . $e->getMessage(), null, 500);
}
