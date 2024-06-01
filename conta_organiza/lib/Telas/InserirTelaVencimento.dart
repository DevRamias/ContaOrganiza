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
                'data': (conta['data'] as Timestamp).toDate(),
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
            'data': Timestamp.fromDate(conta['data']),
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
    DateTime? _dataSelecionada;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                        _dataSelecionada == null
                            ? 'Nenhuma data selecionada'
                            : DateFormat('yyyy-MM-dd')
                                .format(_dataSelecionada!),
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
                            _dataSelecionada = pickedDate;
                          });
                        }
                      },
                      child: Text('Selecionar Data'),
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
                    _dataSelecionada != null) {
                  setState(() {
                    _contas.add({
                      'descricao': _descricaoController.text,
                      'diretorio': _diretorioSelecionado!,
                      'data': _dataSelecionada!,
                    });
                    _saveContas();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar'),
            ),
          ],
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color:
                          Color(0xffD2D6FF), // Cor de fundo ao redor do botão
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
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _mostrarDialogoAdicionarConta,
                ),
              ),
              if (_contas.isNotEmpty)
                ..._contas.map((conta) {
                  return ListTile(
                    title: Text(conta['descricao']),
                    subtitle: Text(
                        '${conta['diretorio']} - ${DateFormat('yyyy-MM-dd').format(conta['data'])}'),
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
