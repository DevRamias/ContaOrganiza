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
    _createAndLoadDirectories();
  }

  Future<void> _createAndLoadDirectories() async {
    await _createDirectory("Luz");
    await _createDirectory("Agua");
    await _loadDirectories();
  }

  Future<void> _createDirectory(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final newDirectory = Directory('${directory.path}/$name');
    if (!(await newDirectory.exists())) {
      await newDirectory.create(recursive: true);
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
                await _loadDirectories();
              }
              Navigator.of(context).pop();
            },
            child: Text('Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: _directories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ArquivosPage(diretorio: _directories[index]),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageIcon(AssetImage('assets/images/diretorio.png'),
                        size: 50,
                        color: Color(0xff5E6DDB)), // Reduza o tamanho do ícone
                    SizedBox(
                        height:
                            5), // Reduza o espaçamento entre o ícone e o texto
                    Text(
                      _directories[index].path.split('/').last,
                      style: TextStyle(
                        fontSize: 14, // Reduza o tamanho do texto
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
