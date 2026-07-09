// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  price: (json['price'] as num).toDouble(),
  costPrice: (json['costPrice'] as num).toDouble(),
  stock: (json['stock'] as num).toInt(),
  minStock: (json['minStock'] as num).toInt(),
  supplier: json['supplier'] as String,
  imageUrl: json['imageUrl'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'price': instance.price,
  'costPrice': instance.costPrice,
  'stock': instance.stock,
  'minStock': instance.minStock,
  'supplier': instance.supplier,
  'imageUrl': instance.imageUrl,
  'status': instance.status,
};
