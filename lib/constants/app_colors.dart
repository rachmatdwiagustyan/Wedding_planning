import 'package:flutter/material.dart';

class AppColors {
  // Palet Warna Utama
  static const Color warmIvory = Color(0xFFF5EFE5);
  static const Color champagne = Color(0xFFD8C2A3);
  static const Color mochaBrown = Color(0xFF755849);
  static const Color deepBurgundy = Color(0xFF542C39);
  static const Color softTaupe = Color(0xFFB7A89A);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF34302E);

  // Variasi UI & Status
  static const Color background = warmIvory;
  static const Color cardBg = pureWhite;
  static const Color primary = deepBurgundy;
  static const Color accent = champagne;
  static const Color textPrimary = charcoal;
  static const Color textSecondary = mochaBrown;
  static const Color textMuted = softTaupe;
  static const Color divider = Color(0xFFE4DAD0);
  static const Color inputBorder = Color(0xFFD8C2A3);

  // Penanggung Jawab Tag Colors
  static const Color wanita = Color(0xFFC77382); // Dusty Rose
  static const Color pria = Color(0xFF5C88AC);   // Soft Blue
  static const Color keduanya = Color(0xFF5E9A78); // Soft Green

  // Status Colors
  static const Color success = Color(0xFF4A7C59);
  static const Color warning = Color(0xFFD49B45);
  static const Color danger = Color(0xFFAD3B3B);
  static const Color info = Color(0xFF4A7B9D);

  // Palet Warna Menu Pusat Persiapan (Warm Ivory, Champagne, Deep Burgundy & Mocha Brown)
  static const Color ivoryBg = Color(0xFFF5EFE5);       // Warm Ivory (#F5EFE5)
  static const Color champagneBg = Color(0xFFEFE5D8);   // Champagne Wash (#D8C2A5 blend)

  static const Color iconBurgundy = Color(0xFF542D3C);  // Deep Burgundy (#542D3C)
  static const Color iconMocha = Color(0xFF80614F);     // Mocha Brown (#80614F)
  static const Color iconSage = Color(0xFF6B8273);      // Muted Sage (#829789 accent)
  static const Color iconRose = Color(0xFFA66369);      // Dusty Rose (#C58D91 accent)

  // Backward compatibility aliases
  static const Color menuAdministrasi = iconRose;
  static const Color menuAdministrasiBg = ivoryBg;
  static const Color menuKebutuhan = iconMocha;
  static const Color menuKebutuhanBg = champagneBg;
  static const Color menuTamu = iconSage;
  static const Color menuTamuBg = ivoryBg;
  static const Color menuVendor = iconBurgundy;
  static const Color menuVendorBg = champagneBg;
  static const Color menuTugas = iconBurgundy;
  static const Color menuTugasBg = ivoryBg;
  static const Color menuCatatan = iconMocha;
  static const Color menuCatatanBg = champagneBg;
  static const Color menuPengingat = iconBurgundy;
  static const Color menuPengingatBg = ivoryBg;
}
