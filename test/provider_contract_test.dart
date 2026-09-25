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
      // Pencarian dengan keyword Cyberpunk
      final searchRes = await provider.searchMedia('Cyberpunk');
      expect(searchRes.isSuccess, isTrue);
      expect(searchRes.data!.isNotEmpty, isTrue);
      expect(
        searchRes.data!.any((m) => m.title.contains('Cyberpunk') || m.genres.contains('Cyberpunk')),
        isTrue,
      );

      // Pencarian dengan query kosong harus mengembalikan list kosong
      final emptyRes = await provider.searchMedia('   ');
      expect(emptyRes.isSuccess, isTrue);
      expect(emptyRes.data, isEmpty);
    });

    test('getMediaDetail dan getStreamSources mengembalikan data siap putar', () async {
      final detailRes = await provider.getMediaDetail('m1');
      expect(detailRes.isSuccess, isTrue);
      expect(detailRes.data, isNotNull);
      expect(detailRes.data!.id, equals('m1'));

      final sourcesRes = await provider.getStreamSources(mediaId: 'm1');
      expect(sourcesRes.isSuccess, isTrue);
      expect(sourcesRes.data!.isNotEmpty, isTrue);
      expect(sourcesRes.data!.first.url.isNotEmpty, isTrue);

      final subsRes = await provider.getSubtitles(mediaId: 'm1');
      expect(subsRes.isSuccess, isTrue);
      expect(subsRes.data!.isNotEmpty, isTrue);
    });
  });
}
