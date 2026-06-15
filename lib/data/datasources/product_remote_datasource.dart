import 'dart:convert';
import 'package:product_app/data/models/product_model.dart';
import 'package:product_app/core/network/client_http.dart';

class ProductRemoteDatasource {
  final HttpClient client;
  static const _baseUrl = "https://dummyjson.com/products";

  ProductRemoteDatasource(this.client);

  Future<List<ProductModel>> getProducts() async {
    final response = await client.get('$_baseUrl/category/smartphones');
    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar produtos: ${response.statusCode}');
    }
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List data = body['products'] as List;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await client.post(
      '$_baseUrl/add',
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar produto: ${response.statusCode}');
    }
    return ProductModel.fromJson(jsonDecode(response.body));
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await client.put(
      '$_baseUrl/${product.id}',
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar produto: ${response.statusCode}');
    }
    return ProductModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteProduct(int id) async {
    final response = await client.delete('$_baseUrl/$id');
    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir produto: ${response.statusCode}');
    }
  }
}
