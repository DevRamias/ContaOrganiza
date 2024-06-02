import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class TelaInicialPage extends StatefulWidget {
  const TelaInicialPage({super.key});

  @override
  _TelaInicialPageState createState() => _TelaInicialPageState();
}

class _TelaInicialPageState extends State<TelaInicialPage> {
  List<Map<String, dynamic>> _contas = [];
  List<String> _diretorios = [];
  Map<String, String> _diretoriosMap = {};
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadContas();
    _loadDirectories();
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
                'comprovante': conta['comprovante'] ?? false,
                'comprovanteUrl': conta['comprovanteUrl'] ?? '',
              };
            }));
          });
        }
      }
    }
  }

  Future<void> _loadDirectories() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      QuerySnapshot directoriesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .get();
      setState(() {
        _diretorios = directoriesSnapshot.docs.map((doc) => doc.id).toList();
        _diretoriosMap = {
          for (var doc in directoriesSnapshot.docs)
            doc.id: (doc.data() as Map<String, dynamic>)['nome'] ?? doc.id
        };
      });
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
            'comprovante': conta['comprovante'],
            'comprovanteUrl': conta['comprovanteUrl'],
          };
        }).toList(),
      });
    }
  }

  Future<void> _mostrarDialogoUpload(
      Map<String, dynamic> conta, bool isImage) async {
    final _descricaoController = TextEditingController();
    String? _diretorioSelecionado;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adicionar Comprovante'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _descricaoController,
                    decoration:
                        InputDecoration(labelText: 'Descrição do Arquivo'),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Diretório'),
                    value: _diretorioSelecionado,
                    items: _diretorios.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(_diretoriosMap[value] ?? value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _diretorioSelecionado = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_descricaoController.text.isNotEmpty &&
                        _diretorioSelecionado != null) {
                      Navigator.of(context).pop();
                      if (isImage) {
                        await _pickImage(conta, _descricaoController.text,
                            _diretorioSelecionado!);
                      } else {
                        await _uploadFile(conta, _descricaoController.text,
                            _diretorioSelecionado!);
                      }
                    }
                  },
                  child: Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _uploadFile(
      Map<String, dynamic> conta, String descricao, String diretorio) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      await _saveFile(conta, file, descricao, diretorio);
    }
  }

  Future<void> _pickImage(
      Map<String, dynamic> conta, String descricao, String diretorio) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _saveFile(conta, imageFile, descricao, diretorio);
    }
  }

  Future<void> _saveFile(Map<String, dynamic> conta, File file,
      String descricao, String diretorio) async {
    setState(() {
      conta['comprovante'] = true;
    });

    try {
      String fileExtension = file.path.split('.').last;
      String fileName =
          '${descricao}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.$fileExtension';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${_currentUser!.uid}/directories/$diretorio/$fileName');
      await storageRef.putFile(file);
      final fileUrl = await storageRef.getDownloadURL();

      // Atualizar Firestore com o URL do comprovante
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'contas': _contas.map((c) {
          if (c['descricao'] == conta['descricao'] &&
              c['dataInicio'] == conta['dataInicio']) {
            return {
              'descricao': c['descricao'],
              'diretorio': c['diretorio'],
              'dataInicio': Timestamp.fromDate(c['dataInicio']),
              'dataTermino': c['dataTermino'] != null
                  ? Timestamp.fromDate(c['dataTermino'])
                  : null,
              'comprovante': true,
              'comprovanteUrl': fileUrl,
            };
          }
          return c;
        }).toList(),
      });
    } catch (e) {
      setState(() {
        conta['comprovante'] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer upload do arquivo: $e'),
        ),
      );
    }
  }

  Future<void> _desmarcarContaComoPaga(Map<String, dynamic> conta) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Desmarcar como paga'),
        content:
            Text('Você tem certeza que deseja desmarcar esta conta como paga?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Desmarcar'),
          ),
        ],
      ),
    );

    if (confirm) {
      setState(() {
        conta['comprovante'] = false;
        conta['comprovanteUrl'] = '';
      });
      await _saveContas();
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
                      bool hasComprovante = conta['comprovante'];

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: hasComprovante
                              ? Colors.green[100]
                              : isVencido
                                  ? Colors.red[100]
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasComprovante
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
                            '${_diretoriosMap[conta['diretorio']] ?? conta['diretorio']} - Início: ${DateFormat('dd/MM/yyyy').format(conta['dataInicio'] ?? DateTime.now())} - Término: ${conta['dataTermino'] != null ? DateFormat('dd/MM/yyyy').format(conta['dataTermino']!) : 'N/A'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file),
                                onPressed: () =>
                                    _mostrarDialogoUpload(conta, false),
                              ),
                              IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () =>
                                    _mostrarDialogoUpload(conta, true),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (String value) {
                                  if (value == 'desmarcar') {
                                    _desmarcarContaComoPaga(conta);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return {'desmarcar'}.map((String choice) {
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
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
