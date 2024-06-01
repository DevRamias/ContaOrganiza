import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      setState(() {
        _files = files;
        _filteredFiles = _files;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
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
            SizedBox(height: 10),
            Row(
              children: [
                Text('Data: '),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
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
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      _filterFiles();
                    },
                  ),
              ],
            ),
            SizedBox(height: 20),
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
                    onTap: () {
                      // Ação ao clicar no arquivo
                    },
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
