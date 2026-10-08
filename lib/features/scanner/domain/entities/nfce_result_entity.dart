// Espelha InvoiceResponseDTO (POST /api/v1/nfce/process).
// O id é necessário para confirmar (POST /nfce/{id}/confirm) ou rejeitar a nota.
class NfceResultEntity {
  final String id;
  final String chaveAcesso;
  final String emitente;
  final String dataEmissao;
  final double valorTotal;
  final List<NfceItemEntity> itens;

  const NfceResultEntity({
    required this.id,
    required this.chaveAcesso,
    required this.emitente,
    required this.dataEmissao,
    required this.valorTotal,
    required this.itens,
  });
}

// id/productId são necessários para o PATCH de revisão
// (PATCH /nfce/{invoiceId}/items/{itemId}). ignored marca o item para não
// entrar no estoque quando a nota for confirmada.
class NfceItemEntity {
  final String id;
  final String descricao;
  final String? ean;
  final String? productId;
  final double quantidade;
  final String unidade;
  final double valorUnitario;
  final double valorTotal;
  final bool ignored;

  const NfceItemEntity({
    required this.id,
    required this.descricao,
    this.ean,
    this.productId,
    required this.quantidade,
    required this.unidade,
    required this.valorUnitario,
    required this.valorTotal,
    this.ignored = false,
  });
}
