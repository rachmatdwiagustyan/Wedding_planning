import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dashboard/dashboard_tab.dart';
import 'persiapan/persiapan_hub_tab.dart';
import 'anggaran/anggaran_tab.dart';
import 'jadwal/jadwal_tab.dart';
import 'profil/profil_tab.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;
  final GlobalKey<DashboardTabState> _dashboardKey = GlobalKey<DashboardTabState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      _dashboardKey.currentState?.loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardTab(
        key: _dashboardKey,
        onNavigateToPersiapan: () => _onTabTapped(1),
        onNavigateToAnggaran: () => _onTabTapped(2),
        onNavigateToJadwal: () => _onTabTapped(3),
      ),
      const PersiapanHubTab(),
      const AnggaranTab(),
      const JadwalTab(),
      const ProfilTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.mochaBrown.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.pureWhite,
          selectedItemColor: AppColors.deepBurgundy,
          unselectedItemColor: AppColors.softTaupe,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize_outlined),
              activeIcon: Icon(Icons.dashboard_customize),
              label: 'Persiapan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Anggaran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
