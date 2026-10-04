import 'package:barber_osbao/features/produtos/domain/models/produto.dart';
import 'package:barber_osbao/features/produtos/domain/models/movimentacao.dart';
import 'package:barber_osbao/features/produtos/domain/repositories/produtos_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpProdutosRepository implements ProdutosRepository {
  final DioClient _dioClient;

  HttpProdutosRepository(this._dioClient);

  @override
  Future<List<Produto>> getProdutos() async {
    final response = await _dioClient.dio.get('/products');
    final data = response.data as List;
    return data.map((json) => Produto.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Produto> createProduto(Produto produto) async {
    final response = await _dioClient.dio.post('/products', data: produto.toJson());
    return Produto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Produto> updateProduto(Produto produto) async {
    final response = await _dioClient.dio.put('/products/${produto.id}', data: produto.toJson());
    return Produto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduto(String id) async {
    await _dioClient.dio.delete('/products/$id');
  }

  @override
  Future<List<MovimentacaoEstoque>> getMovimentacoes() async {
    final response = await _dioClient.dio.get('/products/movements');
    final data = response.data as List;
    return data.map((json) => MovimentacaoEstoque.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> recordMovement(MovimentacaoEstoque movement) async {
    await _dioClient.dio.post('/products/movements', data: movement.toJson());
  }
}

