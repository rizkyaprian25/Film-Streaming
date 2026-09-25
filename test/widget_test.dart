// Uji Asersi Mandiri Terkecil (*Smallest Runnable Smoke Check*)
// Memvalidasi bahwa kerangka aplikasi CineFlow dapat dibangun dan menampilkan tab navigasi tanpa crash.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cineflow/contracts/models.dart';
import 'package:cineflow/contracts/mock_provider.dart';
import 'package:cineflow/core/widgets/media_card.dart';
import 'package:cineflow/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Smoke Test: App Shell dan Tab Navigasi berhasil dirender', (WidgetTester tester) async {
    // Inisialisasi mock shared preferences agar tidak memicu I/O platform native
    SharedPreferences.setMockInitialValues({});

    // Bangun aplikasi dengan MockStreamProvider
    await tester.pumpWidget(
      const CineFlowAppScope(
        streamProvider: MockStreamProvider(simulatedDelayMs: 0),
        child: CineFlowApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verifikasi bahwa 5 tab utama LokLok berhasil tampil
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
    expect(find.text('Koleksi'), findsOneWidget);
  });

  testWidgets('MediaCard: Menampilkan Fallback Poster Artistik Apple HIG saat poster kosong/offline', (WidgetTester tester) async {
    const testItem = MediaItem(
      id: 'test_1',
      title: 'Squid Game Season 3: The End',
      posterUrl: '', // Simulasi poster offline/gagal
      backdropUrl: '',
      rating: 9.6,
      releaseYear: 2026,
      type: MediaType.series,
      genres: ['Drakor', 'Survival', 'Aksi'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MediaCard(
              item: testItem,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verifikasi bahwa teks judul dan tahun 2026 berhasil tampil di poster cadangan
    expect(find.text('Squid Game Season 3: The End'), findsAtLeast(1));
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('9.6'), findsOneWidget);
    expect(find.text('SERIES'), findsOneWidget);
  });
}
