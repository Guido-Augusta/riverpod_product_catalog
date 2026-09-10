import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Event payload untuk mencatat event tap ulang pada tab aktif.
/// Menggunakan timestamp agar event baru selalu memicu listener Riverpod
/// meskipun index tab yang ditekan sama secara berturut-turut.
@immutable
class TabReselectEvent {
  const TabReselectEvent({required this.tabIndex, required this.timestamp});

  final int tabIndex;
  final int timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabReselectEvent &&
          runtimeType == other.runtimeType &&
          tabIndex == other.tabIndex &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(tabIndex, timestamp);
}

/// Notifier untuk mengelola event re-selection tab aktif di bottom nav bar.
class TabReselectNotifier extends Notifier<TabReselectEvent?> {
  @override
  TabReselectEvent? build() => null;

  void reselect(int index) {
    state = TabReselectEvent(
      tabIndex: index,
      timestamp: DateTime.now().microsecondsSinceEpoch,
    );
  }
}

final tabReselectNotifierProvider =
    NotifierProvider<TabReselectNotifier, TabReselectEvent?>(
      TabReselectNotifier.new,
    );

class MainNavScaffold extends ConsumerStatefulWidget {
  const MainNavScaffold({super.key, required this.navigationShell});

  /// Shell dari GoRouter yang menyimpan branch aktif dan state halaman
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends ConsumerState<MainNavScaffold> {
  DateTime? _lastBackPressTime;

  void _onDestinationSelected(int index) {
    // 1. Haptic feedback untuk sentuhan native yang responsif
    HapticFeedback.lightImpact();

    final isCurrentTab = index == widget.navigationShell.currentIndex;
    if (isCurrentTab) {
      // 2. Trigger event agar halaman anak yang aktif dapat melakukan scroll ke atas
      ref.read(tabReselectNotifierProvider.notifier).reselect(index);
    }

    // 3. Pindah branch atau reset ke initialLocation jika re-tap tab aktif
    widget.navigationShell.goBranch(index, initialLocation: isCurrentTab);
  }

  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    // 1. Jika sedang di tab selain Tab 0 (Products), kembali ke Tab 0 lebih dahulu
    if (widget.navigationShell.currentIndex != 0) {
      _lastBackPressTime = null;
      widget.navigationShell.goBranch(0);
      return;
    }

    // 2. Jika sudah di Tab 0, cek interval double-tap (khusus Android)
    final now = DateTime.now();
    final isWithinThreshold =
        _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) <= const Duration(seconds: 2);

    if (isWithinThreshold) {
      // User menekan back kedua kali dalam <= 2 detik -> keluar aplikasi
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SystemNavigator.pop();
    } else {
      // Penekanan pertama -> catat waktu & tampilkan SnackBar konfirmasi
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Press once more to exit',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return PopScope(
      // Hanya intervensi tombol back di Android; biarkan gestur native iOS/desktop berjalan normal
      canPop: !isAndroid,
      onPopInvokedWithResult: (didPop, result) {
        if (isAndroid) {
          _handlePopInvoked(didPop);
        }
      },
      child: Scaffold(
        // Mencegah NavigationBar terdorong naik saat keyboard virtual muncul di salah satu tab
        resizeToAvoidBottomInset: false,
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: _onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Catalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
