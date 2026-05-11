class NfceResultEntity {
  final String chaveAcesso;
  final String emitente;
  final String dataEmissao;
  final double valorTotal;
  final List<NfceItemEntity> itens;

  const NfceResultEntity({
    required this.chaveAcesso,
    required this.emitente,
    required this.dataEmissao,
    required this.valorTotal,
    required this.itens,
  });
}

class NfceItemEntity {
  final String descricao;
  final String? ean;
  final double quantidade;
  final String unidade;
  final double valorUnitario;
  final double valorTotal;

  const NfceItemEntity({
    required this.descricao,
    this.ean,
    required this.quantidade,
    required this.unidade,
    required this.valorUnitario,
    required this.valorTotal,
  });
}
