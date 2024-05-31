import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InserirTelaVencimento extends StatefulWidget {
  const InserirTelaVencimento({super.key});

  @override
  _InserirTelaVencimentoState createState() => _InserirTelaVencimentoState();
}

class _InserirTelaVencimentoState extends State<InserirTelaVencimento> {
  List<Map<String, dynamic>> _contas = [];

  void _mostrarDialogoAdicionarConta() {
    final _descricaoController = TextEditingController();
    final List<String> _diretorios = [
      'Diretório 1',
      'Diretório 2',
      'Diretório 3'
    ];
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
    });
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

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String userProfileImage;
  final String title;
  final Function(String) onUpdateProfileImage;
  final Function(String) onUpdateUserName;

  CustomAppBar({
    required this.userName,
    required this.userProfileImage,
    required this.title,
    required this.onUpdateProfileImage,
    required this.onUpdateUserName,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(100);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late String _userProfileImage;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userProfileImage = widget.userProfileImage;
    _userName = widget.userName;
  }

  void updateProfileImage(String newImage) {
    setState(() {
      _userProfileImage = newImage;
    });
    widget.onUpdateProfileImage(newImage);
  }

  void updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
    widget.onUpdateUserName(newName);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xff838DFF),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _userProfileImage.startsWith('assets/')
                    ? AssetImage(_userProfileImage) as ImageProvider
                    : FileImage(File(_userProfileImage)),
              ),
              const SizedBox(width: 10),
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/images/Vector.png',
            height: 30,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Container(
              height: 2,
              color: Colors.black,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ],
        ),
      ),
    );
  }
}
