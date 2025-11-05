import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_h5p/barrel.dart';
import 'package:mocktail/mocktail.dart';

class MockH5PSetup extends Mock implements H5PSetup {}

void main() {
  late H5PLoader loader;
  late MockH5PSetup mockSetup;

  setUp(() {
    mockSetup = MockH5PSetup();
    loader = H5PLoader();
    loader
      ..status.value = H5PLoadStatus.idle
      ..localServerUrl.value = null
      ..downloadProgress.value = 0;
  });

  test('initial values are correct', () {
    expect(loader.isLoading.value, false);
    expect(loader.status.value, H5PLoadStatus.idle);
    expect(loader.localServerUrl.value, isNull);
    expect(loader.downloadProgress.value, 0);
  });

  test('prepareBaseFiles calls copyBaseFiles()', () async {
    when(() => mockSetup.copyBaseFiles()).thenAnswer((_) async => '/tmp/base');
    await mockSetup.copyBaseFiles();
    verify(() => mockSetup.copyBaseFiles()).called(1);
  });

  test('loadH5P handles DioException gracefully', () async {
    await loader.closeServer();
    final result = loader.loadH5P('invalid-url');
    expect(result, completes);
  });
}
