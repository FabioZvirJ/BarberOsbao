import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> updateStock(String id, int newStock);
}

class MockProductRepository implements ProductRepository {
  final List<Product> _products = [
    const Product(
      id: 'p_1',
      name: 'Pomada Efeito Matte Premium',
      category: 'Finalizadores',
      price: 65.0,
      costPrice: 30.0,
      stock: 24,
      minStock: 5,
      supplier: 'Barber Grooming Ltda',
      imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&width=150',
      status: 'active',
    ),
    const Product(
      id: 'p_2',
      name: 'Óleo para Barba Woodsmoke',
      category: 'Cuidados com a Barba',
      price: 48.0,
      costPrice: 20.0,
      stock: 4, // low stock!
      minStock: 6,
      supplier: 'Beard Care Co.',
      imageUrl: 'https://images.unsplash.com/photo-1626015713026-d837d172406f?q=80&width=150',
      status: 'active',
    ),
    const Product(
      id: 'p_3',
      name: 'Shampoo Fortificante Mentolado',
      category: 'Cabelo',
      price: 55.0,
      costPrice: 25.0,
      stock: 15,
      minStock: 4,
      supplier: 'HairTech Indústria',
      imageUrl: 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?q=80&width=150',
      status: 'active',
    ),
    const Product(
      id: 'p_4',
      name: 'Gilete Pro-Blade Pack 100un',
      category: 'Consumíveis',
      price: 120.0,
      costPrice: 70.0,
      stock: 2, // low stock!
      minStock: 5,
      supplier: 'Gillette Professional',
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&width=150',
      status: 'active',
    ),
  ];

  @override
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_products);
  }

  @override
  Future<Product> updateStock(String id, int newStock) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = _products[index].copyWith(stock: newStock);
      _products[index] = updated;
      return updated;
    }
    throw Exception('Product not found');
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});

final productsListProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getProducts();
});
