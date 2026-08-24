// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductListController)
final productListControllerProvider = ProductListControllerProvider._();

final class ProductListControllerProvider
    extends
        $AsyncNotifierProvider<ProductListController, ProductPaginationState> {
  ProductListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productListControllerHash();

  @$internal
  @override
  ProductListController create() => ProductListController();
}

String _$productListControllerHash() =>
    r'08e14c70b2f72cbae0aff603d75fd8a685898836';

abstract class _$ProductListController
    extends $AsyncNotifier<ProductPaginationState> {
  FutureOr<ProductPaginationState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ProductPaginationState>, ProductPaginationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ProductPaginationState>,
                ProductPaginationState
              >,
              AsyncValue<ProductPaginationState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
