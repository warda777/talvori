// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wordListControllerHash() =>
    r'31f1c9f025e8ace6323cbfc9f62297e94e895350';

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

abstract class _$WordListController
    extends BuildlessAutoDisposeNotifier<WordListState> {
  late final String provKey;

  WordListState build(String provKey);
}

/// See also [WordListController].
@ProviderFor(WordListController)
const wordListControllerProvider = WordListControllerFamily();

/// See also [WordListController].
class WordListControllerFamily extends Family<WordListState> {
  /// See also [WordListController].
  const WordListControllerFamily();

  /// See also [WordListController].
  WordListControllerProvider call(String provKey) {
    return WordListControllerProvider(provKey);
  }

  @override
  WordListControllerProvider getProviderOverride(
    covariant WordListControllerProvider provider,
  ) {
    return call(provider.provKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'wordListControllerProvider';
}

/// See also [WordListController].
class WordListControllerProvider
    extends AutoDisposeNotifierProviderImpl<WordListController, WordListState> {
  /// See also [WordListController].
  WordListControllerProvider(String provKey)
    : this._internal(
        () => WordListController()..provKey = provKey,
        from: wordListControllerProvider,
        name: r'wordListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$wordListControllerHash,
        dependencies: WordListControllerFamily._dependencies,
        allTransitiveDependencies:
            WordListControllerFamily._allTransitiveDependencies,
        provKey: provKey,
      );

  WordListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.provKey,
  }) : super.internal();

  final String provKey;

  @override
  WordListState runNotifierBuild(covariant WordListController notifier) {
    return notifier.build(provKey);
  }

  @override
  Override overrideWith(WordListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WordListControllerProvider._internal(
        () => create()..provKey = provKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        provKey: provKey,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<WordListController, WordListState>
  createElement() {
    return _WordListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WordListControllerProvider && other.provKey == provKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, provKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WordListControllerRef on AutoDisposeNotifierProviderRef<WordListState> {
  /// The parameter `provKey` of this provider.
  String get provKey;
}

class _WordListControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<WordListController, WordListState>
    with WordListControllerRef {
  _WordListControllerProviderElement(super.provider);

  @override
  String get provKey => (origin as WordListControllerProvider).provKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
