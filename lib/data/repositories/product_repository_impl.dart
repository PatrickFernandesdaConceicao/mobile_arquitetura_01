import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/data/datasources/product_remote_datasource.dart';
import 'package:product_app/data/datasources/product_cache_datasource.dart';
import 'package:product_app/data/models/product_model.dart';
import 'package:product_app/domain/entities/product.dart';
import 'package:product_app/core/errors/failure.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remote;
  final ProductCacheDatasource cache;

  ProductRepositoryImpl(this.remote, this.cache);

  Product _toEntity(ProductModel m) => Product(
        id: m.id,
        title: m.title,
        price: m.price,
        description: m.description,
        image: m.image,
      );

  ProductModel _toModel(Product p) => ProductModel(
        id: p.id,
        title: p.title,
        price: p.price,
        description: p.description,
        image: p.image,
      );

  @override
  Future<List<Product>> getProducts() async {
    try {
      final models = await remote.getProducts();
      await cache.save(models);
      return models.map(_toEntity).toList();
    } catch (e) {
      final cached = cache.get();
      if (cached != null) return cached.map(_toEntity).toList();
      throw Failure("Não foi possível carregar os produtos");
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    try {
      final model = await remote.addProduct(_toModel(product));
      return _toEntity(model);
    } catch (e) {
      throw Failure("Não foi possível adicionar o produto");
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final model = await remote.updateProduct(_toModel(product));
      return _toEntity(model);
    } catch (e) {
      throw Failure("Não foi possível atualizar o produto");
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await remote.deleteProduct(id);
    } catch (e) {
      throw Failure("Não foi possível excluir o produto");
    }
  }
}
