import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Diretorios.dart'; // Importar o arquivo Diretorios.dart
import 'CustomAppBar.dart'; // Importar o arquivo CustomAppBar.dart

class InserirTelaVencimento extends StatefulWidget {
  const InserirTelaVencimento({super.key});

  @override
  _InserirTelaVencimentoState createState() => _InserirTelaVencimentoState();
}

class _InserirTelaVencimentoState extends State<InserirTelaVencimento> {
  List<Map<String, dynamic>> _contas = [];
  List<String> _diretorios = [];
  String _userName = 'Nome do Usuário';
  String _userProfileImage = 'assets/images/Foto do perfil.png';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDirectories();
    _loadContas();
    _loadUserProfile();
  }

  Future<void> _loadDirectories() async {
    List<String> directories = await Diretorios.getDirectories();
    setState(() {
      _diretorios = directories;
    });
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
                'dataVencimento': conta['dataVencimento'] != null
                    ? (conta['dataVencimento'] as Timestamp).toDate()
                    : null,
                'quantidadeParcelas': conta['quantidadeParcelas'],
                'contaFixa': conta['contaFixa'] ?? false,
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
            'dataVencimento': conta['dataVencimento'] != null
                ? Timestamp.fromDate(conta['dataVencimento'])
                : null,
            'quantidadeParcelas': conta['quantidadeParcelas'],
            'contaFixa': conta['contaFixa'],
          };
        }).toList(),
      });
    }
  }

  Future<void> _loadUserProfile() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          _userName = data?['name'] ?? 'Nome do Usuário';
          _userProfileImage =
              data?['profileImage'] ?? 'assets/images/Foto do perfil.png';
        });
      }
    }
  }

  void _mostrarDialogoAdicionarConta(
      {Map<String, dynamic>? conta, int? index}) {
    final _descricaoController =
        TextEditingController(text: conta?['descricao']);
    String? _diretorioSelecionado = conta?['diretorio'];
    DateTime? _dataVencimentoSelecionada = conta?['dataVencimento'];
    int? _quantidadeParcelas = conta?['quantidadeParcelas'];
    bool _contaFixa = conta?['contaFixa'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(conta == null ? 'Adicionar Conta' : 'Editar Conta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Diretório'),
                      value: _diretorioSelecionado,
                      items: _diretorios.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _diretorioSelecionado = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dataVencimentoSelecionada == null
                                ? 'Selecione data de vencimento'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_dataVencimentoSelecionada!),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  _dataVencimentoSelecionada ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dataVencimentoSelecionada = pickedDate;
                              });
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16),
                              SizedBox(width: 5),
                              Text(
                                'Vencimento',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                                labelText: 'Quantidade de Parcelas'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _quantidadeParcelas = int.tryParse(value);
                              });
                            },
                            enabled: !_contaFixa,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Checkbox(
                          value: _contaFixa,
                          onChanged: (value) {
                            setState(() {
                              _contaFixa = value ?? false;
                              if (_contaFixa) {
                                _quantidadeParcelas = null;
                              }
                            });
                          },
                        ),
                        const Text('Conta Fixa'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_descricaoController.text.isNotEmpty &&
                        _diretorioSelecionado != null &&
                        _dataVencimentoSelecionada != null) {
                      setState(() {
                        if (conta == null) {
                          _contas.add({
                            'descricao': _descricaoController.text,
                            'diretorio': _diretorioSelecionado!,
                            'dataVencimento': _dataVencimentoSelecionada!,
                            'quantidadeParcelas': _quantidadeParcelas,
                            'contaFixa': _contaFixa,
                          });
                        } else {
                          _contas[index!] = {
                            'descricao': _descricaoController.text,
                            'diretorio': _diretorioSelecionado!,
                            'dataVencimento': _dataVencimentoSelecionada!,
                            'quantidadeParcelas': _quantidadeParcelas,
                            'contaFixa': _contaFixa,
                          };
                        }
                        _saveContas();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(conta == null ? 'Adicionar' : 'Salvar'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removerConta(int index) {
    setState(() {
      _contas.removeAt(index);
      _saveContas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userName: _userName,
        userProfileImage: _userProfileImage,
        title: 'Vencimento',
        onUpdateProfileImage: (String newImageUrl) {},
        onUpdateUserName: (String newName) {},
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xffD2D6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  'Contas adicionadas',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff838DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(14),
                    elevation: 8,
                  ),
                  child: const Icon(Icons.add, color: Colors.black),
                  onPressed: () => _mostrarDialogoAdicionarConta(),
                ),
              ),
              if (_contas.isNotEmpty)
                ..._contas.map((conta) {
                  int index = _contas.indexOf(conta);
                  return ListTile(
                    title: Text(conta['descricao']),
                    subtitle: Text(
                        '${conta['diretorio']} - Vencimento: ${DateFormat('dd/MM/yyyy').format(conta['dataVencimento'] ?? DateTime.now())} - Parcelas: ${conta['contaFixa'] ? 'Conta Fixa' : conta['quantidadeParcelas']}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'Editar') {
                          _mostrarDialogoAdicionarConta(
                              conta: conta, index: index);
                        } else if (value == 'Excluir') {
                          _removerConta(index);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Editar', 'Excluir'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  );
                }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
