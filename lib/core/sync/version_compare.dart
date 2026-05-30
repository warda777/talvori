enum VersionComparison { older, same, newer, invalid }

class VersionCompare {
  const VersionCompare._();

  static VersionComparison compare(String left, String right) {
    final leftParts = _parse(left);
    final rightParts = _parse(right);
    if (leftParts == null || rightParts == null) {
      return VersionComparison.invalid;
    }

    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < length; index++) {
      final leftPart = index < leftParts.length ? leftParts[index] : 0;
      final rightPart = index < rightParts.length ? rightParts[index] : 0;
      if (leftPart < rightPart) return VersionComparison.older;
      if (leftPart > rightPart) return VersionComparison.newer;
    }
    return VersionComparison.same;
  }

  static List<int>? _parse(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split('.');
    if (parts.any((part) => part.isEmpty)) return null;

    final parsed = <int>[];
    for (final part in parts) {
      if (!RegExp(r'^\d+$').hasMatch(part)) return null;
      parsed.add(int.parse(part));
    }
    return parsed;
  }
}
