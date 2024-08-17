import 'package:flutter_test/flutter_test.dart';
import 'package:app_chat/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('RecorderServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
