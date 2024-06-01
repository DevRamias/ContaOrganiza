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
                'dataInicio': conta['dataInicio'] != null
                    ? (conta['dataInicio'] as Timestamp).toDate()
                    : null,
                'dataTermino': conta['dataTermino'] != null
                    ? (conta['dataTermino'] as Timestamp).toDate()
                    : null,
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

  void _mostrarDialogoAdicionarConta() {
    final _descricaoController = TextEditingController();
    String? _diretorioSelecionado;
    DateTime? _dataInicioSelecionada;
    DateTime? _dataTerminoSelecionada;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adicionar Conta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _descricaoController,
                      decoration: InputDecoration(labelText: 'Descrição'),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Diretório'),
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
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dataInicioSelecionada == null
                                ? 'Selecione data de início'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_dataInicioSelecionada!),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dataInicioSelecionada = pickedDate;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16),
                              SizedBox(width: 5),
                              Text(
                                'Início',
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
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dataTerminoSelecionada == null
                                ? 'Selecione data de término'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_dataTerminoSelecionada!),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dataTerminoSelecionada = pickedDate;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16),
                              SizedBox(width: 5),
                              Text(
                                'Término',
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_descricaoController.text.isNotEmpty &&
                        _diretorioSelecionado != null &&
                        _dataInicioSelecionada != null) {
                      setState(() {
                        _contas.add({
                          'descricao': _descricaoController.text,
                          'diretorio': _diretorioSelecionado!,
                          'dataInicio': _dataInicioSelecionada!,
                          'dataTermino': _dataTerminoSelecionada,
                        });
                        _saveContas();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Adicionar'),
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
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> contasFiltradas = _contas.where((conta) {
      DateTime? dataInicio = conta['dataInicio'];
      DateTime? dataTermino = conta['dataTermino'];
      return (dataInicio != null &&
              (dataInicio.isAfter(now) || dataInicio.isAtSameMomentAs(now))) &&
          (dataTermino == null || dataTermino.isAfter(now));
    }).toList();

    contasFiltradas
        .sort((a, b) => a['dataInicio']?.compareTo(b['dataInicio']) ?? 0);

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
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xffD2D6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
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
                title: Text(
                  'Contas adicionadas',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff838DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(14),
                    elevation: 8,
                  ),
                  child: Icon(Icons.add, color: Colors.black),
                  onPressed: _mostrarDialogoAdicionarConta,
                ),
              ),
              if (contasFiltradas.isNotEmpty)
                ...contasFiltradas.map((conta) {
                  return ListTile(
                    title: Text(conta['descricao']),
                    subtitle: Text(
                        '${conta['diretorio']} - Início: ${DateFormat('dd/MM/yyyy').format(conta['dataInicio'] ?? DateTime.now())} - Término: ${conta['dataTermino'] != null ? DateFormat('dd/MM/yyyy').format(conta['dataTermino']!) : 'N/A'}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _removerConta(_contas.indexOf(conta));
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
