import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'dart:io';
import 'InfoConta.dart';

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

  Future<void> _renameDirectory(Directory dir, String newName) async {
    final newPath = '${dir.parent.path}/$newName';
    final newDirectory = Directory(newPath);
    if (!(await newDirectory.exists())) {
      await dir.rename(newPath);
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

  Future<void> _showRenameDirectoryDialog(Directory dir) async {
    String newName = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renomear diretório'),
        content: TextField(
          onChanged: (value) {
            newName = value;
          },
          decoration: InputDecoration(hintText: "Novo nome do diretório"),
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
              if (newName.isNotEmpty) {
                await _renameDirectory(dir, newName);
              }
              Navigator.of(context).pop();
            },
            child: Text('Renomear'),
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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Directory item = _directories.removeAt(oldIndex);
      _directories.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReorderableGridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.5 / 2,
        ),
        itemCount: _directories.length + 1,
        itemBuilder: (context, index) {
          if (index == _directories.length) {
            return SizedBox(
              key: ValueKey('spacer'),
              height: 80,
            );
          }
          Directory dir = _directories[index];
          return GestureDetector(
            key: ValueKey(dir.path),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoConta(directory: dir),
                ),
              );
            },
            child: Container(
              child: Stack(
                children: [
                  Positioned(
                    right: 5,
                    top: 5,
                    child: PopupMenuButton<String>(
                      onSelected: (String result) async {
                        if (result == 'renomear') {
                          await _showRenameDirectoryDialog(dir);
                        } else if (result == 'excluir') {
                          await _showDeleteDirectoryDialog(dir);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'renomear',
                          child: Text('Renomear'),
                        ),
                        PopupMenuItem<String>(
                          value: 'excluir',
                          child: Text('Excluir'),
                        ),
                      ],
                    ),
                  ),
                  Center(
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
                          dir.path.split('/').last,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        onReorder: _onReorder,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDirectoryDialog,
        backgroundColor: Color(0xff838dff),
        child: ImageIcon(
          AssetImage('assets/images/AddDir.png'),
          color: Colors.black,
        ),
      ),
    );
  }
}
