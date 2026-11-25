<?php
require_once __DIR__ . '/../config/database.php';

$database = new Database();
$db = $database->getConnection();
$userId = getAuthUserId();

// 1. Data Pengguna
$uStmt = $db->prepare("SELECT id, nama_lengkap, email, foto FROM users WHERE id = ?");
$uStmt->execute([$userId]);
$user = $uStmt->fetch();

// 2. Data Pasangan
$pStmt = $db->prepare("SELECT * FROM pasangan WHERE user_id = ? LIMIT 1");
$pStmt->execute([$userId]);
$pasangan = $pStmt->fetch();

// 3. Perhitungan Hari Menuju Pernikahan (Countdown)
$countdownDays = null;
if ($pasangan && !empty($pasangan['tanggal_pernikahan'])) {
    $weddingDate = new DateTime($pasangan['tanggal_pernikahan']);
    $today = new DateTime('today');
    $interval = $today->diff($weddingDate);
    if ($weddingDate < $today) {
        $countdownDays = -$interval->days; // Sudah lewat
    } else {
        $countdownDays = $interval->days;
    }
}

// 4. Data Anggaran
$anggaranStmt = $db->prepare("SELECT 
    COALESCE(SUM(estimasi_biaya), 0) AS total_estimasi,
    COALESCE(SUM(biaya_aktual), 0) AS total_aktual
    FROM anggaran WHERE user_id = ?");
$anggaranStmt->execute([$userId]);
$anggaranRow = $anggaranStmt->fetch();
$totalEstimasi = (float)$anggaranRow['total_estimasi'];
$totalAktual = (float)$anggaranRow['total_aktual'];
$selisihAnggaran = $totalEstimasi - $totalAktual;

// 5. Data Dokumen Administrasi
seedDefaultDocuments($db, $userId);
$docStmt = $db->prepare("SELECT 
    COUNT(*) AS total_dokumen,
    COALESCE(SUM(CASE WHEN status_kelengkapan IN ('Sudah Lengkap', 'Sudah Disiapkan') THEN 1 ELSE 0 END), 0) AS dokumen_lengkap
    FROM dokumen_administrasi WHERE user_id = ?");
$docStmt->execute([$userId]);
$docRow = $docStmt->fetch();
$totalDokumen = (int)$docRow['total_dokumen'];
$dokumenLengkap = (int)$docRow['dokumen_lengkap'];
$persenDokumen = $totalDokumen > 0 ? round(($dokumenLengkap / $totalDokumen) * 100) : 0;

// 6. Data Tugas Pernikahan
$tugasStmt = $db->prepare("SELECT 
    COUNT(*) AS total_tugas,
    COALESCE(SUM(CASE WHEN status = 'Selesai' THEN 1 ELSE 0 END), 0) AS tugas_selesai,
    COALESCE(SUM(CASE WHEN status != 'Selesai' THEN 1 ELSE 0 END), 0) AS tugas_belum_selesai
    FROM tugas_pernikahan WHERE user_id = ?");
$tugasStmt->execute([$userId]);
$tugasRow = $tugasStmt->fetch();
$totalTugas = (int)$tugasRow['total_tugas'];
$tugasSelesai = (int)$tugasRow['tugas_selesai'];
$tugasBelumSelesai = (int)$tugasRow['tugas_belum_selesai'];
$persenTugas = $totalTugas > 0 ? round(($tugasSelesai / $totalTugas) * 100) : 0;

// 7. Data Vendor
$vendorStmt = $db->prepare("SELECT 
    COUNT(*) AS total_vendor,
    COALESCE(SUM(CASE WHEN status_pemesanan IN ('Sudah Dipesan', 'Selesai', 'Lunas') THEN 1 ELSE 0 END), 0) AS vendor_dipesan
    FROM vendor WHERE user_id = ?");
$vendorStmt->execute([$userId]);
$vendorRow = $vendorStmt->fetch();
$totalVendor = (int)$vendorRow['total_vendor'];
$vendorDipesan = (int)$vendorRow['vendor_dipesan'];

// 8. Data Daftar Tamu
$tamuStmt = $db->prepare("SELECT 
    COUNT(*) AS total_undangan,
    COALESCE(SUM(jumlah_orang), 0) AS total_tamu,
    COALESCE(SUM(CASE WHEN konfirmasi_kehadiran = 'Hadir' THEN jumlah_orang ELSE 0 END), 0) AS tamu_hadir
    FROM daftar_tamu WHERE user_id = ?");
$tamuStmt->execute([$userId]);
$tamuRow = $tamuStmt->fetch();
$totalUndangan = (int)$tamuRow['total_undangan'];
$totalTamu = (int)$tamuRow['total_tamu'];
$tamuHadir = (int)$tamuRow['tamu_hadir'];

// 9. Data Kebutuhan
$kebutuhanStmt = $db->prepare("SELECT 
    COUNT(*) AS total_kebutuhan,
    COALESCE(SUM(CASE WHEN status_pembelian = 'Sudah Dibeli' THEN 1 ELSE 0 END), 0) AS kebutuhan_dibeli
    FROM daftar_kebutuhan WHERE user_id = ?");
$kebutuhanStmt->execute([$userId]);
$kebutuhanRow = $kebutuhanStmt->fetch();
$totalKebutuhan = (int)$kebutuhanRow['total_kebutuhan'];
$kebutuhanDibeli = (int)$kebutuhanRow['kebutuhan_dibeli'];

// 10. Jadwal Terdekat (Maksimal 3 kegiatan yang akan datang)
$jadwalStmt = $db->prepare("SELECT * FROM jadwal_kegiatan 
    WHERE user_id = ? AND status_selesai = 0 
    ORDER BY tanggal ASC, jam_mulai ASC LIMIT 3");
$jadwalStmt->execute([$userId]);
$jadwalTerdekat = $jadwalStmt->fetchAll();

// 11. Pengingat Aktif (Maksimal 3 pengingat)
$pengingatStmt = $db->prepare("SELECT * FROM pengingat 
    WHERE user_id = ? AND status = 'Aktif' 
    ORDER BY tanggal_pengingat ASC, jam_pengingat ASC LIMIT 3");
$pengingatStmt->execute([$userId]);
$pengingatAktif = $pengingatStmt->fetchAll();

// 12. Hitung Persentase Kemajuan Persiapan Keseluruhan
// Bobot: Dokumen 30%, Tugas 40%, Vendor 15%, Kebutuhan 15%
$progressComponents = [];
$weights = [];

// Komponen Dokumen
$progressComponents[] = $persenDokumen;
$weights[] = 35;

// Komponen Tugas
if ($totalTugas > 0) {
    $progressComponents[] = $persenTugas;
    $weights[] = 35;
}

// Komponen Vendor
if ($totalVendor > 0) {
    $progressComponents[] = round(($vendorDipesan / $totalVendor) * 100);
    $weights[] = 15;
}

// Komponen Kebutuhan
if ($totalKebutuhan > 0) {
    $progressComponents[] = round(($kebutuhanDibeli / $totalKebutuhan) * 100);
    $weights[] = 15;
}

$sumWeights = array_sum($weights);
$weightedScore = 0;
for ($i = 0; $i < count($progressComponents); $i++) {
    $weightedScore += ($progressComponents[$i] * $weights[$i]);
}
$overallProgress = $sumWeights > 0 ? round($weightedScore / $sumWeights) : $persenDokumen;

jsonResponse(true, "Data dashboard berhasil dimuat.", [
    "user" => $user,
    "pasangan" => $pasangan ?: null,
    "countdown_days" => $countdownDays,
    "overall_progress" => min(100, max(0, $overallProgress)),
    "anggaran" => [
        "total_estimasi" => $totalEstimasi,
        "total_aktual" => $totalAktual,
        "selisih" => $selisihAnggaran
    ],
    "dokumen" => [
        "total" => $totalDokumen,
        "lengkap" => $dokumenLengkap,
        "persen" => $persenDokumen
    ],
    "tugas" => [
        "total" => $totalTugas,
        "selesai" => $tugasSelesai,
        "belum_selesai" => $tugasBelumSelesai,
        "persen" => $persenTugas
    ],
    "vendor" => [
        "total" => $totalVendor,
        "dipesan" => $vendorDipesan
    ],
    "tamu" => [
        "total_undangan" => $totalUndangan,
        "total_tamu" => $totalTamu,
        "tamu_hadir" => $tamuHadir
    ],
    "kebutuhan" => [
        "total" => $totalKebutuhan,
        "dibeli" => $kebutuhanDibeli
    ],
    "jadwal_terdekat" => $jadwalTerdekat,
    "pengingat_aktif" => $pengingatAktif
]);
