/// Allowed desktop UI zoom steps (percent).
abstract final class DesktopUiScale {
  static const List<int> steps = [70, 80, 90, 100, 110, 115, 120, 130];

  static int minPercent = steps.first;
  static int maxPercent = steps.last;

  static int normalizePercent(int percent) {
    final clamped = percent.clamp(minPercent, maxPercent);
    if (steps.contains(clamped)) return clamped;

    var best = steps.first;
    var bestDelta = (best - clamped).abs();
    for (var i = 1; i < steps.length; i++) {
      final step = steps[i];
      final delta = (step - clamped).abs();
      if (delta < bestDelta) {
        best = step;
        bestDelta = delta;
      }
    }
    return best;
  }

  static int stepIndexForPercent(int percent) {
    return steps.indexOf(normalizePercent(percent));
  }

  static int percentForStepIndex(int index) {
    final i = index.clamp(0, steps.length - 1);
    return steps[i];
  }

  static double scaleFactorForPercent(int percent) {
    return normalizePercent(percent) / 100.0;
  }
}
