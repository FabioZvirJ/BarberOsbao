import 'package:barber_osbao/features/planos/domain/models/plano.dart';

abstract class PlanosRepository {
  Future<List<Plano>> getPlanos();
  Future<Plano> createPlano(Plano plano);
  Future<Plano> updatePlano(Plano plano);
  Future<void> deletePlano(String id);
}
