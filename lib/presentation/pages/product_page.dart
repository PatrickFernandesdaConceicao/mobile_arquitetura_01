import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_app/presentation/providers/auth_provider.dart';
import 'package:product_app/presentation/providers/product_provider.dart';
import 'package:product_app/presentation/pages/product_form_page.dart';
import 'package:product_app/presentation/pages/favorites_page.dart';

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productListProvider.notifier).loadProducts();
    });
  }

  Future<void> _confirmDelete(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja excluir "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(productListProvider.notifier).deleteProduct(id);
    }
  }

  void _logout(BuildContext context) {
    ref.read(authProvider.notifier).logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final state = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);
    final favCount = state.favoriteCount;
    final userName = authState.user?.firstName ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produtos'),
            if (userName.isNotEmpty)
              Text(
                'Olá, $userName',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite),
                tooltip: 'Favoritos',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesPage()),
                ),
              ),
              if (favCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$favCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => notifier.loadProducts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }
        if (state.products.isEmpty) {
          return const Center(child: Text('Nenhum produto encontrado.'));
        }
        return ListView.builder(
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            final product = state.products[index];
            return ListTile(
              onTap: () =>
                  Navigator.pushNamed(context, '/products/${product.id}'),
              tileColor: product.isFavorite
                  ? Colors.pink.withAlpha((0.2 * 255).round())
                  : null,
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: product.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => notifier.toggleFavorite(product.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductFormPage(product: product),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(product.id, product.title),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormPage()),
            ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () => notifier.loadProducts(),
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}
