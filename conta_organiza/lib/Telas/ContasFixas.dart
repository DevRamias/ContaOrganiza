import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContasFixas extends StatelessWidget {
  final List<Map<String, dynamic>> contas;
  final Function(Map<String, dynamic>, int, bool) mostrarDialogoUpload;
  final Function(Map<String, dynamic>, int) desmarcarParcelaComoPaga;

  const ContasFixas({
    Key? key,
    required this.contas,
    required this.mostrarDialogoUpload,
    required this.desmarcarParcelaComoPaga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime mesAtual = DateTime.now();
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Contas Fixas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...contas.map((conta) {
          bool parcelaPaga = conta['parcelas'].any((parcela) =>
              parcela['mesAno'] == DateFormat('MM/yyyy').format(mesAtual) &&
              parcela['comprovante']);
          return Card(
            child: ExpansionTile(
              title: Text(conta['descricao']),
              subtitle: Text(
                  '${conta['diretorio']} - ${DateFormat('MM/yyyy').format(mesAtual)}'),
              trailing: parcelaPaga
                  ? const Icon(Icons.check, color: Colors.green)
                  : const Icon(Icons.close, color: Colors.red),
              children: [
                ListTile(
                  title: Text(
                      'Parcela - ${DateFormat('MM/yyyy').format(mesAtual)}'),
                  trailing: parcelaPaga
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                // Visualizar comprovante
                                int parcelaIndex = conta['parcelas'].indexWhere(
                                    (parcela) =>
                                        parcela['mesAno'] ==
                                        DateFormat('MM/yyyy').format(mesAtual));
                                String comprovanteUrl = conta['parcelas']
                                    [parcelaIndex]['comprovanteUrl'];
                                // Implemente a lógica para visualizar o comprovante usando a URL
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Desmarcar parcela como paga
                                int parcelaIndex = conta['parcelas'].indexWhere(
                                    (parcela) =>
                                        parcela['mesAno'] ==
                                        DateFormat('MM/yyyy').format(mesAtual));
                                desmarcarParcelaComoPaga(conta, parcelaIndex);
                              },
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: () {
                                // Associar comprovante (arquivo)
                                int parcelaIndex = conta['parcelas'].indexWhere(
                                    (parcela) =>
                                        parcela['mesAno'] ==
                                        DateFormat('MM/yyyy').format(mesAtual));
                                mostrarDialogoUpload(
                                    conta, parcelaIndex, false);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () {
                                // Associar comprovante (câmera)
                                int parcelaIndex = conta['parcelas'].indexWhere(
                                    (parcela) =>
                                        parcela['mesAno'] ==
                                        DateFormat('MM/yyyy').format(mesAtual));
                                mostrarDialogoUpload(conta, parcelaIndex, true);
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
