<?php
require_once __DIR__ . '/cors.php';

class Database {
    private $host = "127.0.0.1";
    private $port = "3306";
    private $db_name = "talenta_event_organizer";
    private $username = "root";
    private $password = "";
    private $socket = "/Applications/XAMPP/xamppfiles/var/mysql/mysql.sock";
    public $conn;

    public function getConnection() {
        $this->conn = null;
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];

        // 1. Coba koneksi TCP 127.0.0.1:3306
        try {
            $dsn = "mysql:host=" . $this->host . ";port=" . $this->port . ";dbname=" . $this->db_name . ";charset=utf8mb4";
            $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            return $this->conn;
        } catch(PDOException $e1) {}

        // 2. Coba socket file jika ada (khusus XAMPP macOS)
        if (file_exists($this->socket)) {
            try {
                $dsn = "mysql:unix_socket=" . $this->socket . ";dbname=" . $this->db_name . ";charset=utf8mb4";
                $this->conn = new PDO($dsn, $this->username, $this->password, $options);
                return $this->conn;
            } catch(PDOException $e2) {}
        }

        // 3. Coba fallback localhost
        try {
            $dsn = "mysql:host=localhost;dbname=" . $this->db_name . ";charset=utf8mb4";
            $this->conn = new PDO($dsn, $this->username, $this->password, $options);
            return $this->conn;
        } catch(PDOException $e3) {
            jsonResponse(false, "Koneksi database MySQL gagal. Pastikan Apache & MySQL pada XAMPP sudah berjalan.", null, 500);
            exit();
        }
    }
}

