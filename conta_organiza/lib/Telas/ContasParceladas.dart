import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContasParceladas extends StatelessWidget {
  final List<Map<String, dynamic>> contas;
  final Function(Map<String, dynamic>, int, bool) mostrarDialogoUpload;
  final Function(Map<String, dynamic>, int) desmarcarParcelaComoPaga;

  const ContasParceladas({
    Key? key,
    required this.contas,
    required this.mostrarDialogoUpload,
    required this.desmarcarParcelaComoPaga,
  }) : super(key: key);

  DateTime calcularDataVencimento(DateTime dataVencimento, int parcelaIndex) {
    return DateTime(dataVencimento.year, dataVencimento.month + parcelaIndex,
        dataVencimento.day);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Contas Parceladas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...contas.map((conta) {
          return Card(
            child: ExpansionTile(
              title: Text(conta['descricao']),
              subtitle: Text(
                  '${conta['diretorio']} - Vencimento: ${DateFormat('dd/MM/yyyy').format(conta['dataVencimento'])}'),
              children: [
                for (int i = 0; i < conta['parcelas'].length; i++)
                  ListTile(
                    title: Text('Parcela ${i + 1}'),
                    subtitle: Text(
                        'Vencimento: ${DateFormat('dd/MM/yyyy').format(calcularDataVencimento(conta['dataVencimento'], i))}'),
                    trailing: conta['parcelas'][i]['comprovante']
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  // Visualizar comprovante
                                  String comprovanteUrl =
                                      conta['parcelas'][i]['comprovanteUrl'];
                                  // Implemente a lógica para visualizar o comprovante usando a URL
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Desmarcar parcela como paga
                                  desmarcarParcelaComoPaga(conta, i);
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
                                  mostrarDialogoUpload(conta, i, false);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: () {
                                  // Associar comprovante (câmera)
                                  mostrarDialogoUpload(conta, i, true);
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
