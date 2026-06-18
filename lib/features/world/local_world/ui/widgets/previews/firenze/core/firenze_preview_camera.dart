import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart' show Matrix4;

const firenzePreviewCityCanvasWidth = 1672.0;
const firenzePreviewCityCanvasHeight = 941.0;
const firenzePreviewScenicPaddingX = 260.0;
const firenzePreviewScenicPaddingY = 170.0;
const firenzePreviewWorldWidth =
    firenzePreviewCityCanvasWidth + firenzePreviewScenicPaddingX * 2;
const firenzePreviewWorldHeight =
    firenzePreviewCityCanvasHeight + firenzePreviewScenicPaddingY * 2;

const firenzePreviewWorldRect = Rect.fromLTWH(
  0,
  0,
  firenzePreviewWorldWidth,
  firenzePreviewWorldHeight,
);
const firenzePreviewCityRect = Rect.fromLTWH(
  firenzePreviewScenicPaddingX,
  firenzePreviewScenicPaddingY,
  firenzePreviewCityCanvasWidth,
  firenzePreviewCityCanvasHeight,
);

class FirenzePreviewCameraLayout {
  const FirenzePreviewCameraLayout({
    required this.viewportSize,
    required this.worldRect,
    required this.cityRect,
    required this.hardMinScale,
    required this.overviewScale,
    required this.maxScale,
    required this.initialTranslation,
  });

  factory FirenzePreviewCameraLayout.fromViewport(Size viewportSize) {
    final hardMinScale = FirenzePreviewCameraMath.minScaleFor(
      viewportSize: viewportSize,
      worldSize: firenzePreviewWorldRect.size,
    );
    final cityWidthTarget =
        viewportSize.width * 0.82 / firenzePreviewCityRect.width;
    final cityHeightTarget =
        viewportSize.height * 0.82 / firenzePreviewCityRect.height;
    final desiredOverviewScale = math.max(cityWidthTarget, cityHeightTarget);
    final maxScale = math.max(hardMinScale * 5.2, hardMinScale + 0.01);
    final overviewScale = desiredOverviewScale
        .clamp(hardMinScale, maxScale)
        .toDouble();
    final layout = FirenzePreviewCameraLayout(
      viewportSize: viewportSize,
      worldRect: firenzePreviewWorldRect,
      cityRect: firenzePreviewCityRect,
      hardMinScale: hardMinScale,
      overviewScale: overviewScale,
      maxScale: maxScale,
      initialTranslation: Offset.zero,
    );
    final initial = layout.overviewTransform();
    return FirenzePreviewCameraLayout(
      viewportSize: viewportSize,
      worldRect: firenzePreviewWorldRect,
      cityRect: firenzePreviewCityRect,
      hardMinScale: hardMinScale,
      overviewScale: overviewScale,
      maxScale: maxScale,
      initialTranslation: Offset(initial.storage[12], initial.storage[13]),
    );
  }

  final Size viewportSize;
  final Rect worldRect;
  final Rect cityRect;
  final double hardMinScale;
  final double overviewScale;
  final double maxScale;
  final Offset initialTranslation;

  double clampScale(double scale) {
    return scale.clamp(hardMinScale, maxScale).toDouble();
  }

  Matrix4 overviewTransform() {
    return transformForWorldPoint(cityRect.center, scale: overviewScale);
  }

  Matrix4 returnToOverviewTransform() {
    return overviewTransform();
  }

  Matrix4 arrivalStartTransform() {
    final introFocus = cityRect.center.translate(
      -cityRect.width * 0.12,
      -cityRect.height * 0.08,
    );
    final introScale = math.min(
      math.max(overviewScale * 1.12, hardMinScale),
      maxScale,
    );
    return transformForWorldPoint(
      introFocus,
      scale: introScale,
      verticalBias: 0.02,
    );
  }

  Matrix4 targetFocusTransform(
    Offset normalizedFocus, {
    required double scale,
    double verticalBias = 0.06,
  }) {
    return transformForNormalizedWorldFocus(
      normalizedFocus,
      scale: scale,
      verticalBias: verticalBias,
    );
  }

  Matrix4 travelFollowTransform(
    Offset normalizedFocus, {
    required double scale,
    double verticalBias = 0.02,
  }) {
    return transformForNormalizedWorldFocus(
      normalizedFocus,
      scale: scale,
      verticalBias: verticalBias,
    );
  }

  Matrix4 transformForNormalizedWorldFocus(
    Offset normalizedFocus, {
    required double scale,
    double verticalBias = 0,
  }) {
    return transformForWorldPoint(
      Offset(
        normalizedFocus.dx * worldRect.width,
        normalizedFocus.dy * worldRect.height,
      ),
      scale: scale,
      verticalBias: verticalBias,
    );
  }