function jsonResponse($success, $message, $data = null, $httpCode = 200) {
    if (!headers_sent()) {
        http_response_code($httpCode);
        header("Content-Type: application/json; charset=UTF-8");
    }
    echo json_encode([
        "success" => $success,
        "message" => $message,
        "data" => $data
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit();
}

function getRequestData() {
    $raw = file_get_contents("php://input");
    if (!empty($raw)) {
        $json = json_decode($raw, true);
        if (is_array($json)) {
            return $json;
        }
    }
    return !empty($_POST) ? $_POST : $_GET;
}

function getAuthUserId() {
    $userId = null;

    // 1. Cek header langsung dari $_SERVER
    if (!empty($_SERVER['HTTP_USER_ID'])) {
        $userId = (int)$_SERVER['HTTP_USER_ID'];
    } elseif (!empty($_SERVER['HTTP_X_USER_ID'])) {
        $userId = (int)$_SERVER['HTTP_X_USER_ID'];
    }

    // 2. Cek getallheaders() jika tersedia
    if (!$userId && function_exists('getallheaders')) {
        $headers = getallheaders();
        if (is_array($headers)) {
            foreach ($headers as $key => $val) {
                $k = strtolower($key);
                if ($k === 'user-id' || $k === 'x-user-id') {
                    $userId = (int)$val;
                    break;
                }
                if ($k === 'authorization') {
                    if (preg_match('/Bearer\s+(\S+)/i', $val, $matches)) {
                        $tokenVal = $matches[1];
                        if (is_numeric($tokenVal)) {
                            $userId = (int)$tokenVal;
                            break;
                        }
                        $decoded = base64_decode($tokenVal, true);
                        if ($decoded && strpos($decoded, ':') !== false) {
                            $parts = explode(':', $decoded);
                            if (!empty($parts[0]) && is_numeric($parts[0])) {
                                $userId = (int)$parts[0];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    // 3. Cek Authorization header dari $_SERVER
    if (!$userId) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? null;
        if ($authHeader && preg_match('/Bearer\s+(\S+)/i', $authHeader, $matches)) {
            $tokenVal = $matches[1];
            if (is_numeric($tokenVal)) {
                $userId = (int)$tokenVal;
            } else {
                $decoded = base64_decode($tokenVal, true);
                if ($decoded && strpos($decoded, ':') !== false) {
                    $parts = explode(':', $decoded);
                    if (!empty($parts[0]) && is_numeric($parts[0])) {
                        $userId = (int)$parts[0];
                    }
                }
            }
        }
    }

    // 4. Cek query parameters atau $_POST
    if (!$userId && isset($_REQUEST['user_id']) && is_numeric($_REQUEST['user_id'])) {
        $userId = (int)$_REQUEST['user_id'];
    }

    // 5. Cek JSON request body
    if (!$userId) {
        $reqData = getRequestData();
        if (is_array($reqData) && !empty($reqData['user_id']) && is_numeric($reqData['user_id'])) {
            $userId = (int)$reqData['user_id'];
        }
    }

    // 6. Fallback ke user pertama di database jika mode single-user lokal
    if (!$userId) {
        global $db;
        if ($db) {
            try {
                $uStmt = $db->query("SELECT id FROM users ORDER BY id ASC LIMIT 1");
                $firstUser = $uStmt->fetch();
                if ($firstUser && !empty($firstUser['id'])) {
                    $userId = (int)$firstUser['id'];
                }
            } catch (Exception $e) {}
        }
    }

    if (!$userId) {
        jsonResponse(false, "Akses tidak diizinkan. Silakan login terlebih dahulu.", null, 401);
        exit();
    }
    return $userId;
}

function seedDefaultDocuments($db, $userId) {
    if (!$userId || $userId <= 0) return;

    $checkStmt = $db->prepare("SELECT COUNT(*) as cnt FROM dokumen_administrasi WHERE user_id = ?");
    $checkStmt->execute([$userId]);
    $res = $checkStmt->fetch();
    if ($res && (int)$res['cnt'] >= 18) {
        return; // Sudah ada 18 dokumen standar
    }

    $documents = [
        [1, "Pas Foto 2x3 Background Biru Calon Pengantin Wanita", "Calon Pengantin Wanita"],
        [2, "Pas Foto 2x3 Background Biru Calon Pengantin Pria", "Calon Pengantin Pria"],
        [3, "Pas Foto 4x6 Background Biru Calon Pengantin Wanita", "Calon Pengantin Wanita"],
        [4, "Pas Foto 4x6 Background Biru Calon Pengantin Pria", "Calon Pengantin Pria"],
        [5, "Fotokopi KTP Calon Pengantin Wanita", "Calon Pengantin Wanita"],
        [6, "Fotokopi KTP Calon Pengantin Pria", "Calon Pengantin Pria"],
        [7, "Fotokopi Kartu Keluarga Calon Pengantin Wanita", "Calon Pengantin Wanita"],
        [8, "Fotokopi Kartu Keluarga Calon Pengantin Pria", "Calon Pengantin Pria"],
        [9, "Fotokopi Akta Kelahiran", "Keduanya"],
        [10, "Fotokopi Ijazah Terakhir", "Keduanya"],
        [11, "Surat Pengantar RT dan RW", "Keduanya"],
        [12, "Formulir N1, N2, N4, N5", "Keduanya"],
        [13, "Surat Numpang Nikah dari KUA Domisili", "Keduanya"],
        [14, "KIR Nikah, Vaksin, dan Diskesmas", "Keduanya"],
        [15, "Fotokopi KTP Dua Orang Saksi Nikah", "Keduanya"],
        [16, "Fotokopi KTP Orang Tua", "Keduanya"],
        [17, "Fotokopi Akta Kematian (Jika Diperlukan)", "Keduanya"],
        [18, "Map Batik", "Keduanya"]
    ];

    $insert = $db->prepare("INSERT INTO dokumen_administrasi (user_id, nomor_dokumen, nama_dokumen, penanggung_jawab, status_kelengkapan) VALUES (?, ?, ?, ?, 'Belum Disiapkan')");
    foreach ($documents as $doc) {
        // Cek apakah nomor dokumen ini sudah ada untuk user
        $exist = $db->prepare("SELECT id FROM dokumen_administrasi WHERE user_id = ? AND nomor_dokumen = ?");
        $exist->execute([$userId, $doc[0]]);
        if (!$exist->fetch()) {
            $insert->execute([$userId, $doc[0], $doc[1], $doc[2]]);
        }
    }
}

function seedDefaultVendors($db, $userId) {
    if (!$userId || $userId <= 0) return;

    $vendors = [
        ['Royal Taste Catering', 'Katering', '0812-3456-7801', 'Jl. Palagan Tentara Pelajar No. 45, Sleman, Yogyakarta', 35000000.00, 'Belum Dipesan', 'Paket buffet 500 porsi, 5 gubukan pilihan (Sate, Zuppa Soup, Siomay, Bakso, Kambing Guling), aneka dessert & minuman segar.'],
        ['Larasati Boga Catering', 'Katering', '0812-3456-7802', 'Jl. Kaliurang KM 8, Ngaglik, Sleman', 28000000.00, 'Belum Dipesan', 'Menu tradisional Nusantara & oriental, 400 porsi buffet, 4 stan makanan khas, gratis tester menu untuk 4 orang.'],
        ['Blossom & Grace Decoration', 'Dekorasi', '0812-3456-7803', 'Jl. Gejayan No. 12, Sleman, D.I. Yogyakarta', 22000000.00, 'Belum Dipesan', 'Dekorasi pelaminan modern rustic / floral garden, bunga segar impor, pergola masuk, photo booth area, & lighting ambiance.'],
        ['Kirana Heritage Décor', 'Dekorasi', '0812-3456-7804', 'Jl. Bantul KM 5, Sewon, Bantul, Yogyakarta', 18500000.00, 'Belum Dipesan', 'Spesialis dekorasi adat Jawa klasik & kontemporer, gebyok ukir jati, ornamen ronce melati, karpet jalan, & lighting panggung.'],
        ['Lumiere Wedding Moments', 'Fotografer', '0812-3456-7805', 'Jl. Affandi No. 88, Caturtunggal, Depok, Sleman', 12000000.00, 'Sudah Dipesan', 'Full day coverage akad & resepsi, 2 fotografer + 1 videografer drone, album kolase 30x20cm, cinematic video 3 menit, flashdisk all raw files.'],
        ['Kisah Cerita Visual', 'Fotografer', '0812-3456-7806', 'Jl. Taman Siswa No. 34, Mergangsan, Yogyakarta', 9500000.00, 'Belum Dipesan', 'Dokumentasi candid & formal akad-resepsi, 1 fotografer + 1 videografer, teaser 1 menit Instagram, cetak canvas 40x60cm + frame.'],
        ['Grand Ballroom Sahid Raya', 'Gedung', '0812-3456-7807', 'Jl. Babarsari No. 2, Caturtunggal, Sleman', 25000000.00, 'Belum Dipesan', 'Kapasitas hingga 1.000 tamu, full AC sentral, sound system 5.000 watt, ruang transit VIP pengantin, parkir luas gratis 150 mobil.'],
        ['Pendopo Agung Royal Ambarrukmo', 'Gedung', '0812-3456-7808', 'Jl. Laksda Adisucipto No. 81, Sleman', 32000000.00, 'Belum Dipesan', 'Nuansa cagar budaya kraton Yogyakarta, semi-outdoor & pendopo utama, kapasitas 800 orang, pencahayaan heritage malam hari eksklusif.'],
        ['Flawless by Dian Ayu MUA', 'Makeup', '0812-3456-7809', 'Jl. Kaliurang KM 5, Sleman, Yogyakarta', 8500000.00, 'Belum Dipesan', 'Makeup akad & resepsi pengantin wanita (touch up 2x), paes adat / modern, makeup 2 ibu pengantin, & 4 orang penerima tamu.'],
        ['Glow Studio Wedding MUA', 'Makeup', '0812-3456-7810', 'Jl. Seturan Raya No. 15, Sleman, Yogyakarta', 6500000.00, 'Belum Dipesan', 'Flawless soft glam look, produk makeup high-end tahan 16 jam, gratis softlens & kuku palsu bride, include makeup 2 ibu.'],
        ['Sekar Asri Sanggar Kebaya & Beskap', 'Busana', '0812-3456-7811', 'Jl. Malioboro No. 67, Yogyakarta', 10500000.00, 'Belum Dipesan', 'Sewa perdana kebaya akad ekor panjang, gaun resepsi / kebaya beludru, beskap pengantin pria lengkap jarik & blangkon, 4 beskap orang tua.'],
        ['Atelier Royal Bride & Groom', 'Busana', '0812-3456-7812', 'Jl. Urip Sumoharjo No. 40, Gondokusuman, Yogyakarta', 14000000.00, 'Belum Dipesan', 'Koleksi busana internasional & nasional modern, wedding gown A-line / mermaid, jas tuxedo bespoke pria, fitting 3x & alter gratis.'],
        ['Talenta Wedding Organizer Team', 'Wedding Organizer', '0812-3456-7813', 'Jl. Monjali No. 89, Sleman, Yogyakarta', 15000000.00, 'Sudah Dipesan', '10 orang tim kru profesional di hari H, timeline & rundown acara, technical meeting vendor, koordinasi keluarga & pengisi acara, buku panduan acara.'],
        ['Harmoni Wedding Planner', 'Wedding Organizer', '0812-3456-7814', 'Jl. Godean KM 3, Kasihan, Bantul, Yogyakarta', 11000000.00, 'Belum Dipesan', 'D-Day coordination (6 kru lapangan), panduan gladi resik akad, koordinasi konsumsi tamu, pendampingan VIP pengantin & orang tua.']
    ];

    $check = $db->prepare("SELECT id FROM vendor WHERE user_id = ? AND nama_vendor = ?");
    $insert = $db->prepare("INSERT INTO vendor (user_id, nama_vendor, kategori, nomor_telepon, alamat, harga_penawaran, status_pemesanan, catatan) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    foreach ($vendors as $v) {
        $check->execute([$userId, $v[0]]);
        if (!$check->fetch()) {
            $insert->execute([$userId, $v[0], $v[1], $v[2], $v[3], $v[4], $v[5], $v[6]]);
        }
    }
}
