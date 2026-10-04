import 'package:barber_osbao/features/categorias/domain/models/categoria.dart';
import 'package:barber_osbao/features/categorias/domain/repositories/categorias_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpCategoriasRepository implements CategoriasRepository {
  final DioClient _dioClient;

  HttpCategoriasRepository(this._dioClient);

  @override
  Future<List<Categoria>> getCategorias() async {
    final response = await _dioClient.dio.get('/categories');
    final data = response.data as List;
    return data.map((json) => Categoria.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Categoria> createCategoria(Categoria categoria) async {
    final response = await _dioClient.dio.post('/categories', data: categoria.toJson());
    return Categoria.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Categoria> updateCategoria(Categoria categoria) async {
    final response = await _dioClient.dio.put('/categories/${categoria.id}', data: categoria.toJson());
    return Categoria.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCategoria(String id) async {
    await _dioClient.dio.delete('/categories/$id');
  }
}

