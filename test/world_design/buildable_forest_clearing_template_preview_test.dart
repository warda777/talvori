import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _baseAssetPath =
    'assets/images/world/buildable_islands/forest_clearing/base.png';
const _foundationAssetPath =
    'assets/images/world/buildable_islands/forest_clearing/foundation_started.png';

const _phoneWidth = 430.0;
const _phoneHeight = 932.0;
const _assetSize = Size(1536, 1024);
const _phoneSize = Size(_phoneWidth, _phoneHeight);
const _mainBuildAreaAnchor = Offset(0.511, 0.508);
const _foundationOverlayAnchor = Offset(0.511, 0.508);
const _focusCameraTarget = Offset(0.511, 0.508);
const _visualBounds = Rect.fromLTRB(0.031, 0.028, 0.960, 0.948);
const _logicalBounds = Rect.fromLTRB(0.031, 0.028, 0.960, 0.948);
const _foundationVisibleBounds = Rect.fromLTRB(0.374, 0.412, 0.648, 0.604);
const _placementBounds = Rect.fromLTRB(0.355, 0.385, 0.670, 0.635);
const _hitTestRadii = Size(0.180, 0.120);

void main() {
  testWidgets(
    'validates forest clearing preview anchors in an isolated portrait harness',
    (tester) async {
      expect(_readPngSize(File(_baseAssetPath)), _assetSize);
      expect(_readPngSize(File(_foundationAssetPath)), _assetSize);
      expect(_visualBounds.contains(_mainBuildAreaAnchor), isTrue);
      expect(_logicalBounds.contains(_mainBuildAreaAnchor), isTrue);
      expect(_placementBounds.contains(_foundationOverlayAnchor), isTrue);
      expect(
        _foundationVisibleBounds.contains(_foundationOverlayAnchor),
        isTrue,
      );

      final fullLayout = _PreviewLayout.fullPortrait();
      final focusLayout = _PreviewLayout.islandViewFocus();
      final fullPlacement = fullLayout.normalizedRectToScreen(_placementBounds);
      final fullHitTarget = fullLayout.hitTargetSize(_hitTestRadii);
      final focusPlacement = focusLayout.normalizedRectToScreen(
        _placementBounds,
      );

      expect(fullHitTarget.width, greaterThan(44));
      expect(fullHitTarget.height, greaterThan(44));
      expect(_topUiReservedZone.overlaps(fullPlacement), isFalse);
      expect(_bottomUiReservedZone.overlaps(fullPlacement), isFalse);
      expect(_topUiReservedZone.overlaps(focusPlacement), isFalse);
      expect(_bottomUiReservedZone.overlaps(focusPlacement), isFalse);

      await _pumpPreviewHarness(
        tester,
        layout: fullLayout,
        showFoundation: false,
        showDebug: false,
      );
      await _pumpPreviewHarness(
        tester,
        layout: fullLayout,
        showFoundation: true,
        showDebug: true,
      );
      await _pumpPreviewHarness(
        tester,
        layout: focusLayout,
        showFoundation: true,
        showDebug: true,
      );
    },
  );
}

const _topUiReservedZone = Rect.fromLTWH(0, 0, _phoneWidth, 82);
const _bottomUiReservedZone = Rect.fromLTWH(
  0,
  _phoneHeight - 108,
  _phoneWidth,
  108,
);

Size _readPngSize(File file) {
  final bytes = file.readAsBytesSync();
  expect(bytes.length, greaterThan(24));
  final data = ByteData.sublistView(bytes);
  return Size(
    data.getUint32(16, Endian.big).toDouble(),
    data.getUint32(20, Endian.big).toDouble(),
  );
}

