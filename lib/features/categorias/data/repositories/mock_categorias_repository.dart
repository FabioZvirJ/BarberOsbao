import 'package:barber_osbao/features/categorias/domain/models/categoria.dart';
import 'package:barber_osbao/features/categorias/domain/repositories/categorias_repository.dart';

class MockCategoriasRepository implements CategoriasRepository {
  final List<Categoria> _categorias = [
    const Categoria(id: 'cat_1', nome: 'Cabelo', tipo: 'servicos'),
    const Categoria(id: 'cat_2', nome: 'Barba', tipo: 'servicos'),
    const Categoria(id: 'cat_3', nome: 'Sobrancelha', tipo: 'servicos'),
    const Categoria(id: 'cat_4', nome: 'Combo', tipo: 'servicos'),
    const Categoria(id: 'cat_5', nome: 'Finalizadores', tipo: 'produtos'),
    const Categoria(id: 'cat_6', nome: 'Cuidados com a Barba', tipo: 'produtos'),
    const Categoria(id: 'cat_7', nome: 'Cabelo', tipo: 'produtos'),
    const Categoria(id: 'cat_8', nome: 'Consumíveis', tipo: 'produtos'),
    const Categoria(id: 'cat_9', nome: 'Mensal', tipo: 'planos'),
    const Categoria(id: 'cat_10', nome: 'Trimestral', tipo: 'planos'),
    const Categoria(id: 'cat_11', nome: 'Semestral', tipo: 'planos'),
    const Categoria(id: 'cat_12', nome: 'Anual', tipo: 'planos'),
  ];

  @override
  Future<List<Categoria>> getCategorias() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_categorias);
  }

  @override
  Future<Categoria> createCategoria(Categoria categoria) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newCat = categoria.copyWith(id: 'cat_${DateTime.now().millisecondsSinceEpoch}');
    _categorias.add(newCat);
    return newCat;
  }

  @override
  Future<Categoria> updateCategoria(Categoria categoria) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _categorias.indexWhere((c) => c.id == categoria.id);
    if (index != -1) {
      _categorias[index] = categoria;
      return categoria;
    }
    throw Exception('Categoria não encontrada');
  }

  @override
  Future<void> deleteCategoria(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _categorias.removeWhere((c) => c.id == id);
  }
}
