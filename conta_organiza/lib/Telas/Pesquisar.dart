import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class Pesquisar extends StatefulWidget {
  final List<Map<String, dynamic>> files;

  Pesquisar({required this.files});

  @override
  _PesquisarState createState() => _PesquisarState();
}

class _PesquisarState extends State<Pesquisar> {
  List<Map<String, dynamic>> _filteredFiles = [];
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _filteredFiles = widget.files;
  }

  void _filterFiles() {
    List<Map<String, dynamic>> filtered = widget.files.where((file) {
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
              decoration: InputDecoration(labelText: 'Nome do Arquivo'),
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
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                          : 'Selecionar Data',
                      style: TextStyle(decoration: TextDecoration.underline),
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
