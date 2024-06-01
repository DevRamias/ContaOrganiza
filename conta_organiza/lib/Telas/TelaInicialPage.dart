import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaInicialPage extends StatefulWidget {
  const TelaInicialPage({super.key});

  @override
  _TelaInicialPageState createState() => _TelaInicialPageState();
}

class _TelaInicialPageState extends State<TelaInicialPage> {
  List<Map<String, dynamic>> _contas = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadContas();
  }

  Future<void> _loadContas() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('contas')) {
          setState(() {
            _contas =
                List<Map<String, dynamic>>.from(data['contas'].map((conta) {
              return {
                'descricao': conta['descricao'],
                'diretorio': conta['diretorio'],
                'dataInicio': conta['dataInicio'] != null
                    ? (conta['dataInicio'] as Timestamp).toDate()
                    : null,
                'dataTermino': conta['dataTermino'] != null
                    ? (conta['dataTermino'] as Timestamp).toDate()
                    : null,
                'pago': conta['pago'] ?? false,
              };
            }));
          });
        }
      }
    }
  }

  Future<void> _saveContas() async {
    if (_currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'contas': _contas.map((conta) {
          return {
            'descricao': conta['descricao'],
            'diretorio': conta['diretorio'],
            'dataInicio': conta['dataInicio'] != null
                ? Timestamp.fromDate(conta['dataInicio'])
                : null,
            'dataTermino': conta['dataTermino'] != null
                ? Timestamp.fromDate(conta['dataTermino'])
                : null,
            'pago': conta['pago'],
          };
        }).toList(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> contasFiltradas = _contas.where((conta) {
      DateTime? dataInicio = conta['dataInicio'];
      DateTime? dataTermino = conta['dataTermino'];
      return (dataInicio != null &&
              (dataInicio.isBefore(now) || dataInicio.isAtSameMomentAs(now))) &&
          (dataTermino == null || dataTermino.isAfter(now));
    }).toList();

    contasFiltradas
        .sort((a, b) => a['dataInicio']?.compareTo(b['dataInicio']) ?? 0);

    String dataAtual = DateFormat('dd/MM/yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Inicial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Atual: $dataAtual',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: contasFiltradas.length,
                    itemBuilder: (context, index) {
                      final conta = contasFiltradas[index];
                      DateTime? dataTermino = conta['dataTermino'];
                      bool isVencido =
                          dataTermino != null && dataTermino.isBefore(now);
                      bool isPago = conta['pago'];

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isPago
                              ? Colors.green[100]
                              : isVencido
                                  ? Colors.red[100]
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPago
                                ? Colors.green
                                : isVencido
                                    ? Colors.red
                                    : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          title: Text(conta['descricao']),
                          subtitle: Text(
                            '${conta['diretorio']} - Início: ${DateFormat('dd/MM/yyyy').format(conta['dataInicio'] ?? DateTime.now())} - Término: ${conta['dataTermino'] != null ? DateFormat('dd/MM/yyyy').format(conta['dataTermino']!) : 'N/A'}',
                          ),
                          trailing: Checkbox(
                            value: isPago,
                            onChanged: (bool? value) {
                              setState(() {
                                conta['pago'] = value ?? false;
                                _saveContas();
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
