import 'package:flutter/material.dart';
import 'package:conta_organiza/Telas/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InserirTelaVencimento extends StatefulWidget {
  @override
  _InserirTelaVencimentoState createState() => _InserirTelaVencimentoState();
}

class _InserirTelaVencimentoState extends State<InserirTelaVencimento> {
  List<Map<String, dynamic>> _contas = [];
  List<String> _diretorios = [];
  String? _selectedDiretorio;

  @override
  void initState() {
    super.initState();
    _loadDiretorios();
  }

  Future<void> _loadDiretorios() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('diretorios').get();
    List<String> diretorios =
        snapshot.docs.map((doc) => doc['nome'].toString()).toList();
    setState(() {
      _diretorios = diretorios;
    });
  }

  void _adicionarConta(String descricao, String diretorio, DateTime data) {
    setState(() {
      _contas
          .add({'descricao': descricao, 'diretorio': diretorio, 'data': data});
    });
  }

  void _removerConta(int index) {
    setState(() {
      _contas.removeAt(index);
    });
  }

  void _mostrarDialogoAdicionarConta() {
    String descricao = '';
    DateTime data = DateTime.now();
    String? diretorioSelecionado;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Conta'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Conta'),
                    onChanged: (value) {
                      descricao = value;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Diretório'),
                    items: _diretorios.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        diretorioSelecionado = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: 'Data'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          data = pickedDate;
                        });
                      }
                    },
                    controller: TextEditingController(
                        text: DateFormat('yyyy-MM-dd').format(data)),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () {
                if (descricao.isNotEmpty && diretorioSelecionado != null) {
                  _adicionarConta(descricao, diretorioSelecionado!, data);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userName: 'Nome do Usuário',
        userProfileImage: 'assets/images/Foto do perfil.png',
        title: 'Vencimento',
        onUpdateProfileImage: (String newImageUrl) {},
        onUpdateUserName: (String newName) {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FloatingActionButton(
                  onPressed: _mostrarDialogoAdicionarConta,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Contas adicionais',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _contas.length,
              itemBuilder: (context, index) {
                final conta = _contas[index];
                return ListTile(
                  title: Text(conta['descricao']),
                  subtitle: Text(
                      '${conta['diretorio']} - ${DateFormat('yyyy-MM-dd').format(conta['data'])}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _removerConta(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
