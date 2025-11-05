import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_h5p/lumi_h5p.dart';

void main() {
  test('LumiH5P initializes without errors', () async {
    final h5p = LumiH5P();

    await h5p.init();

    expect(h5p.status.value, isNotNull);
    expect(h5p.localServerUrl.value, isNull);

    await h5p.dispose();
  });
}
