import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Diretorios extends StatefulWidget {
  @override
  _DiretoriosState createState() => _DiretoriosState();
}

class _DiretoriosState extends State<Diretorios> {
  List<Directory> _directories = [];

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _createDirectory(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final newDirectory = Directory('${directory.path}/$name');
    if (!(await newDirectory.exists())) {
      await newDirectory.create(recursive: true);
      await _loadDirectories();
    }
  }

  Future<void> _deleteDirectory(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await _loadDirectories();
    }
  }

  Future<void> _loadDirectories() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = directory.listSync();

    List<Directory> directories = [];
    for (var entity in entities) {
      if (entity is Directory) {
        directories.add(entity);
      }
    }

    setState(() {
      _directories = directories;
    });
  }

  Future<void> _showCreateDirectoryDialog() async {
    String dirName = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Criar novo diretório'),
        content: TextField(
          onChanged: (value) {
            dirName = value;
          },
          decoration: InputDecoration(hintText: "Nome do diretório"),
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
              if (dirName.isNotEmpty) {
                await _createDirectory(dirName);
              }
              Navigator.of(context).pop();
            },
            child: Text('Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDirectoryDialog(Directory dir) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir diretório'),
        content: Text(
            'Você tem certeza que deseja excluir o diretório ${dir.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteDirectory(dir);
              Navigator.of(context).pop();
            },
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.5 / 2,
        ),
        itemCount: _directories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () => _showDeleteDirectoryDialog(_directories[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ArquivosPage(diretorio: _directories[index]),
                ),
              );
            },
            child: Container(
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(10),
              //   color: Colors.blue.shade100,
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.grey.withOpacity(0.5),
              //       spreadRadius: 2,
              //       blurRadius: 5,
              //       offset: Offset(0, 3),
              //     ),
              //   ],
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageIcon(
                    AssetImage('assets/images/diretorio.png'),
                    size: 60,
                    color: Color(0xff5E6DDB),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _directories[index].path.split('/').last,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDirectoryDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class ArquivosPage extends StatelessWidget {
  final Directory diretorio;

  ArquivosPage({required this.diretorio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(diretorio.path.split('/').last),
      ),
      body: Center(
        child: Text('Arquivos em ${diretorio.path}'),
      ),
    );
  }
}
