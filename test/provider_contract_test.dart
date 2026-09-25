// Pengujian Kualitas Kontrak Provider & Pencarian (*Contract & Provider Quality Gate*)
// Memvalidasi kesesuaian implementasi MockStreamProvider dengan antarmuka StreamProvider.

import 'package:flutter_test/flutter_test.dart';
import 'package:cineflow/contracts/api_contracts.dart';
import 'package:cineflow/contracts/mock_provider.dart';
import 'package:cineflow/contracts/models.dart';

void main() {
  group('MockStreamProvider Contract Tests', () {
    late StreamProvider provider;

    setUp(() {
      provider = const MockStreamProvider(simulatedDelayMs: 0);
    });

    test('getFeaturedMedia mengembalikan daftar media unggulan', () async {
      final res = await provider.getFeaturedMedia();
      expect(res.isSuccess, isTrue);
      expect(res.data, isNotNull);
      expect(res.data!.isNotEmpty, isTrue);
    });

    test('getTrending mengembalikan daftar media yang sedang tren', () async {
      final res = await provider.getTrending();
      expect(res.isSuccess, isTrue);
      expect(res.data, isNotNull);
      expect(res.data!.isNotEmpty, isTrue);
    });

    test('getByCategory menyaring konten berdasarkan kategori secara tepat', () async {
      final tvRes = await provider.getByCategory('tv_series');
      expect(tvRes.isSuccess, isTrue);
      expect(tvRes.data!.every((m) => m.type == MediaType.series), isTrue);

      final animeRes = await provider.getByCategory('anime');
      expect(animeRes.isSuccess, isTrue);
      expect(animeRes.data!.every((m) => m.type == MediaType.anime), isTrue);

      final movieRes = await provider.getByCategory('popular_movies');
      expect(movieRes.isSuccess, isTrue);
      expect(movieRes.data!.every((m) => m.type == MediaType.movie), isTrue);
    });

    test('searchMedia menemukan media berdasarkan judul dan genre', () async {
      // Pencarian dengan keyword Queen of Tears
      final searchRes = await provider.searchMedia('Queen of Tears');
      expect(searchRes.isSuccess, isTrue);
      expect(searchRes.data!.isNotEmpty, isTrue);
      expect(
        searchRes.data!.any((m) => m.title.contains('Queen of Tears')),
        isTrue,
      );

      // Pencarian dengan query kosong harus mengembalikan list kosong
      final emptyRes = await provider.searchMedia('   ');
      expect(emptyRes.isSuccess, isTrue);
      expect(emptyRes.data, isEmpty);
    });

    test('getMediaDetail dan getStreamSources mengembalikan data siap putar', () async {
      final detailRes = await provider.getMediaDetail('k1');
      expect(detailRes.isSuccess, isTrue);
      expect(detailRes.data, isNotNull);
      expect(detailRes.data!.id, equals('k1'));

      final sourcesRes = await provider.getStreamSources(mediaId: 'k1');
      expect(sourcesRes.isSuccess, isTrue);
      expect(sourcesRes.data!.isNotEmpty, isTrue);
      expect(sourcesRes.data!.first.url.isNotEmpty, isTrue);

      final subsRes = await provider.getSubtitles(mediaId: 'm1');
      expect(subsRes.isSuccess, isTrue);
      expect(subsRes.data!.isNotEmpty, isTrue);
    });

    test('Validasi Katalog 2026: Seluruh konten dirilis antara 2024 - 2026', () async {
      final allCategories = ['drakor', 'anime', 'western_series', 'hollywood', 'indonesian'];
      for (final cat in allCategories) {
        final res = await provider.getByCategory(cat);
        expect(res.isSuccess, isTrue);
        expect(res.data!.length, equals(40));
        // Tidak ada film jadul di bawah 2024
        expect(res.data!.every((m) => m.releaseYear >= 2024), isTrue);
        // Terdapat film rilisan 2026
        expect(res.data!.any((m) => m.releaseYear == 2026), isTrue);
      }
    });

    test('Validasi Multi-Mirror Video: Minimal 5 mirror CDN aktif tersedia', () async {
      final sourcesRes = await provider.getStreamSources(mediaId: 'k1');
      expect(sourcesRes.isSuccess, isTrue);
      expect(sourcesRes.data!.length, greaterThanOrEqualTo(5));
      // Terdapat opsi MP4 dan HLS
      expect(sourcesRes.data!.any((s) => s.isHls), isTrue);
      expect(sourcesRes.data!.any((s) => !s.isHls), isTrue);
      // Setiap mirror memiliki serverName yang jelas
      expect(sourcesRes.data!.every((s) => s.serverName != null && s.serverName!.isNotEmpty), isTrue);
    });
  });
}
