import '../../domain/entities/nfce_result_entity.dart';

class NfceResultModel extends NfceResultEntity {
  const NfceResultModel({
    required super.chaveAcesso,
    required super.emitente,
    required super.dataEmissao,
    required super.valorTotal,
    required super.itens,
  });

  factory NfceResultModel.fromJson(Map<String, dynamic> json) {
    final rawItens = (json['itens'] as List<dynamic>? ?? []);
    return NfceResultModel(
      chaveAcesso: json['chaveAcesso'] as String? ?? '',
      emitente: json['emitente'] as String? ?? '',
      dataEmissao: json['dataEmissao'] as String? ?? '',
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0,
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
      descricao: json['descricao'] as String? ?? '',
      ean: json['ean'] as String?,
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 1,
      unidade: json['unidade'] as String? ?? 'UN',
      valorUnitario: (json['valorUnitario'] as num?)?.toDouble() ?? 0,
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}
