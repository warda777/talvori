import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('setMode_sets_srs_mode_directly', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = SrsModeController();
    await Future<void>.delayed(Duration.zero);

    controller.setMode(SrsSystem.adaptive);
    expect(controller.state.mode, SrsSystem.adaptive);
    expect(controller.state.lastNonHybrid, SrsSystem.adaptive);

    controller.setMode(SrsSystem.hybrid);
    expect(controller.state.mode, SrsSystem.hybrid);
    expect(controller.state.lastNonHybrid, SrsSystem.adaptive);

    controller.setMode(SrsSystem.time);
    expect(controller.state.mode, SrsSystem.time);
    expect(controller.state.lastNonHybrid, SrsSystem.time);
  });
}
