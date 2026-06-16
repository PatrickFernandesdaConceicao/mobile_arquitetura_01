import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/core/network/client_http.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/datasources/product_cache_datasource.dart';
import 'package:product_app/data/repositories/product_repository_impl.dart';
import 'package:product_app/domain/entities/product.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/presentation/states/product_state.dart';

final httpClientProvider = Provider<HttpClient>((ref) => HttpClient());

final productRemoteDatasourceProvider = Provider<ProductRemoteDatasource>((ref) {
  return ProductRemoteDatasource(ref.watch(httpClientProvider));
});

final productCacheDatasourceProvider = Provider<ProductCacheDatasource>((ref) {
  return ProductCacheDatasourceImpl();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ref.watch(productRemoteDatasourceProvider),
    ref.watch(productCacheDatasourceProvider),
  );
});

class ProductListNotifier extends StateNotifier<ProductState> {
  final ProductRepository repository;

  ProductListNotifier(this.repository) : super(const ProductState());

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await repository.getProducts();
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleFavorite(int productId) {
    final updated = state.products
        .map((p) => p.id == productId ? p.copyWith(isFavorite: !p.isFavorite) : p)
        .toList();
    state = state.copyWith(products: updated);
  }

  Future<void> addProduct(Product product) async {
    try {
      final created = await repository.addProduct(product);
      state = state.copyWith(products: [...state.products, created]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductState>((ref) {
  return ProductListNotifier(ref.watch(productRepositoryProvider));
});

extension ProductStateX on ProductState {
  int get favoriteCount => products.where((p) => p.isFavorite).length;
}

final productByIdProvider = Provider.family<Product?, int>((ref, id) {
  final products = ref.watch(productListProvider).products;
  try {
    return products.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
