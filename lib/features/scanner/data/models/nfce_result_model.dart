// Espelha InvoiceResponseDTO / InvoiceItemDTO (resposta dentro do envelope ApiResponseDTO).
import '../../domain/entities/nfce_result_entity.dart';

class NfceResultModel extends NfceResultEntity {
  const NfceResultModel({
    required super.id,
    required super.chaveAcesso,
    required super.emitente,
    required super.dataEmissao,
    required super.valorTotal,
    required super.itens,
  });

  factory NfceResultModel.fromJson(Map<String, dynamic> json) {
    final rawItens = (json['items'] as List<dynamic>? ?? []);
    return NfceResultModel(
      id: json['id'].toString(),
      chaveAcesso: json['invoiceKey'] as String? ?? '',
      emitente: json['supplierName'] as String? ?? '',
      dataEmissao: json['purchaseDate'] as String? ?? '',
      valorTotal: (json['totalValue'] as num?)?.toDouble() ?? 0,
      itens: rawItens
          .map((e) => NfceItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NfceItemModel extends NfceItemEntity {
  const NfceItemModel({
    required super.descricao,
    super.ean,
    required super.quantidade,
    required super.unidade,
    required super.valorUnitario,
    required super.valorTotal,
  });

  factory NfceItemModel.fromJson(Map<String, dynamic> json) {
    return NfceItemModel(
      descricao: json['productName'] as String? ?? '',
      ean: json['productEan'] as String?,
      quantidade: (json['quantity'] as num?)?.toDouble() ?? 1,
      unidade: json['unit'] as String? ?? 'UN',
      valorUnitario: (json['unitValue'] as num?)?.toDouble() ?? 0,
      valorTotal: (json['totalValue'] as num?)?.toDouble() ?? 0,
    );
  }
}
