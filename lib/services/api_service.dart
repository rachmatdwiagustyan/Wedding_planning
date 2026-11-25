import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';
import '../models/user_model.dart';
import '../models/pasangan_model.dart';
import '../models/dashboard_model.dart';
import '../models/anggaran_model.dart';
import '../models/kebutuhan_model.dart';
import '../models/perbandingan_model.dart';
import '../models/dokumen_model.dart';
import '../models/jadwal_model.dart';
import '../models/tamu_model.dart';
import '../models/vendor_model.dart';
import '../models/tugas_model.dart';
import '../models/catatan_model.dart';
import '../models/pengingat_model.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class ApiService {
  static dynamic _safeJsonDecode(String body, [int statusCode = 200]) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return {
        'success': false,
        'message': 'Respon server kosong (HTTP $statusCode).',
        'data': null,
      };
    }
    try {
      return jsonDecode(trimmed);
    } catch (e) {
      return {
        'success': false,
        'message': 'Format respon server tidak valid (HTTP $statusCode).',
        'data': null,
      };
    }
  }

  static Future<Map<String, String>> _headers() async {
    final userId = await SessionService.getUserId();
    final token = await SessionService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (userId != null && userId > 0) {
      headers['User-Id'] = userId.toString();
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // =================== AUTH ===================

  static Future<ApiResponse<UserModel>> register({
    required String namaLengkap,
    required String email,
    required String password,
    required String konfirmasiPassword,
  }) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/auth/register.php');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': namaLengkap,
          'email': email,
          'password': password,
          'konfirmasi_password': konfirmasiPassword,
        }),
      );

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null && json['data']['user'] != null) {
        final userData = json['data']['user'];
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Pendaftaran berhasil.',
          data: UserModel.fromJson(userData),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal mendaftar.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi ke server gagal: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/auth/login.php');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        final data = json['data'];
        final user = UserModel.fromJson(data['user']);
        final token = data['token'] ?? '';
        final hasPasangan = data['has_pasangan'] == true;
        PasanganModel? pasangan;
        if (data['pasangan'] != null) {
          pasangan = PasanganModel.fromJson(data['pasangan']);
        }

        await SessionService.saveSession(
          token: token,
          user: user,
          pasangan: pasangan,
        );

        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Login berhasil.',
          data: {
            'user': user,
            'has_pasangan': hasPasangan,
            'pasangan': pasangan,
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Email atau kata sandi salah.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi ke server gagal: $e');
    }
  }

  static Future<void> logout() async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/auth/logout.php');
      final headers = await _headers();
      await http.post(uri, headers: headers);
    } catch (_) {}
    await SessionService.clearSession();
  }

  static Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/auth/profile.php');
      final headers = await _headers();
      final res = await http.get(uri, headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final data = json['data'];
        final user = UserModel.fromJson(data['user']);
        PasanganModel? pasangan;
        if (data['pasangan'] != null) {
          pasangan = PasanganModel.fromJson(data['pasangan']);
        }
        await SessionService.updateUser(user);
        if (pasangan != null) {
          await SessionService.updatePasangan(pasangan);
        }
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Profil berhasil dimuat.',
          data: {'user': user, 'pasangan': pasangan},
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat profil.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<UserModel>> updateProfile({
    required String namaLengkap,
    required String email,
    String? password,
  }) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/auth/profile.php');
      final headers = await _headers();
      final body = {
        'nama_lengkap': namaLengkap,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      final res = await http.put(uri, headers: headers, body: jsonEncode(body));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final user = UserModel.fromJson(json['data']['user']);
        await SessionService.updateUser(user);
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Profil berhasil diperbarui.',
          data: user,
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui profil.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== PASANGAN ===================

  static Future<ApiResponse<PasanganModel>> getPasangan() async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/pasangan.php');
      final headers = await _headers();
      final res = await http.get(uri, headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true && json['data'] != null) {
        final pasangan = PasanganModel.fromJson(json['data']);
        await SessionService.updatePasangan(pasangan);
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Data pasangan berhasil dimuat.',
          data: pasangan,
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Belum ada data pasangan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<PasanganModel>> savePasangan(PasanganModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/pasangan.php');
      final headers = await _headers();
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(model.toJson()),
      );

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final saved = PasanganModel.fromJson(json['data']);
        await SessionService.updatePasangan(saved);
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Identitas pasangan berhasil disimpan.',
          data: saved,
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menyimpan identitas pasangan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== DASHBOARD ===================

  static Future<ApiResponse<DashboardModel>> getDashboard() async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/dashboard.php');
      final headers = await _headers();
      final res = await http.get(uri, headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final dashboard = DashboardModel.fromJson(json['data']);
        if (dashboard.pasangan != null) {
          await SessionService.updatePasangan(dashboard.pasangan!);
        }
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Dashboard dimuat.',
          data: dashboard,
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat dashboard.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== ANGGARAN ===================

  static Future<ApiResponse<Map<String, dynamic>>> getAnggaran({String? kategori}) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final userId = await SessionService.getUserId() ?? 0;
      var url = '$baseUrl/api/anggaran.php';
      final params = <String>[];
      if (userId > 0) params.add('user_id=$userId');
      if (kategori != null && kategori != 'Semua') {
        params.add('kategori=${Uri.encodeComponent(kategori)}');
      }
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        final List list = json['data']['items'] ?? [];
        final items = list.map((e) => AnggaranModel.fromJson(e)).toList();
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'items': items,
            'total_estimasi': double.tryParse(json['data']['total_estimasi']?.toString() ?? '0') ?? 0.0,
            'total_aktual': double.tryParse(json['data']['total_aktual']?.toString() ?? '0') ?? 0.0,
            'selisih': double.tryParse(json['data']['selisih']?.toString() ?? '0') ?? 0.0,
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat anggaran.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<AnggaranModel>> addAnggaran(AnggaranModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/anggaran.php');
      final headers = await _headers();
      final bodyData = model.toJson();
      if (bodyData['user_id'] == null || bodyData['user_id'] == 0) {
        final uid = await SessionService.getUserId();
        if (uid != null && uid > 0) bodyData['user_id'] = uid;
      }
      final res = await http.post(uri, headers: headers, body: jsonEncode(bodyData));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Anggaran berhasil ditambahkan.',
          data: AnggaranModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah anggaran.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<AnggaranModel>> updateAnggaran(AnggaranModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/anggaran.php');
      final headers = await _headers();
      final bodyData = model.toJson();
      if (bodyData['user_id'] == null || bodyData['user_id'] == 0) {
        final uid = await SessionService.getUserId();
        if (uid != null && uid > 0) bodyData['user_id'] = uid;
      }
      final res = await http.put(uri, headers: headers, body: jsonEncode(bodyData));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Anggaran berhasil diperbarui.',
          data: AnggaranModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui anggaran.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteAnggaran(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final userId = await SessionService.getUserId() ?? 0;
      final uri = Uri.parse('$baseUrl/api/anggaran.php');
      final headers = await _headers();
      final bodyData = <String, dynamic>{'id': id};
      if (userId > 0) bodyData['user_id'] = userId;
      final res = await http.delete(uri, headers: headers, body: jsonEncode(bodyData));

      final json = _safeJsonDecode(res.body, res.statusCode);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Anggaran berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== KEBUTUHAN ===================

  static Future<ApiResponse<Map<String, dynamic>>> getKebutuhan({String? kategori}) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/kebutuhan.php';
      if (kategori != null && kategori != 'Semua') {
        url += '?kategori=${Uri.encodeComponent(kategori)}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final List list = json['data']['items'] ?? [];
        final items = list.map((e) => KebutuhanModel.fromJson(e)).toList();
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'items': items,
            'total_item': json['data']['total_item'] ?? 0,
            'grand_total': double.tryParse(json['data']['grand_total']?.toString() ?? '0') ?? 0.0,
            'total_dibeli': json['data']['total_dibeli'] ?? 0,
            'total_terbeli': double.tryParse(json['data']['total_terbeli']?.toString() ?? '0') ?? 0.0,
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat kebutuhan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<KebutuhanModel>> addKebutuhan(KebutuhanModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/kebutuhan.php');
      final headers = await _headers();
      final res = await http.post(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Kebutuhan berhasil ditambahkan.',
          data: KebutuhanModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah kebutuhan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<KebutuhanModel>> updateKebutuhan(KebutuhanModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/kebutuhan.php');
      final headers = await _headers();
      final res = await http.put(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Kebutuhan berhasil diperbarui.',
          data: KebutuhanModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui kebutuhan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> toggleKebutuhan(int id, String newStatus) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/kebutuhan.php');
      final headers = await _headers();
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'action': 'toggle_status',
          'id': id,
          'status_pembelian': newStatus,
        }),
      );

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Status berhasil diubah.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteKebutuhan(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/kebutuhan.php');
      final headers = await _headers();
      final res = await http.delete(uri, headers: headers, body: jsonEncode({'id': id}));

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Kebutuhan berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== PERBANDINGAN ===================

  static Future<ApiResponse<Map<String, dynamic>>> getPerbandingan() async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final userId = await SessionService.getUserId() ?? 0;
      var url = '$baseUrl/api/perbandingan.php';
      if (userId > 0) {
        url += '?user_id=$userId';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        final List list = json['data']['items'] ?? [];
        final items = list.map((e) => PerbandinganModel.fromJson(e)).toList();
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'items': items,
            'summary': json['data']['summary'] ?? {},
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat perbandingan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<PerbandinganModel>> addPerbandingan(PerbandinganModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/perbandingan.php');
      final headers = await _headers();
      final bodyData = model.toJson();
      if (bodyData['user_id'] == null || bodyData['user_id'] == 0) {
        final uid = await SessionService.getUserId();
        if (uid != null && uid > 0) bodyData['user_id'] = uid;
      }
      final res = await http.post(uri, headers: headers, body: jsonEncode(bodyData));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Perbandingan berhasil ditambahkan.',
          data: PerbandinganModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah perbandingan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<PerbandinganModel>> updatePerbandingan(PerbandinganModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/perbandingan.php');
      final headers = await _headers();
      final bodyData = model.toJson();
      if (bodyData['user_id'] == null || bodyData['user_id'] == 0) {
        final uid = await SessionService.getUserId();
        if (uid != null && uid > 0) bodyData['user_id'] = uid;
      }
      final res = await http.put(uri, headers: headers, body: jsonEncode(bodyData));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Perbandingan berhasil diperbarui.',
          data: PerbandinganModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui perbandingan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deletePerbandingan(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final userId = await SessionService.getUserId() ?? 0;
      final uri = Uri.parse('$baseUrl/api/perbandingan.php');
      final headers = await _headers();
      final bodyData = <String, dynamic>{'id': id};
      if (userId > 0) bodyData['user_id'] = userId;
      final res = await http.delete(uri, headers: headers, body: jsonEncode(bodyData));

      final json = _safeJsonDecode(res.body, res.statusCode);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Perbandingan berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== DOKUMEN ADMINISTRASI ===================

  static Future<ApiResponse<Map<String, dynamic>>> getDokumen({String? penanggungJawab}) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      final queryParams = <String>[];
      if (userId != null && userId > 0) {
        queryParams.add('user_id=$userId');
      }
      if (penanggungJawab != null && penanggungJawab != 'Semua') {
        queryParams.add('penanggung_jawab=${Uri.encodeComponent(penanggungJawab)}');
      }
      var url = '$baseUrl/api/dokumen.php';
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        final List list = json['data']['items'] ?? [];
        final items = list.map((e) => DokumenModel.fromJson(e)).toList();
        final rawPersen = json['data']['persentase'];
        final persentase = double.tryParse(rawPersen?.toString() ?? '0') ?? 0.0;
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'items': items,
            'total': json['data']['total'] ?? 0,
            'selesai': json['data']['selesai'] ?? 0,
            'belum_selesai': json['data']['belum_selesai'] ?? 0,
            'persentase': persentase,
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat dokumen.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<DokumenModel>> addDokumen(DokumenModel model) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/dokumen.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final uri = Uri.parse(url);
      final headers = await _headers();
      final res = await http.post(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Dokumen berhasil ditambahkan.',
          data: DokumenModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah dokumen.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<DokumenModel>> updateDokumen(DokumenModel model) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/dokumen.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final uri = Uri.parse(url);
      final headers = await _headers();
      final res = await http.put(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Dokumen berhasil diperbarui.',
          data: DokumenModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui dokumen.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> toggleDokumen(int id, String newStatus) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/dokumen.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final uri = Uri.parse(url);
      final headers = await _headers();
      final bodyData = {
        'action': 'toggle_status',
        'id': id,
        'status_kelengkapan': newStatus,
        if (userId != null && userId > 0) 'user_id': userId,
      };
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(bodyData),
      );

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Status berhasil diubah.',
          data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal mengubah status dokumen.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteDokumen(int id) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/dokumen.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final uri = Uri.parse(url);
      final headers = await _headers();
      final res = await http.delete(uri, headers: headers, body: jsonEncode({
        'id': id,
        if (userId != null && userId > 0) 'user_id': userId,
      }));

      final json = _safeJsonDecode(res.body, res.statusCode);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Dokumen berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== JADWAL KEGIATAN ===================

  static Future<ApiResponse<List<JadwalModel>>> getJadwal({String? tanggal}) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/jadwal.php';
      if (tanggal != null && tanggal.isNotEmpty) {
        url += '?tanggal=${Uri.encodeComponent(tanggal)}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final List list = json['data'] ?? [];
        final items = list.map((e) => JadwalModel.fromJson(e)).toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: items);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat jadwal.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<JadwalModel>> addJadwal(JadwalModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/jadwal.php');
      final headers = await _headers();
      final res = await http.post(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Jadwal berhasil ditambahkan.',
          data: JadwalModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah jadwal.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<JadwalModel>> updateJadwal(JadwalModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/jadwal.php');
      final headers = await _headers();
      final res = await http.put(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Jadwal berhasil diperbarui.',
          data: JadwalModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui jadwal.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> toggleJadwal(int id, bool isDone) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/jadwal.php');
      final headers = await _headers();
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'action': 'toggle_status',
          'id': id,
          'status_selesai': isDone ? 1 : 0,
        }),
      );

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Status berhasil diubah.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteJadwal(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/jadwal.php');
      final headers = await _headers();
      final res = await http.delete(uri, headers: headers, body: jsonEncode({'id': id}));

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Jadwal berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== DAFTAR TAMU ===================

  static Future<ApiResponse<Map<String, dynamic>>> getTamu({
    String? search,
    String? kategori,
    String? konfirmasi,
  }) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/tamu.php?1=1';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      if (kategori != null && kategori != 'Semua') {
        url += '&kategori=${Uri.encodeComponent(kategori)}';
      }
      if (konfirmasi != null && konfirmasi != 'Semua') {
        url += '&konfirmasi=${Uri.encodeComponent(konfirmasi)}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final List list = json['data']['items'] ?? [];
        final items = list.map((e) => TamuModel.fromJson(e)).toList();
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'items': items,
            'summary': json['data']['summary'] ?? {},
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat tamu.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<TamuModel>> addTamu(TamuModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/tamu.php');
      final headers = await _headers();
      final res = await http.post(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Tamu berhasil ditambahkan.',
          data: TamuModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah tamu.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<TamuModel>> updateTamu(TamuModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/tamu.php');
      final headers = await _headers();
      final res = await http.put(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Tamu berhasil diperbarui.',
          data: TamuModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui tamu.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteTamu(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/tamu.php');
      final headers = await _headers();
      final res = await http.delete(uri, headers: headers, body: jsonEncode({'id': id}));

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Tamu berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== VENDOR ===================

  static Future<ApiResponse<Map<String, dynamic>>> getVendor({
    String? kategori,
    String? search,
    String? status,
  }) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      final queryParams = <String>[];
      if (userId != null && userId > 0) {
        queryParams.add('user_id=$userId');
      }
      if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
        queryParams.add('kategori=${Uri.encodeComponent(kategori)}');
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search.trim())}');
      }
      if (status != null && status.isNotEmpty && status != 'Semua') {
        queryParams.add('status=${Uri.encodeComponent(status)}');
      }
      var url = '$baseUrl/api/vendor.php';
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        final List list = json['data']['items'] ?? [];
        final items = list.map((e) => VendorModel.fromJson(e)).toList();
        final List catList = json['data']['perbandingan_kategori'] ?? [];
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'items': items,
            'summary': json['data']['summary'] ?? {},
            'perbandingan_kategori': catList,
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat vendor.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<VendorModel>> addVendor(VendorModel model) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/vendor.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final headers = await _headers();
      final res = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(model.toJson()));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Vendor berhasil ditambahkan.',
          data: VendorModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah vendor.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<VendorModel>> updateVendor(VendorModel model) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/vendor.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final headers = await _headers();
      final res = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(model.toJson()));

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Vendor berhasil diperbarui.',
          data: VendorModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui vendor.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<VendorModel>> updateVendorStatus(int id, String status) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/vendor.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final headers = await _headers();
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'action': 'update_status',
          'id': id,
          'status_pemesanan': status,
          if (userId != null && userId > 0) 'user_id': userId,
        }),
      );

      final json = _safeJsonDecode(res.body, res.statusCode);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Status vendor berhasil diubah.',
          data: VendorModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal mengubah status vendor.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteVendor(int id) async {
    try {
      final userId = await SessionService.getUserId();
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/vendor.php';
      if (userId != null && userId > 0) {
        url += '?user_id=$userId';
      }
      final headers = await _headers();
      final res = await http.delete(Uri.parse(url), headers: headers, body: jsonEncode({'id': id}));

      final json = _safeJsonDecode(res.body, res.statusCode);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Vendor berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== TUGAS PERNIKAHAN ===================

  static Future<ApiResponse<Map<String, dynamic>>> getTugas({String? status}) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/tugas.php';
      if (status != null && status != 'Semua') {
        url += '?status=${Uri.encodeComponent(status)}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final List list = json['data']['items'] ?? [];
        final items = list.map((e) => TugasModel.fromJson(e)).toList();
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'items': items,
            'total': json['data']['total'] ?? 0,
            'selesai': json['data']['selesai'] ?? 0,
            'proses': json['data']['proses'] ?? 0,
            'belum': json['data']['belum'] ?? 0,
            'persentase': json['data']['persentase'] ?? 0,
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat tugas.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<TugasModel>> addTugas(TugasModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/tugas.php');
      final headers = await _headers();
      final res = await http.post(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Tugas berhasil ditambahkan.',
          data: TugasModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah tugas.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<TugasModel>> updateTugas(TugasModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/tugas.php');
      final headers = await _headers();
      final res = await http.put(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Tugas berhasil diperbarui.',
          data: TugasModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui tugas.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> toggleTugas(int id, String newStatus) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/tugas.php');
      final headers = await _headers();
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'action': 'toggle_status',
          'id': id,
          'status': newStatus,
        }),
      );

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Status berhasil diubah.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteTugas(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/tugas.php');
      final headers = await _headers();
      final res = await http.delete(uri, headers: headers, body: jsonEncode({'id': id}));

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Tugas berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== CATATAN ===================

  static Future<ApiResponse<List<CatatanModel>>> getCatatan({String? kategori}) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/catatan.php';
      if (kategori != null && kategori != 'Semua') {
        url += '?kategori=${Uri.encodeComponent(kategori)}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final List list = json['data'] ?? [];
        final items = list.map((e) => CatatanModel.fromJson(e)).toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: items);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat catatan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<CatatanModel>> addCatatan(CatatanModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/catatan.php');
      final headers = await _headers();
      final res = await http.post(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Catatan berhasil ditambahkan.',
          data: CatatanModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah catatan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<CatatanModel>> updateCatatan(CatatanModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/catatan.php');
      final headers = await _headers();
      final res = await http.put(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Catatan berhasil diperbarui.',
          data: CatatanModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui catatan.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deleteCatatan(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/catatan.php');
      final headers = await _headers();
      final res = await http.delete(uri, headers: headers, body: jsonEncode({'id': id}));

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Catatan berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  // =================== PENGINGAT ===================

  static Future<ApiResponse<List<PengingatModel>>> getPengingat({String? status}) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      var url = '$baseUrl/api/pengingat.php';
      if (status != null && status != 'Semua') {
        url += '?status=${Uri.encodeComponent(status)}';
      }
      final headers = await _headers();
      final res = await http.get(Uri.parse(url), headers: headers);

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        final List list = json['data'] ?? [];
        final items = list.map((e) => PengingatModel.fromJson(e)).toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: items);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memuat pengingat.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<PengingatModel>> addPengingat(PengingatModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/pengingat.php');
      final headers = await _headers();
      final res = await http.post(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Pengingat berhasil ditambahkan.',
          data: PengingatModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal menambah pengingat.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<PengingatModel>> updatePengingat(PengingatModel model) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/pengingat.php');
      final headers = await _headers();
      final res = await http.put(uri, headers: headers, body: jsonEncode(model.toJson()));

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? 'Pengingat berhasil diperbarui.',
          data: PengingatModel.fromJson(json['data']),
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Gagal memperbarui pengingat.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> togglePengingat(int id, String newStatus) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/pengingat.php');
      final headers = await _headers();
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'action': 'toggle_status',
          'id': id,
          'status': newStatus,
        }),
      );

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Status pengingat berhasil diubah.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse<bool>> deletePengingat(int id) async {
    try {
      final baseUrl = await SessionService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/pengingat.php');
      final headers = await _headers();
      final res = await http.delete(uri, headers: headers, body: jsonEncode({'id': id}));

      final json = jsonDecode(res.body);
      return ApiResponse(
        success: json['success'] == true,
        message: json['message'] ?? 'Pengingat berhasil dihapus.',
        data: json['success'] == true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Koneksi gagal: $e');
    }
  }
}
