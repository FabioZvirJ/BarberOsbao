import 'package:barber_osbao/features/produtos/domain/models/produto.dart';
import 'package:barber_osbao/features/produtos/domain/models/movimentacao.dart';
import 'package:barber_osbao/features/produtos/domain/repositories/produtos_repository.dart';

class MockProdutosRepository implements ProdutosRepository {
  final List<Produto> _produtos = [
    const Produto(
      id: 'p_1',
      name: 'Pomada Efeito Matte Premium',
      brand: 'BarberGroom',
      category: 'Finalizadores',
      supplier: 'Barber Grooming Ltda',
      code: 'PROD001',
      costPrice: 30.0,
      price: 65.0,
      stock: 24,
      minStock: 5,
      description: 'Pomada modeladora de alta fixação com efeito seco e opaco.',
      status: true,
      imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&width=150',
    ),
    const Produto(
      id: 'p_2',
      name: 'Óleo para Barba Woodsmoke',
      brand: 'BeardCare',
      category: 'Cuidados com a Barba',
      supplier: 'Beard Care Co.',
      code: 'PROD002',
      costPrice: 20.0,
      price: 48.0,
      stock: 4, // low stock!
      minStock: 6,
      description: 'Hidrata a barba e perfuma com essência amadeirada sutil.',
      status: true,
      imageUrl: 'https://images.unsplash.com/photo-1626015713026-d837d172406f?q=80&width=150',
    ),
    const Produto(
      id: 'p_3',
      name: 'Shampoo Fortificante Mentolado',
      brand: 'HairTech',
      category: 'Cabelo',
      supplier: 'HairTech Indústria',
      code: 'PROD003',
      costPrice: 25.0,
      price: 55.0,
      stock: 15,
      minStock: 4,
      description: 'Shampoo refrescante anticaspa e de crescimento capilar.',
      status: true,
      imageUrl: 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?q=80&width=150',
    ),
    const Produto(
      id: 'p_4',
      name: 'Gilete Pro-Blade Pack 100un',
      brand: 'Gillette',
      category: 'Consumíveis',
      supplier: 'Gillette Professional',
      code: 'PROD004',
      costPrice: 70.0,
      price: 120.0,
      stock: 2, // low stock!
      minStock: 5,
      description: 'Lâminas profissionais de aço inoxidável para acabamento perfeito.',
      status: true,
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&width=150',
    ),
  ];

  final List<MovimentacaoEstoque> _movimentacoes = [
    const MovimentacaoEstoque(id: 'm_1', productId: 'p_1', productName: 'Pomada Efeito Matte Premium', type: 'Entrada', qty: 12, reason: 'Compra fornecedor', date: '08/07/2026', user: 'Fábio Zvir'),
    const MovimentacaoEstoque(id: 'm_2', productId: 'p_2', productName: 'Óleo para Barba Woodsmoke', type: 'Saída', qty: 1, reason: 'Venda cliente', date: '08/07/2026', user: 'Arthur Santos'),
    const MovimentacaoEstoque(id: 'm_3', productId: 'p_4', productName: 'Gilete Pro-Blade Pack 100un', type: 'Saída', qty: 1, reason: 'Uso interno cabine', date: '07/07/2026', user: 'Marcos Silva'),
    const MovimentacaoEstoque(id: 'm_4', productId: 'p_3', productName: 'Shampoo Fortificante Mentolado', type: 'Entrada', qty: 6, reason: 'Ajuste inventário', date: '05/07/2026', user: 'Fábio Zvir'),
  ];

  @override
  Future<List<Produto>> getProdutos() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_produtos);
  }

  @override
  Future<Produto> createProduto(Produto produto) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newProd = produto.copyWith(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
    );
    _produtos.add(newProd);
    return newProd;
  }

  @override
  Future<Produto> updateProduto(Produto produto) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _produtos.indexWhere((p) => p.id == produto.id);
    if (index != -1) {
      // Record movement automatically if stock changed
      final oldStock = _produtos[index].stock;
      if (oldStock != produto.stock) {
        final difference = (produto.stock - oldStock).abs();
        final type = produto.stock > oldStock ? 'Entrada' : 'Saída';
        _movimentacoes.add(MovimentacaoEstoque(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          productId: produto.id,
          productName: produto.name,
          type: type,
          qty: difference,
          reason: 'Ajuste manual',
          date: '09/07/2026',
          user: 'Fábio Zvir',
        ));
      }
      _produtos[index] = produto;
      return produto;
    }
    throw Exception('Produto não encontrado');
  }

  @override
  Future<void> deleteProduto(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _produtos.removeWhere((p) => p.id == id);
  }

  @override
  Future<List<MovimentacaoEstoque>> getMovimentacoes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_movimentacoes);
  }

  @override
  Future<void> recordMovement(MovimentacaoEstoque movement) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _movimentacoes.add(movement);
    
    // Update product stock accordingly
    final idx = _produtos.indexWhere((p) => p.id == movement.productId);
    if (idx != -1) {
      final p = _produtos[idx];
      int newStock = p.stock;
      if (movement.type == 'Entrada') {
        newStock += movement.qty;
      } else if (movement.type == 'Saída') {
        newStock = (newStock - movement.qty).clamp(0, 999999);
      } else if (movement.type == 'Inventário') {
        newStock = movement.qty;
      }
      _produtos[idx] = p.copyWith(stock: newStock);
    }
  }
}
