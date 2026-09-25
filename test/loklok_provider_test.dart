// Pengujian Kualitas LoklokStreamProvider (*LokLok Provider Quality Gate*)
// Memvalidasi integrasi adapter REST API LokLok dengan ketahanan fallback transparan.

import 'package:flutter_test/flutter_test.dart';
import 'package:cineflow/contracts/loklok_provider.dart';
import 'package:cineflow/contracts/mock_provider.dart';

void main() {
  group('LoklokStreamProvider Tests', () {
    late LoklokStreamProvider provider;

    setUp(() {
      provider = const LoklokStreamProvider(
        timeoutSeconds: 1, // Timeout cepat untuk pengujian unit headless
        fallbackProvider: MockStreamProvider(simulatedDelayMs: 0),
      );
    });

    test('getFeaturedMedia mengembalikan data valid (lokal atau remote)', () async {
      final res = await provider.getFeaturedMedia();
      expect(res.isSuccess, isTrue);
      expect(res.data, isNotNull);
      expect(res.data!.isNotEmpty, isTrue);
    });

    test('searchMedia menangani pencarian kata kunci dengan proteksi fallback', () async {
      final res = await provider.searchMedia('Solo Leveling');
      expect(res.isSuccess, isTrue);
      expect(res.data, isNotNull);
      expect(res.data!.isNotEmpty, isTrue);
    });

    test('getMediaDetail dan getStreamSources mengembalikan detail dan sumber pemutaran', () async {
      final detailRes = await provider.getMediaDetail('a1');
      expect(detailRes.isSuccess, isTrue);
      expect(detailRes.data, isNotNull);

      final sourcesRes = await provider.getStreamSources(mediaId: 'a1');
      expect(sourcesRes.isSuccess, isTrue);
      expect(sourcesRes.data, isNotNull);
      expect(sourcesRes.data!.isNotEmpty, isTrue);
    });
  });
}
