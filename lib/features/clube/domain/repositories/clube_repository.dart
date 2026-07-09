import 'package:barber_osbao/features/clube/domain/models/beneficio_clube.dart';

abstract class ClubeRepository {
  Future<List<BeneficioClube>> getBeneficios();
  Future<BeneficioClube> createBeneficio(BeneficioClube beneficio);
  Future<BeneficioClube> updateBeneficio(BeneficioClube beneficio);
  Future<void> deleteBeneficio(String id);
  Future<void> reorderBeneficios(List<BeneficioClube> list);
}
