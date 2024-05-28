import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conta_organiza/Telas/CustomAppBar.dart'; // Certifique-se de ajustar o caminho conforme necessário

class TelaNotificacao extends StatefulWidget {
  const TelaNotificacao({super.key});

  @override
  _TelaNotificacaoState createState() => _TelaNotificacaoState();
}

class _TelaNotificacaoState extends State<TelaNotificacao> {
  bool _pushNotifications = false;
  bool _emailNotifications = false;
  DateTime? _dueDate;
  String _userName = 'Nome do Usuário';
  String _userProfileImage = 'assets/images/Foto do perfil.png';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('pushNotifications') ?? false;
      _emailNotifications = prefs.getBool('emailNotifications') ?? false;
      final dueDateString = prefs.getString('dueDate');
      if (dueDateString != null) {
        _dueDate = DateTime.parse(dueDateString);
      }
      _userName = prefs.getString('userName') ?? 'Nome do Usuário';
      _userProfileImage = prefs.getString('userProfileImage') ??
          'assets/images/Foto do perfil.png';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setBool('emailNotifications', _emailNotifications);
    if (_dueDate != null) {
      await prefs.setString('dueDate', _dueDate!.toIso8601String());
    }
  }

  void _togglePushNotifications(bool value) {
    setState(() {
      _pushNotifications = value;
    });
    _saveSettings();
  }

  void _toggleEmailNotifications(bool value) {
    setState(() {
      _emailNotifications = value;
    });
    _saveSettings();
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userName: _userName,
        userProfileImage: _userProfileImage,
        title: 'Notificações',
        onUpdateProfileImage: (String) {},
        onUpdateUserName: (String) {},
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color:
                          Color(0xffD2D6FF), // Cor de fundo ao redor do botão
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Receber notificações push',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                trailing: Switch(
                  value: _pushNotifications,
                  onChanged: _togglePushNotifications,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
              ),
              ListTile(
                title: Text(
                  'Notificações por email',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                trailing: Switch(
                  value: _emailNotifications,
                  onChanged: _toggleEmailNotifications,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
              ),
              ListTile(
                title: Text(
                  'Inserir a data de vencimento',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _pickDueDate,
                ),
              ),
              if (_dueDate != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Data de vencimento: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
