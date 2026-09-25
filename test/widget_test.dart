// Uji Asersi Mandiri Terkecil (*Smallest Runnable Smoke Check*)
// Memvalidasi bahwa kerangka aplikasi CineFlow dapat dibangun dan menampilkan tab navigasi tanpa crash.

import 'package:flutter_test/flutter_test.dart';
import 'package:cineflow/contracts/mock_provider.dart';
import 'package:cineflow/main.dart';

void main() {
  testWidgets('Smoke Test: App Shell dan Tab Navigasi berhasil dirender', (WidgetTester tester) async {
    // Bangun aplikasi dengan MockStreamProvider
    await tester.pumpWidget(
      const CineFlowAppScope(
        streamProvider: MockStreamProvider(simulatedDelayMs: 0),
        child: CineFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi bahwa 4 tab utama LokLok berhasil tampil
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
    expect(find.text('Koleksi'), findsOneWidget);
  });
}
