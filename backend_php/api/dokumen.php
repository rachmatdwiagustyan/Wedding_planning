<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();
$method = $_SERVER['REQUEST_METHOD'];

// Pastikan dokumen default ter-seed untuk user aktif
seedDefaultDocuments($db, $userId);

if ($method === 'GET') {
    $pj = $_GET['penanggung_jawab'] ?? null;
    if ($pj && $pj !== 'Semua') {
        $stmt = $db->prepare("SELECT * FROM dokumen_administrasi WHERE user_id = ? AND penanggung_jawab = ? ORDER BY nomor_dokumen ASC, id ASC");
        $stmt->execute([$userId, $pj]);
    } else {
        $stmt = $db->prepare("SELECT * FROM dokumen_administrasi WHERE user_id = ? ORDER BY nomor_dokumen ASC, id ASC");
        $stmt->execute([$userId]);
    }
    $items = $stmt->fetchAll();

    // Hitung ringkasan kelengkapan dokumen
    $sum = $db->prepare("SELECT 
        COUNT(*) AS total,
        COALESCE(SUM(CASE WHEN status_kelengkapan IN ('Sudah Lengkap', 'Sudah Disiapkan') THEN 1 ELSE 0 END), 0) AS selesai,
        COALESCE(SUM(CASE WHEN status_kelengkapan NOT IN ('Sudah Lengkap', 'Sudah Disiapkan') THEN 1 ELSE 0 END), 0) AS belum_selesai
        FROM dokumen_administrasi WHERE user_id = ?");
    $sum->execute([$userId]);
    $summary = $sum->fetch();
    $total = (int)$summary['total'];
    $selesai = (int)$summary['selesai'];
    $belumSelesai = (int)$summary['belum_selesai'];
    $persen = $total > 0 ? round(($selesai / $total) * 100, 2) : 0;

    jsonResponse(true, "Daftar dokumen berhasil diambil.", [
        "items" => $items,
        "total" => $total,
        "selesai" => $selesai,
        "belum_selesai" => $belumSelesai,
        "persentase" => $persen
    ]);
} elseif ($method === 'POST') {
    $data = getRequestData();
    $action = $data['action'] ?? ($_REQUEST['action'] ?? '');

    // Action toggle status checkbox dokumen
    if ($action === 'toggle_status') {
        $id = (int)($data['id'] ?? ($_REQUEST['id'] ?? 0));
        if ($id <= 0) {
            jsonResponse(false, "ID dokumen tidak valid.", null, 400);
        }

        $rawStatus = trim($data['status_kelengkapan'] ?? ($data['status'] ?? ''));
        $isComplete = in_array(strtolower($rawStatus), [
            'sudah disiapkan', 'sudah_disiapkan', 'sudah lengkap', 'sudah_lengkap', '1', 'true', 'selesai', 'lengkap'
        ]);
        $status = $isComplete ? 'Sudah Disiapkan' : 'Belum Disiapkan';
        $tgl = $isComplete ? date('Y-m-d') : null;

        try {
            // Cek apakah dokumen ini ada
            $chk = $db->prepare("SELECT * FROM dokumen_administrasi WHERE id = ?");
            $chk->execute([$id]);
            $doc = $chk->fetch();
            if (!$doc) {
                jsonResponse(false, "Dokumen dengan ID $id tidak ditemukan.", null, 404);
            }

            // Lakukan update status dokumen
            $stmt = $db->prepare("UPDATE dokumen_administrasi SET status_kelengkapan = ?, tanggal_disiapkan = ? WHERE id = ?");
            $stmt->execute([$status, $tgl, $id]);

            // Ambil summary terbaru untuk user dokumen ini
            $docUserId = !empty($doc['user_id']) ? (int)$doc['user_id'] : $userId;
            $sum = $db->prepare("SELECT 
                COUNT(*) AS total,
                COALESCE(SUM(CASE WHEN status_kelengkapan IN ('Sudah Lengkap', 'Sudah Disiapkan') THEN 1 ELSE 0 END), 0) AS selesai,
                COALESCE(SUM(CASE WHEN status_kelengkapan NOT IN ('Sudah Lengkap', 'Sudah Disiapkan') THEN 1 ELSE 0 END), 0) AS belum_selesai
                FROM dokumen_administrasi WHERE user_id = ?");
            $sum->execute([$docUserId]);
            $summary = $sum->fetch();
            $total = (int)$summary['total'];
            $selesai = (int)$summary['selesai'];
            $belumSelesai = (int)$summary['belum_selesai'];
            $persen = $total > 0 ? round(($selesai / $total) * 100, 2) : 0;

            jsonResponse(true, "Status dokumen berhasil diperbarui.", [
                "id" => $id,
                "status" => $status,
                "status_kelengkapan" => $status,
                "tanggal_disiapkan" => $tgl,
                "summary" => [
                    "total" => $total,
                    "selesai" => $selesai,
                    "belum_selesai" => $belumSelesai,
                    "persentase" => $persen
                ]
            ]);
        } catch (Throwable $e) {
            jsonResponse(false, "Gagal memperbarui status dokumen: " . $e->getMessage(), null, 500);
        }
    }

    $nomor = (int)($data['nomor_dokumen'] ?? 0);
    $nama = trim($data['nama_dokumen'] ?? '');
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = trim($data['status_kelengkapan'] ?? 'Belum Disiapkan');
    $tgl = !empty($data['tanggal_disiapkan']) ? trim($data['tanggal_disiapkan']) : null;
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama dokumen wajib diisi.", null, 400);
    }

    if ($nomor <= 0) {
        $maxStmt = $db->prepare("SELECT COALESCE(MAX(nomor_dokumen), 0) + 1 AS next_no FROM dokumen_administrasi WHERE user_id = ?");
        $maxStmt->execute([$userId]);
        $nomor = (int)$maxStmt->fetch()['next_no'];
    }

    try {
        $stmt = $db->prepare("INSERT INTO dokumen_administrasi (user_id, nomor_dokumen, nama_dokumen, penanggung_jawab, status_kelengkapan, tanggal_disiapkan, catatan) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$userId, $nomor, $nama, $pj, $status, $tgl, $catatan]);
        $newId = (int)$db->lastInsertId();

        $fetch = $db->prepare("SELECT * FROM dokumen_administrasi WHERE id = ?");
        $fetch->execute([$newId]);

        jsonResponse(true, "Dokumen berhasil ditambahkan.", $fetch->fetch(), 201);
    } catch (Throwable $e) {
        jsonResponse(false, "Gagal menambahkan dokumen: " . $e->getMessage(), null, 500);
    }
} elseif ($method === 'PUT') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? 0);
    if ($id <= 0) {
        jsonResponse(false, "ID dokumen tidak valid.", null, 400);
    }

    $nomor = (int)($data['nomor_dokumen'] ?? 1);
    $nama = trim($data['nama_dokumen'] ?? '');
    $pj = trim($data['penanggung_jawab'] ?? 'Keduanya');
    $status = trim($data['status_kelengkapan'] ?? 'Belum Disiapkan');
    $tgl = !empty($data['tanggal_disiapkan']) ? trim($data['tanggal_disiapkan']) : null;
    $catatan = trim($data['catatan'] ?? '');

    if (empty($nama)) {
        jsonResponse(false, "Nama dokumen wajib diisi.", null, 400);
    }

    try {
        $stmt = $db->prepare("UPDATE dokumen_administrasi SET nomor_dokumen = ?, nama_dokumen = ?, penanggung_jawab = ?, status_kelengkapan = ?, tanggal_disiapkan = ?, catatan = ? WHERE id = ?");
        $stmt->execute([$nomor, $nama, $pj, $status, $tgl, $catatan, $id]);

        $fetch = $db->prepare("SELECT * FROM dokumen_administrasi WHERE id = ?");
        $fetch->execute([$id]);

        jsonResponse(true, "Dokumen berhasil diperbarui.", $fetch->fetch());
    } catch (Throwable $e) {
        jsonResponse(false, "Gagal memperbarui dokumen: " . $e->getMessage(), null, 500);
    }
} elseif ($method === 'DELETE') {
    $data = getRequestData();
    $id = (int)($data['id'] ?? ($_GET['id'] ?? 0));
    if ($id <= 0) {
        jsonResponse(false, "ID dokumen tidak valid.", null, 400);
    }

    try {
        $stmt = $db->prepare("DELETE FROM dokumen_administrasi WHERE id = ?");
        $stmt->execute([$id]);

        jsonResponse(true, "Dokumen berhasil dihapus.", ["id" => $id]);
    } catch (Throwable $e) {
        jsonResponse(false, "Gagal menghapus dokumen: " . $e->getMessage(), null, 500);
    }
} else {
    jsonResponse(false, "Metode HTTP tidak didukung.", null, 405);
}
