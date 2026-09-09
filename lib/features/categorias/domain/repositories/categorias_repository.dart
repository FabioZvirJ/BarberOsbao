import 'package:barber_osbao/features/categorias/domain/models/categoria.dart';

abstract class CategoriasRepository {
  Future<List<Categoria>> getCategorias();
  Future<Categoria> createCategoria(Categoria categoria);
  Future<Categoria> updateCategoria(Categoria categoria);
  Future<void> deleteCategoria(String id);
}
