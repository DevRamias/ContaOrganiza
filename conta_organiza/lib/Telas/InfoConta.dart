import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class InfoConta extends StatefulWidget {
  final Directory directory;

  InfoConta({required this.directory});

  @override
  _InfoContaState createState() => _InfoContaState();
}

class _InfoContaState extends State<InfoConta> {
  List<Map<String, dynamic>> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (!widget.directory.existsSync()) {
      await widget.directory.create(recursive: true);
    }

    final List<FileSystemEntity> entities = widget.directory.listSync();
    List<Map<String, dynamic>> files = [];

    for (var entity in entities) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        final parts = fileName.split('_');
        if (parts.length == 3) {
          files.add({
            'file': entity,
            'description': parts[0],
            'date': DateFormat('yyyy-MM-dd').parse(parts[1]),
            'type': parts[2],
          });
        }
      }
    }

    setState(() {
      _files = files;
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);
      await _showFileInfoDialog(pickedFile);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _showFileInfoDialog(imageFile);
    }
  }

  Future<void> _showFileInfoDialog(File file) async {
    String description = '';
    DateTime date = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informações do arquivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                description = value;
              },
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Vencimento: '),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          date = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(date),
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
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
          TextButton(
            onPressed: () async {
              final fileName =
                  '${description}_${DateFormat('yyyy-MM-dd').format(date)}_${file.path.split('.').last}';
              final newFilePath = '${widget.directory.path}/$fileName';

              // Certifique-se de que o diretório de destino exista
              if (!widget.directory.existsSync()) {
                await widget.directory.create(recursive: true);
              }

              // Copie o arquivo para o novo local
              await file.copy(newFilePath);

              // Carregue os arquivos novamente para atualizar a lista
              await _loadFiles();

              Navigator.of(context).pop();
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(File file) async {
    await file.delete();
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.directory.path.split('/').last),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Tirar Foto'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: Icon(Icons.file_upload),
                  label: Text('Carregar Arquivo'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final fileData = _files[index];
                final file = fileData['file'];
                final description = fileData['description'];
                final date = fileData['date'];
                final type = fileData['type'];

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
                      'Vencimento: ${DateFormat('yyyy-MM-dd').format(date)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteFile(file),
                  ),
                  onTap: () {
                    // Ação ao clicar no arquivo
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