  Matrix4 transformForWorldPoint(
    Offset worldFocus, {
    required double scale,
    double verticalBias = 0,
  }) {
    final safeScale = clampScale(scale);
    final viewportFocus = Offset(
      viewportSize.width / 2,
      viewportSize.height * (0.5 - verticalBias),
    );
    final translation = clampTranslation(
      viewportFocus - worldFocus * safeScale,
      safeScale,
    );
    return Matrix4.identity()
      ..setEntry(0, 0, safeScale)
      ..setEntry(1, 1, safeScale)
      ..setEntry(0, 3, translation.dx)
      ..setEntry(1, 3, translation.dy);
  }

  Offset clampTranslation(Offset translation, double scale) {
    final safeScale = clampScale(scale);
    final scaledWidth = worldRect.width * safeScale;
    final scaledHeight = worldRect.height * safeScale;
    return Offset(
      FirenzePreviewCameraMath.clampAxis(
        translation.dx,
        viewportSize.width,
        scaledWidth,
      ),
      FirenzePreviewCameraMath.clampAxis(
        translation.dy,
        viewportSize.height,
        scaledHeight,
      ),
    );
  }

  Matrix4 clampMatrix(Matrix4 matrix) {
    return FirenzePreviewCameraMath.clampMatrix(
      matrix,
      viewportSize: viewportSize,
      worldSize: worldRect.size,
      minScale: hardMinScale,
      maxScale: maxScale,
    );
  }
}

class FirenzePreviewCameraViewportTransition {
  const FirenzePreviewCameraViewportTransition({
    required this.previousLayout,
    required this.nextLayout,
    required this.nextMatrix,
  });

  factory FirenzePreviewCameraViewportTransition.fromViewports({
    required Size previousViewportSize,
    required Size nextViewportSize,
    Matrix4? previousMatrix,
    bool resetToOverview = true,
  }) {
    final previousLayout = FirenzePreviewCameraLayout.fromViewport(
      previousViewportSize,
    );
    final nextLayout = FirenzePreviewCameraLayout.fromViewport(
      nextViewportSize,
    );
    final nextMatrix = resetToOverview
        ? nextLayout.overviewTransform()
        : nextLayout.clampMatrix(
            previousMatrix ?? nextLayout.overviewTransform(),
          );
    return FirenzePreviewCameraViewportTransition(
      previousLayout: previousLayout,
      nextLayout: nextLayout,
      nextMatrix: nextMatrix,
    );
  }

  final FirenzePreviewCameraLayout previousLayout;
  final FirenzePreviewCameraLayout nextLayout;
  final Matrix4 nextMatrix;
}

class FirenzePreviewCameraMath {
  const FirenzePreviewCameraMath._();

  static double minScaleFor({
    required Size viewportSize,
    required Size worldSize,
  }) {
    if (viewportSize.width <= 0 ||
        viewportSize.height <= 0 ||
        worldSize.width <= 0 ||
        worldSize.height <= 0) {
      return 0.1;
    }
    return math.max(
      viewportSize.width / worldSize.width,
      viewportSize.height / worldSize.height,
    );
  }

  static Matrix4 clampMatrix(
    Matrix4 matrix, {
    required Size viewportSize,
    required Size worldSize,
    required double minScale,
    required double maxScale,
  }) {
    final scale = matrix.storage[0].clamp(minScale, maxScale).toDouble();
    final scaledWidth = worldSize.width * scale;
    final scaledHeight = worldSize.height * scale;
    final dx = clampAxis(matrix.storage[12], viewportSize.width, scaledWidth);
    final dy = clampAxis(matrix.storage[13], viewportSize.height, scaledHeight);
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, dx)
      ..setEntry(1, 3, dy);
  }

  static double clampAxis(double translation, double viewport, double scaled) {
    if (scaled <= viewport) {
      return (viewport - scaled) / 2;
    }
    return translation.clamp(viewport - scaled, 0).toDouble();
  }
}

class FirenzePreviewCameraGesture {
  const FirenzePreviewCameraGesture._();

  static Matrix4 update({
    required Matrix4 startMatrix,
    required Offset startFocalPoint,
    required Offset currentFocalPoint,
    required double scaleFactor,
    required FirenzePreviewCameraLayout layout,
  }) {
    final startScale = startMatrix.storage[0];
    final startTranslation = Offset(
      startMatrix.storage[12],
      startMatrix.storage[13],
    );
    final safeStartScale = startScale == 0 ? layout.hardMinScale : startScale;
    final worldFocalPoint =
        (startFocalPoint - startTranslation) / safeStartScale;
    final targetScale = (safeStartScale * scaleFactor)
        .clamp(layout.hardMinScale, layout.maxScale)
        .toDouble();
    final targetTranslation = currentFocalPoint - worldFocalPoint * targetScale;
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, targetScale)
      ..setEntry(1, 1, targetScale)
      ..setEntry(0, 3, targetTranslation.dx)
      ..setEntry(1, 3, targetTranslation.dy);
    return layout.clampMatrix(matrix);
  }
}
