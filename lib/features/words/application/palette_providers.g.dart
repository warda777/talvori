// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palette_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryTintHash() => r'b647ce81fb46bfe5815f4acecd4a53a2f334d6f2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [categoryTint].
@ProviderFor(categoryTint)
const categoryTintProvider = CategoryTintFamily();

/// See also [categoryTint].
class CategoryTintFamily extends Family<Color?> {
  /// See also [categoryTint].
  const CategoryTintFamily();

  /// See also [categoryTint].
  CategoryTintProvider call(String categoryId) {
    return CategoryTintProvider(categoryId);
  }

  @override
  CategoryTintProvider getProviderOverride(
    covariant CategoryTintProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryTintProvider';
}

/// See also [categoryTint].
class CategoryTintProvider extends AutoDisposeProvider<Color?> {
  /// See also [categoryTint].
  CategoryTintProvider(String categoryId)
    : this._internal(
        (ref) => categoryTint(ref as CategoryTintRef, categoryId),
        from: categoryTintProvider,
        name: r'categoryTintProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$categoryTintHash,
        dependencies: CategoryTintFamily._dependencies,
        allTransitiveDependencies:
            CategoryTintFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  CategoryTintProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(Color? Function(CategoryTintRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: CategoryTintProvider._internal(
        (ref) => create(ref as CategoryTintRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Color?> createElement() {
    return _CategoryTintProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryTintProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryTintRef on AutoDisposeProviderRef<Color?> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _CategoryTintProviderElement extends AutoDisposeProviderElement<Color?>
    with CategoryTintRef {
  _CategoryTintProviderElement(super.provider);

  @override
  String get categoryId => (origin as CategoryTintProvider).categoryId;
}

String _$isApplyAllHash() => r'b9a28e361b51cff9865ea349119bc4826fe4b359';

/// See also [isApplyAll].
@ProviderFor(isApplyAll)
final isApplyAllProvider = AutoDisposeProvider<bool>.internal(
  isApplyAll,
  name: r'isApplyAllProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isApplyAllHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsApplyAllRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
