import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

class TelaInicialPage extends StatefulWidget {
  const TelaInicialPage({Key? key});

  @override
  _TelaInicialPageState createState() => _TelaInicialPageState();
}

class _TelaInicialPageState extends State<TelaInicialPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _contas = [];
  List<String> _diretorios = [];
  Map<String, String> _diretoriosMap = {};
  User? _currentUser;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadContas();
    _loadDirectories();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
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
            if (!_isDisposed) {
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
                        'mesAno': DateFormat('MM/yyyy')
                            .format(DateTime.now().add(Duration(days: 30 * i))),
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
        if (!_isDisposed) {
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

      // Verifica se a conta é fixa ou parcelada e ajusta a descrição
      String fileName;
      if (conta['contaFixa'] == true) {
        fileName =
            '${sanitizedDescription} - ${conta['parcelas'][parcelaIndex]['mesAno']} - ${DateFormat('yyyy-MM-dd').format(date)}.${file.path.split('.').last}';
      } else {
        fileName =
            '${sanitizedDescription} - Parcela ${parcelaIndex + 1} - ${DateFormat('yyyy-MM-dd').format(date)}.${file.path.split('.').last}';
      }

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
        'description': conta['contaFixa'] == true
            ? '$description - ${conta['parcelas'][parcelaIndex]['mesAno']}'
            : '$description - Parcela ${parcelaIndex + 1}',
        'date': date,
        'type': file.path.split('.').last,
        'url': fileUrl,
      });

      // Marcar a parcela como paga e salvar no Firebase
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
      text:
          '${conta['descricao']} - ${conta['parcelas'][parcelaIndex]['mesAno']}',
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
              title: Text(
                  '${conta['descricao']} - ${conta['parcelas'][parcelaIndex]['mesAno']}'),
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
      // Desmarcar a parcela como paga e salvar no Firebase
      setState(() {
        conta['parcelas'][parcelaIndex]['comprovante'] = false;
        conta['parcelas'][parcelaIndex]['comprovanteUrl'] = '';
        _saveContas(); // Salva as contas após a atualização
      });
    }
  }

  void _showSnackBar(String message) {
    if (!_isDisposed) {
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

  void _adicionarConta() async {
    final _descricaoController = TextEditingController();
    String? _diretorioSelecionado =
        _diretorios.isNotEmpty ? _diretorios[0] : null;
    DateTime _selectedDate = DateTime.now();
    int _quantidadeParcelas = 1;
    bool _contaFixa = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Conta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                          labelText: 'Descrição da Conta'),
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
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
                                _quantidadeParcelas = int.tryParse(value) ?? 1;
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
                                _quantidadeParcelas = 1;
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
                    String descricao = _descricaoController.text.trim();
                    if (descricao.isNotEmpty && _diretorioSelecionado != null) {
                      Map<String, dynamic> novaConta = {
                        'descricao': descricao,
                        'diretorio': _diretorioSelecionado!,
                        'dataVencimento': _selectedDate,
                        'quantidadeParcelas': _quantidadeParcelas,
                        'contaFixa': _contaFixa,
                        'parcelas': List.generate(
                          _quantidadeParcelas,
                          (index) => {
                            'comprovante': false,
                            'comprovanteUrl': '',
                            'mesAno': _contaFixa
                                ? DateFormat('MM/yyyy').format(DateTime(
                                    _selectedDate.year,
                                    _selectedDate.month + index))
                                : null,
                          },
                        ),
                      };
                      setState(() {
                        _contas.add(novaConta);
                        _saveContas(); // Salva as contas após adicionar
                      });
                      Navigator.of(context).pop();
                      _showSnackBar('Conta adicionada com sucesso.');
                    } else {
                      _showSnackBar('Por favor, preencha todos os campos.');
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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> contasFixas =
        _contas.where((conta) => conta['contaFixa'] == true).toList();
    List<Map<String, dynamic>> contasParceladas =
        _contas.where((conta) => conta['contaFixa'] == false).toList();

    // Ordenar contas por data de vencimento
    contasFixas.sort((a, b) {
      DateTime? dataVencimentoA = a['dataVencimento'];
      DateTime? dataVencimentoB = b['dataVencimento'];
      if (dataVencimentoA == null || dataVencimentoB == null) return 0;
      return dataVencimentoA.compareTo(dataVencimentoB);
    });

    contasParceladas.sort((a, b) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Data Atual: $dataAtual',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                    width: 15), // Espaço entre o Text e o FloatingActionButton
                Padding(
                  padding: const EdgeInsets.all(
                      4.0), // Espaço interno do FloatingActionButton
                  child: FloatingActionButton(
                    onPressed: _adicionarConta,
                    backgroundColor: const Color(0xff838dff),
                    child: const ImageIcon(
                      AssetImage('assets/images/plus-line.png'),
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Expanded(
              child: ListView(
                children: [
                  // Seção de Contas Fixas
                  if (contasFixas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Contas Fixas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...contasFixas.map((conta) {
                      DateTime? dataVencimentoInicial = conta['dataVencimento'];
                      if (dataVencimentoInicial == null) return Container();

                      // Inicializa a lista de parcelas se for nula
                      conta['parcelas'] ??= [];

                      // Adiciona nova parcela para o mês atual se não existir
                      if (!conta['parcelas'].any((parcela) =>
                          parcela['mesAno'] ==
                          DateFormat('MM/yyyy')
                              .format(DateTime(now.year, now.month)))) {
                        conta['parcelas'].add({
                          'comprovante': false,
                          'comprovanteUrl': '',
                          'mesAno': DateFormat('MM/yyyy')
                              .format(DateTime(now.year, now.month)),
                        });
                        _saveContas();
                      }

                      return ExpansionTile(
                        title: Text(
                            '${conta['descricao']} - ${DateFormat('MM/yyyy').format(now)}'),
                        subtitle: Text(
                          '${_diretoriosMap[conta['diretorio']] ?? conta['diretorio']} - Vencimento Inicial: ${DateFormat('dd/MM/yyyy').format(dataVencimentoInicial)}',
                        ),
                        children: List.generate(conta['parcelas'].length,
                            (parcelaIndex) {
                          Map<String, dynamic> parcela =
                              conta['parcelas'][parcelaIndex];
                          DateTime vencimentoParcela = DateTime(
                            int.parse(parcela['mesAno'].split('/')[1]),
                            int.parse(parcela['mesAno'].split('/')[0]),
                            dataVencimentoInicial.day,
                          );
                          bool isVencido = vencimentoParcela.isBefore(now);
                          bool hasComprovante = parcela['comprovante'];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: hasComprovante
                                  ? Colors.green[100]
                                  : isVencido
                                      ? Colors.red[100]
                                      : Colors.white,
                              border: Border.all(
                                color: hasComprovante
                                    ? Colors.green
                                    : isVencido
                                        ? Colors.red
                                        : Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                  '${conta['descricao']} - ${parcela['mesAno']}'),
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
                                      if (hasComprovante)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _desmarcarParcelaComoPaga(
                                                      conta, parcelaIndex),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    }).toList(),
                  ],

                  // Seção de Contas Parceladas
                  if (contasParceladas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Contas Parceladas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...contasParceladas.map((conta) {
                      DateTime? dataVencimentoInicial = conta['dataVencimento'];
                      if (dataVencimentoInicial == null) return Container();

                      return ExpansionTile(
                        title: Text(conta['descricao']),
                        subtitle: Text(
                          '${_diretoriosMap[conta['diretorio']] ?? conta['diretorio']} - Vencimento Inicial: ${DateFormat('dd/MM/yyyy').format(dataVencimentoInicial)}',
                        ),
                        children: List.generate(conta['quantidadeParcelas'],
                            (parcelaIndex) {
                          DateTime vencimentoParcela = calcularDataVencimento(
                              dataVencimentoInicial, parcelaIndex);
                          bool isVencido = vencimentoParcela.isBefore(now);
                          bool hasComprovante = conta['parcelas'] != null &&
                              conta['parcelas'].length > parcelaIndex &&
                              conta['parcelas'][parcelaIndex]['comprovante'];

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: hasComprovante
                                  ? Colors.green[100]
                                  : isVencido
                                      ? Colors.red[100]
                                      : Colors.white,
                              border: Border.all(
                                color: hasComprovante
                                    ? Colors.green
                                    : isVencido
                                        ? Colors.red
                                        : Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                  '${conta['descricao']} - Parcela ${parcelaIndex + 1}'),
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
                                      if (hasComprovante)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  _desmarcarParcelaComoPaga(
                                                      conta, parcelaIndex),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