Future<void> _pumpPreviewHarness(
  WidgetTester tester, {
  required _PreviewLayout layout,
  required bool showFoundation,
  required bool showDebug,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: _phoneSize.width,
        height: _phoneSize.height,
        child: CustomPaint(
          painter: _ForestClearingPreviewPainter(
            layout: layout,
            showFoundation: showFoundation,
            showDebug: showDebug,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  expect(find.byType(CustomPaint), findsOneWidget);
}

class _ForestClearingPreviewPainter extends CustomPainter {
  const _ForestClearingPreviewPainter({
    required this.layout,
    required this.showFoundation,
    required this.showDebug,
  });

  final _PreviewLayout layout;
  final bool showFoundation;
  final bool showDebug;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.islandRect, const Radius.circular(14)),
      Paint()..color = const Color(0xAA789B4A),
    );
    if (showFoundation) {
      canvas.drawRect(
        layout.normalizedRectToScreen(_foundationVisibleBounds),
        Paint()..color = const Color(0xCCBDA16D),
      );
    }
    if (showDebug) {
      _paintDebug(canvas);
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF050815),
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      280,
      Paint()..color = const Color(0x20263462),
    );
    canvas.drawRect(
      _topUiReservedZone,
      Paint()..color = const Color(0x3A000000),
    );
    canvas.drawRect(
      _bottomUiReservedZone,
      Paint()..color = const Color(0x44000000),
    );
    _drawReservedPill(canvas, const Rect.fromLTWH(18, 20, 100, 20));
    _drawReservedPill(canvas, Rect.fromLTWH(size.width - 118, 20, 100, 20));
    _drawReservedPill(
      canvas,
      Rect.fromLTWH(size.width / 2 - 44, size.height - 64, 88, 30),
    );
  }

  void _drawReservedPill(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x446E86C8),
    );
  }

  void _paintDebug(Canvas canvas) {
    _drawRect(canvas, _visualBounds, const Color(0x334C89FF), 'visual');
    _drawRect(canvas, _placementBounds, const Color(0x8832D6B4), 'place');
    _drawRect(
      canvas,
      _foundationVisibleBounds,
      const Color(0x88FFC857),
      'overlay',
    );
    _drawHitEllipse(canvas);
    _drawAnchor(canvas, _mainBuildAreaAnchor, const Color(0xFFEFF6A0));
  }

  void _drawRect(Canvas canvas, Rect normalized, Color color, String label) {
    final rect = layout.normalizedRectToScreen(normalized);
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color,
    );
    _drawLabel(canvas, label, rect.topLeft + const Offset(4, 4), color);
  }

  void _drawHitEllipse(Canvas canvas) {
    final center = layout.normalizedPointToScreen(_mainBuildAreaAnchor);
    final radii = layout.hitTargetSize(_hitTestRadii);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radii.width, height: radii.height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xAA94FF7D),
    );
  }

  void _drawAnchor(Canvas canvas, Offset normalized, Color color) {
    final point = layout.normalizedPointToScreen(normalized);
    canvas.drawCircle(point, 4, Paint()..color = color);
    canvas.drawLine(
      point + const Offset(-8, 0),
      point + const Offset(8, 0),
      Paint()
        ..strokeWidth = 1
        ..color = color,
    );
    canvas.drawLine(
      point + const Offset(0, -8),
      point + const Offset(0, 8),
      Paint()
        ..strokeWidth = 1
        ..color = color,
    );
  }

  void _drawLabel(Canvas canvas, String label, Offset offset, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color.withValues(alpha: 0.95),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ForestClearingPreviewPainter oldDelegate) {
    return oldDelegate.layout != layout ||
        oldDelegate.showFoundation != showFoundation ||
        oldDelegate.showDebug != showDebug;
  }
}

class _PreviewLayout {
  const _PreviewLayout._(this.islandRect);

  factory _PreviewLayout.fullPortrait() {
    final targetWidth = 410.0;
    final targetHeight = targetWidth * _assetSize.height / _assetSize.width;
    return _PreviewLayout._(Rect.fromLTWH(10, 286, targetWidth, targetHeight));
  }

  factory _PreviewLayout.islandViewFocus() {
    final targetWidth = 600.0;
    final targetHeight = targetWidth * _assetSize.height / _assetSize.width;
    final scale = targetWidth / _assetSize.width;
    return _PreviewLayout._(
      Rect.fromLTWH(
        _phoneSize.width / 2 - _focusCameraTarget.dx * _assetSize.width * scale,
        438 - _focusCameraTarget.dy * _assetSize.height * scale,
        targetWidth,
        targetHeight,
      ),
    );
  }

  final Rect islandRect;

  Offset normalizedPointToScreen(Offset normalized) {
    return Offset(
      islandRect.left + islandRect.width * normalized.dx,
      islandRect.top + islandRect.height * normalized.dy,
    );
  }

  Rect normalizedRectToScreen(Rect normalized) {
    return Rect.fromLTRB(
      islandRect.left + islandRect.width * normalized.left,
      islandRect.top + islandRect.height * normalized.top,
      islandRect.left + islandRect.width * normalized.right,
      islandRect.top + islandRect.height * normalized.bottom,
    );
  }

  Size hitTargetSize(Size normalizedRadii) {
    return Size(
      islandRect.width * normalizedRadii.width * 2,
      islandRect.height * normalizedRadii.height * 2,
    );
  }
}
