import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'InfoConta.dart';

class Diretorios extends StatefulWidget {
  const Diretorios({super.key});

  @override
  _DiretoriosState createState() => _DiretoriosState();
}

class _DiretoriosState extends State<Diretorios> {
  List<DocumentSnapshot> _directories = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadDirectories();
  }

  Future<void> _createDirectory(String name) async {
    if (_currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .add({'name': name});
      await _loadDirectories();
    }
  }

  Future<void> _renameDirectory(DocumentSnapshot dir, String newName) async {
    if (_currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .doc(dir.id)
          .update({'name': newName});
      await _loadDirectories();
    }
  }

  Future<void> _deleteDirectory(DocumentSnapshot dir) async {
    if (_currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .doc(dir.id)
          .delete();
      await _loadDirectories();
    }
  }

  Future<void> _loadDirectories() async {
    if (_currentUser != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('directories')
          .get();
      setState(() {
        _directories = querySnapshot.docs;
      });
    }
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

  Future<void> _showRenameDirectoryDialog(DocumentSnapshot dir) async {
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

  Future<void> _showDeleteDirectoryDialog(DocumentSnapshot dir) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir diretório'),
        content: Text(
            'Você tem certeza que deseja excluir o diretório ${dir['name']}?'),
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
      final DocumentSnapshot item = _directories.removeAt(oldIndex);
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
          DocumentSnapshot dir = _directories[index];
          return GestureDetector(
            key: ValueKey(dir.id),
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
                          dir['name'],
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
