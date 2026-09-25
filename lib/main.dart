// Titik Masuk Utama Aplikasi CineFlow (*Root Entry Point*)
// Mengonfigurasi tema gelap sinematik, pelindung error global, dan kerangka App Shell.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/error/global_error_boundary.dart';
import 'contracts/api_contracts.dart';
import 'contracts/mock_provider.dart';
import 'features/shell/app_shell.dart';

/// Penyedia layanan data global tunggal (Service Locator / Dependency Injection sederhana)
class CineFlowAppScope extends InheritedWidget {
  final StreamProvider streamProvider;

  const CineFlowAppScope({
    super.key,
    required this.streamProvider,
    required super.child,
  });

  static StreamProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CineFlowAppScope>();
    assert(scope != null, 'CineFlowAppScope tidak ditemukan di dalam widget tree');
    return scope!.streamProvider;
  }

  @override
  bool updateShouldNotify(covariant CineFlowAppScope oldWidget) =>
      streamProvider != oldWidget.streamProvider;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci status bar agar transparan dengan ikon putih sinematik
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    GlobalErrorBoundary(
      child: CineFlowAppScope(
        streamProvider: const MockStreamProvider(),
        child: const CineFlowApp(),
      ),
    ),
  );
}

class CineFlowApp extends StatelessWidget {
  const CineFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
