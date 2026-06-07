import 'package:flutter/material.dart';

import 'foundation_choice_preview.dart';

const _harnessBackground = Color(0xFF0B1018);
const _harnessPanel = Color(0xFF111D2B);
const _harnessBorder = Color(0xFF4F6A7E);
const _harnessAccent = Color(0xFF5DDCFF);

class FoundationChoicePreviewHarness extends StatelessWidget {
  const FoundationChoicePreviewHarness({
    super.key,
    this.viewportSize = const Size(390, 844),
  });

  final Size viewportSize;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: _harnessBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _harnessAccent,
        brightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: theme,
        child: Material(
          color: _harnessBackground,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _FoundationChoiceHarnessNotice(),
                  const SizedBox(height: 14),
                  _FoundationChoiceHarnessFrame(viewportSize: viewportSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoundationChoiceHarnessNotice extends StatelessWidget {
  const _FoundationChoiceHarnessNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('foundation-choice-preview-harness-notice'),
      constraints: const BoxConstraints(maxWidth: 390),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _harnessPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _harnessBorder),
      ),
      child: const Text(
        'Lokaler Harness / keine Route / keine Speicherung / keine Screenshots',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _FoundationChoiceHarnessFrame extends StatelessWidget {
  const _FoundationChoiceHarnessFrame({required this.viewportSize});

  final Size viewportSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _harnessBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: viewportSize.width,
            height: viewportSize.height,
            child: MediaQuery(
              data: MediaQueryData(
                size: viewportSize,
                devicePixelRatio: 2,
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
              ),
              child: const FoundationChoicePreview(),
            ),
          ),
        ),
      ),
    );
  }
}
