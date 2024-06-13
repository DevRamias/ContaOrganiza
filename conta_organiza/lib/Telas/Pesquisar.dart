import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Pesquisar extends StatefulWidget {
  @override
  _PesquisarState createState() => _PesquisarState();
}

class _PesquisarState extends State<Pesquisar> {
  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> _filteredFiles = [];
  String _searchQuery = '';
  DateTime? _selectedDate;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    // Implemente este método se precisar cancelar operações assíncronas
    // ou liberar recursos quando o widget for descartado.
    super.dispose();
  }

  Future<void> _loadFiles() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      QuerySnapshot directoriesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .get();

      List<Map<String, dynamic>> files = [];
      for (var directory in directoriesSnapshot.docs) {
        QuerySnapshot filesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('directories')
            .doc(directory.id)
            .collection('files')
            .get();

        files.addAll(filesSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'description': doc['description'],
            'date': doc['date'].toDate(),
            'type': doc['type'],
            'url': doc['url'],
            'directoryId': directory.id,
            'directoryName': directory['name'],
          };
        }).toList());
      }

      // Verifica se o widget ainda está montado antes de chamar setState()
      if (mounted) {
        setState(() {
          _files = files;
          _filteredFiles = _files;
        });
      }
    }
  }

  void _filterFiles() {
    List<Map<String, dynamic>> filtered = _files.where((file) {
      bool matchesQuery = file['description']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      bool matchesDate = _selectedDate == null || file['date'] == _selectedDate;
      return matchesQuery && matchesDate;
    }).toList();

    setState(() {
      _filteredFiles = filtered;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _filterFiles();
    }
  }

  Future<void> _showPdfPreview(String url) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: FutureBuilder<File>(
            future: _downloadPdf(url),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(
                    child: const Text(
                      'Não foi possível exibir o PDF. Por favor, tente novamente mais tarde.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                try {
                  return PDFView(filePath: snapshot.data!.path);
                } catch (e) {
                  return const Center(
                    child: Text(
                      'Erro ao carregar o PDF. Por favor, tente novamente mais tarde.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<File> _downloadPdf(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${url.split('/').last}';
      final file = File(filePath);

      if (await file.exists()) {
        return file;
      }

      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);
      return file;
    } catch (e) {
      throw Exception('Erro ao baixar o PDF: $e');
    }
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: FutureBuilder(
            future: _loadImage(url),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar a imagem'));
                }
                return Image.network(url);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadImage(String url) async {
    try {
      final response = await Dio().get(url);
      if (response.statusCode != 200) {
        throw Exception('Erro ao carregar a imagem');
      }
    } catch (e) {
      throw Exception('Erro ao carregar a imagem: $e');
    }
  }

  Future<void> _openFileInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _editFileDetails(Map<String, dynamic> fileData) {
    String description = fileData['description'];
    DateTime date = fileData['date'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Detalhes do Arquivo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  description = value;
                },
                controller: TextEditingController(text: description),
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Vencimento: '),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            date = pickedDate;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('dd/MM/yyyy').format(date),
                            style: const TextStyle(
                                decoration: TextDecoration.underline),
                          ),
                        ],
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
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser!.uid)
                  .collection('directories')
                  .doc(fileData['directoryId'])
                  .collection('files')
                  .doc(fileData['id'])
                  .update({
                'description': description,
                'date': date,
              });
              await _loadFiles();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(Map<String, dynamic> fileData) async {
    if (_currentUser != null) {
      // Deletar o arquivo do Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(fileData['url']);
      await storageRef.delete();

      // Deletar metadados do Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .doc(fileData['directoryId'])
          .collection('files')
          .doc(fileData['id'])
          .delete();

      _loadFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nome do Arquivo',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterFiles();
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Data: '),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : 'Selecionar Data',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      _filterFiles();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFiles.length,
                itemBuilder: (context, index) {
                  final fileData = _filteredFiles[index];
                  final description = fileData['description'];
                  final date = fileData['date'];
                  final type = fileData['type'];
                  final directoryName = fileData['directoryName'];

                  IconData iconData;
                  if (type == 'pdf') {
                    iconData = Icons.picture_as_pdf;
                  } else {
                    iconData = Icons.image;
                  }

                  return ListTile(
                    leading: Icon(iconData),
                    title: Text(description),
                    subtitle: Text(
                        'Diretório: $directoryName\nVencimento: ${DateFormat('yyyy-MM-dd').format(date)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'view':
                            if (type == 'pdf') {
                              _showPdfPreview(fileData['url']);
                            } else {
                              _showImagePreview(fileData['url']);
                            }
                            break;
                          case 'download':
                            await _openFileInBrowser(fileData['url']);
                            break;
                          case 'edit':
                            _editFileDetails(fileData);
                            break;
                          case 'delete':
                            _deleteFile(fileData);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('Visualizar'),
                          ),
                          const PopupMenuItem(
                            value: 'download',
                            child: Text('Download'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Excluir'),
                          ),
                        ];
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
