import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class InfoConta extends StatefulWidget {
  final String directoryName;

  InfoConta({required this.directoryName});

  @override
  _InfoContaState createState() => _InfoContaState();
}

class _InfoContaState extends State<InfoConta> {
  List<Map<String, dynamic>> files = [];

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        files.add({
          'file': File(result.files.single.path!),
          'date': DateTime.now(),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.directoryName),
      ),
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: pickFiles,
            icon: Icon(Icons.upload_file),
            label: Text('Carregar Arquivo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff838DFF),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                File file = files[index]['file'];
                String fileName = file.path.split('/').last;
                DateTime fileDate = files[index]['date'];
                return ListTile(
                  title: Text(fileName),
                  subtitle: Text('Data: ${fileDate.toLocal()}'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Navegar para visualização ou outra ação
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
