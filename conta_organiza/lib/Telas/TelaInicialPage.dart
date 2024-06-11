import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/scheduler.dart';

class TelaInicialPage extends StatefulWidget {
  const TelaInicialPage({super.key});

  @override
  _TelaInicialPageState createState() => _TelaInicialPageState();
}

class _TelaInicialPageState extends State<TelaInicialPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('contas')) {
            if (mounted) {
              setState(() {
                _contas =
                    List<Map<String, dynamic>>.from(data['contas'].map((conta) {
                  List<Map<String, dynamic>> parcelas = [];
                  if (conta.containsKey('parcelas')) {
                    parcelas =
                        List<Map<String, dynamic>>.from(conta['parcelas']);
                  } else {
                    int quantidadeParcelas = conta['quantidadeParcelas'] ?? 1;
                    for (int i = 0; i < quantidadeParcelas; i++) {
                      parcelas.add({
                        'comprovante': false,
                        'comprovanteUrl': '',
                      });
                    }
                  }
                  return {
                    'descricao': conta['descricao'],
                    'diretorio': conta['diretorio'],
                    'dataVencimento': conta['dataVencimento'] != null
                        ? (conta['dataVencimento'] as Timestamp).toDate()
                        : null,
                    'quantidadeParcelas': conta['quantidadeParcelas'],
                    'contaFixa': conta['contaFixa'] ?? false,
                    'parcelas': parcelas,
                  };
                }));
              });
            }
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar contas: $e');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Erro ao carregar contas: $e');
        });
      }
    }
  }

  Future<void> _loadDirectories() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        QuerySnapshot directoriesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('directories')
            .get();
        if (mounted) {
          setState(() {
            _diretorios =
                directoriesSnapshot.docs.map((doc) => doc.id).toSet().toList();
            _diretoriosMap = {
              for (var doc in directoriesSnapshot.docs)
                doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? doc.id
            };
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar diretórios: $e');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Erro ao carregar diretórios: $e');
        });
      }
    }
  }

  Future<void> _saveContas() async {
    try {
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
              'parcelas': conta['parcelas'],
            };
          }).toList(),
        });
      }
    } catch (e) {
      print('Erro ao salvar contas: $e');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Erro ao salvar contas: $e');
        });
      }
    }
  }

  Future<void> _pickFiles(BuildContext context, Map<String, dynamic> conta,
      int parcelaIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        File pickedFile = File(result.files.single.path!);
        await _uploadFile(context, pickedFile, conta, parcelaIndex);
      }
    } catch (e) {
      print('Erro ao selecionar arquivo: $e');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Erro ao selecionar arquivo: $e');
        });
      }
    }
  }

  Future<void> _pickImage(BuildContext context, Map<String, dynamic> conta,
      int parcelaIndex) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        await _uploadFile(context, imageFile, conta, parcelaIndex);
      }
    } catch (e) {
      print('Erro ao capturar imagem: $e');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Erro ao capturar imagem: $e');
        });
      }
    }
  }

  Future<void> _uploadFile(BuildContext context, File file,
      Map<String, dynamic> conta, int parcelaIndex) async {
    try {
      String description = conta['descricao'];
      String directoryId = conta['diretorio'];
      DateTime date = DateTime.now();

      // Verifica se a parcela já foi paga
      if (conta['parcelas'][parcelaIndex]['comprovante'] == true) {
        _showSnackBar('Esta parcela já foi paga.');
        return;
      }

      String sanitizedDescription =
          description.replaceAll(RegExp(r'[\/:*?"<>|]'), '');
      final fileName =
          '${sanitizedDescription}_Parcela_${parcelaIndex + 1}_${DateFormat('yyyy-MM-dd').format(date)}_${file.path.split('.').last}';

      // Upload do arquivo para o Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
          'users/${_currentUser!.uid}/directories/$directoryId/$fileName');
      await storageRef.putFile(file);
      final fileUrl = await storageRef.getDownloadURL();

      // Salvar metadados no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .doc(directoryId)
          .collection('files')
          .add({
        'description': '$description - Parcela ${parcelaIndex + 1}',
        'date': date,
        'type': file.path.split('.').last,
        'url': fileUrl,
      });

      // Marcar a parcela como paga
      setState(() {
        conta['parcelas'][parcelaIndex]['comprovante'] = true;
        conta['parcelas'][parcelaIndex]['comprovanteUrl'] = fileUrl;
      });

      await _saveContas();

      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Arquivo enviado com sucesso!');
        });
      }
    } catch (e) {
      print('Erro ao fazer upload do arquivo: $e');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _showSnackBar('Erro ao fazer upload do arquivo: $e');
        });
      }
    }
  }

  Future<void> _mostrarDialogoUpload(
      Map<String, dynamic> conta, int parcelaIndex, bool isImage) async {
    final _descricaoController = TextEditingController(
      text: '${conta['descricao']} - Parcela ${parcelaIndex + 1}',
    );
    String? _diretorioSelecionado = conta['diretorio'];

    // Verifique se o diretório selecionado está na lista de diretórios
    if (!_diretorios.contains(_diretorioSelecionado)) {
      _diretorioSelecionado = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Comprovante'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                        labelText: 'Descrição do Arquivo'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Diretório'),
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
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_diretorioSelecionado != null) {
                      Navigator.of(context).pop();
                      conta['diretorio'] = _diretorioSelecionado!;
                      if (isImage) {
                        await _pickImage(context, conta, parcelaIndex);
                      } else {
                        await _pickFiles(context, conta, parcelaIndex);
                      }
                      await _saveContas();
                    } else {
                      if (mounted) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          _showSnackBar('Por favor, preencha todos os campos.');
                        });
                      }
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _desmarcarParcelaComoPaga(
      Map<String, dynamic> conta, int parcelaIndex) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desmarcar como paga'),
        content: const Text(
            'Você tem certeza que deseja desmarcar esta parcela como paga?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Desmarcar'),
          ),
        ],
      ),
    );

    if (confirm) {
      setState(() {
        conta['parcelas'][parcelaIndex]['comprovante'] = false;
        conta['parcelas'][parcelaIndex]['comprovanteUrl'] = '';
      });
      await _saveContas();
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  DateTime calcularDataVencimento(DateTime dataVencimento, int parcelaIndex) {
    return DateTime(dataVencimento.year, dataVencimento.month + parcelaIndex,
        dataVencimento.day);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> contasFiltradas = _contas.where((conta) {
      return true; // Filtragem pode ser ajustada conforme necessário
    }).toList();

    // Ordenar contas
    contasFiltradas.sort((a, b) {
      DateTime? dataVencimentoA = a['dataVencimento'];
      DateTime? dataVencimentoB = b['dataVencimento'];
      if (dataVencimentoA == null || dataVencimentoB == null) return 0;
      return dataVencimentoA.compareTo(dataVencimentoB);
    });

    String dataAtual = DateFormat('dd/MM/yyyy').format(now);

    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Atual: $dataAtual',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ListView.builder(
                    itemCount: contasFiltradas.length,
                    itemBuilder: (context, index) {
                      final conta = contasFiltradas[index];
                      DateTime? dataVencimento = conta['dataVencimento'];
                      if (dataVencimento == null) return Container();

                      String descricao = conta['contaFixa']
                          ? '${conta['descricao']} - ${DateFormat('MM/yyyy').format(now)}'
                          : conta['descricao'];

                      return ExpansionTile(
                        title: Text(descricao),
                        subtitle: Text(
                          '${_diretoriosMap[conta['diretorio']] ?? conta['diretorio']} - Vencimento Inicial: ${DateFormat('dd/MM/yyyy').format(dataVencimento)}',
                        ),
                        children: List.generate(
                            conta['contaFixa']
                                ? 1
                                : conta['quantidadeParcelas'], (parcelaIndex) {
                          DateTime vencimentoParcela = conta['contaFixa']
                              ? DateTime(
                                  now.year, now.month, dataVencimento.day)
                              : calcularDataVencimento(
                                  dataVencimento, parcelaIndex);
                          bool isVencido = vencimentoParcela.isBefore(now);
                          bool hasComprovante = conta['parcelas'].length >
                                  parcelaIndex &&
                              conta['parcelas'][parcelaIndex]['comprovante'];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            height: 90, // Definindo a altura do container
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
                              title: Text(conta['contaFixa']
                                  ? 'Parcela ${DateFormat('MM/yyyy').format(vencimentoParcela)}'
                                  : 'Parcela ${parcelaIndex + 1}'),
                              subtitle: Text(
                                'Vencimento: ${DateFormat('dd/MM/yyyy').format(vencimentoParcela)}',
                              ),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.attach_file,
                                            size: 24),
                                        onPressed: () => _mostrarDialogoUpload(
                                            conta, parcelaIndex, false),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.camera_alt,
                                            size: 24),
                                        onPressed: () => _mostrarDialogoUpload(
                                            conta, parcelaIndex, true),
                                      ),
                                    ],
                                  ),
                                  if (hasComprovante)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          size: 24),
                                      onPressed: () =>
                                          _desmarcarParcelaComoPaga(
                                              conta, parcelaIndex),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
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
