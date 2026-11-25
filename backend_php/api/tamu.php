<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $search = trim($_GET['search'] ?? '');
    $kategori = trim($_GET['kategori'] ?? '');
    $konfirmasi = trim($_GET['konfirmasi'] ?? '');

    $query = "SELECT * FROM daftar_tamu WHERE user_id = ?";
    $params = [$userId];

    if (!empty($search)) {
        $query .= " AND (nama_tamu LIKE ? OR nomor_telepon LIKE ? OR alamat LIKE ?)";
        $like = "%" . $search . "%";
        $params[] = $like;
        $params[] = $like;
        $params[] = $like;
    }

    if (!empty($kategori) && $kategori !== 'Semua') {
        $query .= " AND kategori = ?";
        $params[] = $kategori;
    }

    if (!empty($konfirmasi) && $konfirmasi !== 'Semua') {
        $query .= " AND konfirmasi_kehadiran = ?";
        $params[] = $konfirmasi;
    }

    $query .= " ORDER BY nama_tamu ASC";
    $stmt = $db->prepare($query);
    $stmt->execute($params);
    $items = $stmt->fetchAll();

    // Summary statistics
    $sum = $db->prepare("SELECT 
        COUNT(*) AS total_undangan,
        COALESCE(SUM(jumlah_orang), 0) AS total_tamu,
        COALESCE(SUM(CASE WHEN konfirmasi_kehadiran = 'Hadir' THEN jumlah_orang ELSE 0 END), 0) AS total_hadir,
        COALESCE(SUM(CASE WHEN konfirmasi_kehadiran = 'Tidak Hadir' THEN jumlah_orang ELSE 0 END), 0) AS total_tidak_hadir,
        COALESCE(SUM(CASE WHEN konfirmasi_kehadiran = 'Belum Konfirmasi' THEN jumlah_orang ELSE 0 END), 0) AS total_belum_konfirmasi,
        COALESCE(SUM(CASE WHEN status_undangan = 'Sudah Diundang' THEN 1 ELSE 0 END), 0) AS total_terundang
        FROM daftar_tamu WHERE user_id = ?");
    $sum->execute([$userId]);
    $summary = $sum->fetch();

    jsonResponse(true, "Daftar tamu berhasil diambil.", [
        "items" => $items,
        "summary" => $summary
    ]);
} elseif ($method === 'POST') {
    $data = getRequestData();
    $nama = trim($data['nama_tamu'] ?? '');
    $telepon = trim($data['nomor_telepon'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Keluarga');
    $jumlah = max(1, (int)($data['jumlah_orang'] ?? 1));
    $alamat = trim($data['alamat'] ?? '');
    $statusUndangan = trim($data['status_undangan'] ?? 'Belum Diundang');
    $konfirmasi = trim($data['konfirmasi_kehadiran'] ?? 'Belum Konfirmasi');

    if (empty($nama)) {
        jsonResponse(false, "Nama tamu wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("INSERT INTO daftar_tamu (user_id, nama_tamu, nomor_telepon, kategori, jumlah_orang, alamat, status_undangan, konfirmasi_kehadiran) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$userId, $nama, $telepon, $kategori, $jumlah, $alamat, $statusUndangan, $konfirmasi]);
    $newId = (int)$db->lastInsertId();

    $fetch = $db->prepare("SELECT * FROM daftar_tamu WHERE id = ?");
    $fetch->execute([$newId]);

    jsonResponse(true, "Tamu berhasil ditambahkan.", $fetch->fetch(), 201);
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID tamu tidak valid.", null, 400);
    }

    $nama = trim($data['nama_tamu'] ?? '');
    $telepon = trim($data['nomor_telepon'] ?? '');
    $kategori = trim($data['kategori'] ?? 'Keluarga');
    $jumlah = max(1, (int)($data['jumlah_orang'] ?? 1));
    $alamat = trim($data['alamat'] ?? '');
    $statusUndangan = trim($data['status_undangan'] ?? 'Belum Diundang');
    $konfirmasi = trim($data['konfirmasi_kehadiran'] ?? 'Belum Konfirmasi');

    if (empty($nama)) {
        jsonResponse(false, "Nama tamu wajib diisi.", null, 400);
    }

    $stmt = $db->prepare("UPDATE daftar_tamu SET nama_tamu = ?, nomor_telepon = ?, kategori = ?, jumlah_orang = ?, alamat = ?, status_undangan = ?, konfirmasi_kehadiran = ? WHERE id = ? AND user_id = ?");
    $stmt->execute([$nama, $telepon, $kategori, $jumlah, $alamat, $statusUndangan, $konfirmasi, $id, $userId]);

    $fetch = $db->prepare("SELECT * FROM daftar_tamu WHERE id = ?");
    $fetch->execute([$id]);

    jsonResponse(true, "Data tamu berhasil diperbarui.", $fetch->fetch());
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID tamu tidak valid.", null, 400);
    }

    $stmt = $db->prepare("DELETE FROM daftar_tamu WHERE id = ? AND user_id = ?");
    $stmt->execute([$id, $userId]);

    jsonResponse(true, "Tamu berhasil dihapus.", ["id" => $id]);
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
