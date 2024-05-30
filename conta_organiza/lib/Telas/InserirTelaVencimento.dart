import 'package:flutter/material.dart';
import 'package:conta_organiza/Telas/CustomAppBar.dart';
import 'dart:io';

import 'package:intl/intl.dart';

class InserirTelaVencimento extends StatefulWidget {
  @override
  _InserirDataVencimentoState createState() => _InserirDataVencimentoState();
}

class _InserirDataVencimentoState extends State<InserirTelaVencimento> {
  List<Map<String, dynamic>> _contas = [];

  void _adicionarConta(String descricao, DateTime data) {
    setState(() {
      _contas.add({'descricao': descricao, 'data': data});
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Descrição'),
                onChanged: (value) {
                  descricao = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Data (yyyy-mm-dd)'),
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  data = DateTime.parse(value);
                },
              ),
            ],
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
                _adicionarConta(descricao, data);
                Navigator.of(context).pop();
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
                  subtitle:
                      Text(DateFormat('yyyy-MM-dd').format(conta['data'])),
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
