import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/presentation/providers/product_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);
    final favorites = state.products.where((p) => p.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos (${favorites.length})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum favorito ainda.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                return ListTile(
                  onTap: () =>
                      Navigator.pushNamed(context, '/products/${product.id}'),
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(product.title),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    tooltip: 'Remover dos favoritos',
                    onPressed: () => notifier.toggleFavorite(product.id),
                  ),
                );
              },
            ),
    );
  }
}
