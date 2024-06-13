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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> _filteredFiles = [];
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final QuerySnapshot directoriesSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('directories')
            .get();

        final List<Map<String, dynamic>> files = [];
        for (var directory in directoriesSnapshot.docs) {
          final QuerySnapshot filesSnapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('directories')
              .doc(directory.id)
              .collection('files')
              .get();

          files.addAll(filesSnapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'description': doc['description'],
              'date': (doc['date'] as Timestamp).toDate(),
              'type': doc['type'],
              'url': doc['url'],
              'directoryId': directory.id,
              'directoryName': directory['name'],
            };
          }).toList());
        }

        if (mounted) {
          setState(() {
            _files = files;
            _filteredFiles = files;
          });
        }
      } catch (e) {
        print('Erro ao carregar arquivos: $e');
        // TODO: Implementar tratamento de erro para o usuário (ex: SnackBar)
      }
    }
  }

  void _filterFiles() {
    setState(() {
      _filteredFiles = _files.where((file) {
        final bool matchesQuery = file['description']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final bool matchesDate = _selectedDate == null ||
            DateFormat('yyyy-MM-dd').format(file['date']) ==
                DateFormat('yyyy-MM-dd').format(_selectedDate!);
        return matchesQuery && matchesDate;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    try {
      final File pdfFile = await _downloadFile(url);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: PDFView(filePath: pdfFile.path),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Erro ao exibir PDF: $e');
      // TODO: Implementar tratamento de erro para o usuário (ex: SnackBar)
    }
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(url),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<File> _downloadFile(String url) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/${url.split('/').last}';
      final File file = File(filePath);

      if (await file.exists()) {
        return file;
      }

      final Response response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);
      return file;
    } catch (e) {
      rethrow;
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
                onChanged: (value) => description = value,
                controller: TextEditingController(text: description),
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Data: '),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            date = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(date),
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .collection('directories')
                    .doc(fileData['directoryId'])
                    .collection('files')
                    .doc(fileData['id'])
                    .update({'description': description, 'date': date});
                await _loadFiles();
                Navigator.of(context).pop();
              } catch (e) {
                print('Erro ao atualizar arquivo: $e');
                // TODO: Implementar tratamento de erro para o usuário (ex: SnackBar)
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(Map<String, dynamic> fileData) async {
    try {
      // Exibe um diálogo de confirmação antes de excluir
      final bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir Arquivo'),
          content: const Text('Tem certeza que deseja excluir este arquivo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        final Reference storageRef = _storage.refFromURL(fileData['url']);
        await storageRef.delete();

        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('directories')
            .doc(fileData['directoryId'])
            .collection('files')
            .doc(fileData['id'])
            .delete();

        _loadFiles();
      }
    } catch (e) {
      print('Erro ao excluir arquivo: $e');
      // TODO: Implementar tratamento de erro para o usuário (ex: SnackBar)
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
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
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

                  IconData iconData =
                      type == 'pdf' ? Icons.picture_as_pdf : Icons.image;

                  return ListTile(
                    leading: Icon(iconData),
                    title: Text(description),
                    subtitle: Text(
                      'Diretório: $directoryName\nData: ${DateFormat('dd/MM/yyyy').format(date)}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'view':
                            if (type == 'pdf') {
                              await _showPdfPreview(fileData['url']);
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
                            await _deleteFile(fileData);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return const [
                          PopupMenuItem(
                            value: 'view',
                            child: Text('Visualizar'),
                          ),
                          PopupMenuItem(
                            value: 'download',
                            child: Text('Download'),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          PopupMenuItem(
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
