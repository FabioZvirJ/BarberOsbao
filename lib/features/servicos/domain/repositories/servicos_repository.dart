import 'package:barber_osbao/features/servicos/domain/models/servico.dart';

abstract class ServicosRepository {
  Future<List<Servico>> getServicos();
  Future<Servico> createServico(Servico servico);
  Future<Servico> updateServico(Servico servico);
  Future<void> deleteServico(String id);
  Future<void> reorderServicos(List<Servico> servicos);
}
