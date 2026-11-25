<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

// Pastikan vendor default ter-seed untuk user aktif
seedDefaultVendors($db, $userId);

if ($method === 'GET') {
    if (isset($_GET['id'])) {
        $id = (int)$_GET['id'];
        $stmt = $db->prepare("SELECT * FROM vendor WHERE id = ? AND (user_id = ? OR user_id = 0)");
        $stmt->execute([$id, $userId]);
        $item = $stmt->fetch();
        if (!$item) {
            jsonResponse(false, "Vendor tidak ditemukan.", null, 404);
        }
        jsonResponse(true, "Detail vendor berhasil diambil.", $item);
    } else {
        $kategori = trim($_GET['kategori'] ?? '');
        $search = trim($_GET['search'] ?? ($_GET['q'] ?? ''));
        $status = trim($_GET['status'] ?? '');

        $sql = "SELECT * FROM vendor WHERE user_id = ?";
        $params = [$userId];

        if (!empty($kategori) && $kategori !== 'Semua') {
            $sql .= " AND kategori = ?";
            $params[] = $kategori;
        }

        if (!empty($status) && $status !== 'Semua') {
            $sql .= " AND status_pemesanan = ?";
            $params[] = $status;
        }

        if (!empty($search)) {
            $sql .= " AND (nama_vendor LIKE ? OR alamat LIKE ? OR catatan LIKE ?)";
            $params[] = "%$search%";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }

        $sql .= " ORDER BY kategori ASC, harga_penawaran ASC, nama_vendor ASC";
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $items = $stmt->fetchAll();

        // Ambil data ringkasan vendor untuk user ini
        $sum = $db->prepare("SELECT 
            COUNT(*) AS total_vendor,
            COALESCE(SUM(CASE WHEN status_pemesanan IN ('Sudah Dipesan', 'Selesai', 'Lunas') THEN 1 ELSE 0 END), 0) AS total_dipesan,
            COALESCE(SUM(CASE WHEN status_pemesanan = 'Belum Dipesan' THEN 1 ELSE 0 END), 0) AS total_belum_dipesan,
            COALESCE(SUM(CASE WHEN status_pemesanan = 'Dibatalkan' THEN 1 ELSE 0 END), 0) AS total_dibatalkan,
            COALESCE(SUM(harga_penawaran), 0) AS total_nilai_penawaran,
            COALESCE(SUM(CASE WHEN status_pemesanan IN ('Sudah Dipesan', 'Selesai', 'Lunas') THEN harga_penawaran ELSE 0 END), 0) AS total_nilai_dipesan
            FROM vendor WHERE user_id = ?");
        $sum->execute([$userId]);
        $summary = $sum->fetch();

        // Ringkasan perbandingan harga per kategori
        $catStmt = $db->prepare("SELECT 
            kategori,
            COUNT(*) AS jumlah_vendor,
            MIN(harga_penawaran) AS harga_terendah,
            MAX(harga_penawaran) AS harga_tertinggi,
            AVG(harga_penawaran) AS harga_rata_rata
            FROM vendor WHERE user_id = ?
            GROUP BY kategori
            ORDER BY kategori ASC");
        $catStmt->execute([$userId]);
        $kategoriSummary = $catStmt->fetchAll();

        jsonResponse(true, "Daftar vendor berhasil diambil.", [
            "items" => $items,
            "summary" => $summary,
            "perbandingan_kategori" => $kategoriSummary
        ]);
    }
} elseif ($method === 'POST') {
    $data = getRequestData();
    $action = $data['action'] ?? ($_REQUEST['action'] ?? '');

    // Action ubah status pemesanan vendor (Belum Dipesan, Sudah Dipesan, Dibatalkan)
    if ($action === 'toggle_status' || $action === 'update_status') {
        $id = (int)($data['id'] ?? ($_REQUEST['id'] ?? 0));
        $newStatus = trim($data['status_pemesanan'] ?? ($data['status'] ?? 'Belum Dipesan'));

        if ($id <= 0) {
            jsonResponse(false, "ID vendor tidak valid.", null, 400);
        }

        try {
            $stmt = $db->prepare("UPDATE vendor SET status_pemesanan = ? WHERE id = ? AND (user_id = ? OR user_id = 0)");
            $stmt->execute([$newStatus, $id, $userId]);

            $fetch = $db->prepare("SELECT * FROM vendor WHERE id = ?");
            $fetch->execute([$id]);
            $updated = $fetch->fetch();

            jsonResponse(true, "Status vendor berhasil diperbarui.", $updated);
        } catch (Throwable $e) {
            jsonResponse(false, "Gagal memperbarui status vendor: " . $e->getMessage(), null, 500);
        }
    }

    $nama = trim($data['nama_vendor'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Lainnya');
    $telepon = trim($data['nomor_telepon'] ?? '');
    $alamat = trim($data['alamat'] ?? '');
    $harga = (float)($data['harga_penawaran'] ?? 0);
    $status = trim($data['status_pemesanan'] ?? 'Belum Dipesan');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama vendor wajib diisi.", null, 400);
    }

    try {
        $stmt = $db->prepare("INSERT INTO vendor (user_id, nama_vendor, kategori, nomor_telepon, alamat, harga_penawaran, status_pemesanan, catatan) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$userId, $nama, $kategori, $telepon, $alamat, $harga, $status, $catatan]);
        $newId = (int)$db->lastInsertId();

        $fetch = $db->prepare("SELECT * FROM vendor WHERE id = ?");
        $fetch->execute([$newId]);

        jsonResponse(true, "Vendor berhasil ditambahkan.", $fetch->fetch(), 201);
    } catch (Throwable $e) {
        jsonResponse(false, "Gagal menambahkan vendor: " . $e->getMessage(), null, 500);
    }
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID vendor tidak valid.", null, 400);
    }

    $nama = trim($data['nama_vendor'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Lainnya');
    $telepon = trim($data['nomor_telepon'] ?? '');
    $alamat = trim($data['alamat'] ?? '');
    $harga = (float)($data['harga_penawaran'] ?? 0);
    $status = trim($data['status_pemesanan'] ?? 'Belum Dipesan');
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama vendor wajib diisi.", null, 400);
    }

    try {
        $stmt = $db->prepare("UPDATE vendor SET nama_vendor = ?, kategori = ?, nomor_telepon = ?, alamat = ?, harga_penawaran = ?, status_pemesanan = ?, catatan = ? WHERE id = ? AND (user_id = ? OR user_id = 0)");
        $stmt->execute([$nama, $kategori, $telepon, $alamat, $harga, $status, $catatan, $id, $userId]);

        $fetch = $db->prepare("SELECT * FROM vendor WHERE id = ?");
        $fetch->execute([$id]);

        jsonResponse(true, "Vendor berhasil diperbarui.", $fetch->fetch());
    } catch (Throwable $e) {
        jsonResponse(false, "Gagal memperbarui vendor: " . $e->getMessage(), null, 500);
    }
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID vendor tidak valid.", null, 400);
    }

    try {
        $stmt = $db->prepare("DELETE FROM vendor WHERE id = ? AND (user_id = ? OR user_id = 0)");
        $stmt->execute([$id, $userId]);

        jsonResponse(true, "Vendor berhasil dihapus.", ["id" => $id]);
    } catch (Throwable $e) {
        jsonResponse(false, "Gagal menghapus vendor: " . $e->getMessage(), null, 500);
    }
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
