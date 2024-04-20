import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CadastrarUsuario extends StatefulWidget {
  const CadastrarUsuario({super.key});

  @override
  _CadastrarUsuarioState createState() => _CadastrarUsuarioState();
}

class _CadastrarUsuarioState extends State<CadastrarUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomeUsuarioController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastrar de Usuário',
          style: TextStyle(
            color: Color(0xffffffff),
            fontFamily: 'Inter',
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff838DFF),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Nome completo',
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 20,
                color: Color(0xff000000),
              ),
            ),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xff838DFF)), // Cor da borda
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  color: Color(0xff000000),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xff000000),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe seu nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'E-mail',
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 20,
                color: Color(0xff000000),
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xff838DFF)), // Cor da borda
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  color: Color(0xff000000),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xff000000),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe seu e-mail';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Nome usuário',
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 20,
                color: Color(0xff000000),
              ),
            ),
            TextFormField(
              controller: _nomeUsuarioController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xff838DFF)), // Cor da borda
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  color: Color(0xff000000),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xff000000),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe seu nome de usuário';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Senha',
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 20,
                color: Color(0xff000000),
              ),
            ),
            TextFormField(
              controller: _senhaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(0xff838DFF)), // Cor da borda
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  color: Color(0xff000000),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xff000000),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Defina uma senha';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Todos os campos foram preenchidos corretamente
                  // Faça o que precisar aqui, como enviar os dados para o servidor
                }
              },
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
