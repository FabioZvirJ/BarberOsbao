import 'package:barber_osbao/features/produtos/domain/models/produto.dart';
import 'package:barber_osbao/features/produtos/domain/models/movimentacao.dart';

abstract class ProdutosRepository {
  Future<List<Produto>> getProdutos();
  Future<Produto> createProduto(Produto produto);
  Future<Produto> updateProduto(Produto produto);
  Future<void> deleteProduto(String id);
  
  // Stock actions
  Future<List<MovimentacaoEstoque>> getMovimentacoes();
  Future<void> recordMovement(MovimentacaoEstoque movement);
}
