import 'dart:io';
import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';

import '../helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? _editedContact;
  bool _userEdited = false;
  ContactHelper helper = ContactHelper();
  String nomeNaPrimeiraInstanciacaoDaPagina = "";

  // controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      // pega os dados do contato passado no parametro e passa para tela
      _nameController.text =
          _editedContact!.name != null ? _editedContact!.name! : "";
      _emailController.text =
          _editedContact!.email != null ? _editedContact!.email! : "";
      _phoneController.text =
          _editedContact!.phone != null ? _editedContact!.phone! : "";

      nomeNaPrimeiraInstanciacaoDaPagina = _nameController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact?.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var isNameValido = _editedContact!.name != null &&
                _editedContact!.name!.isNotEmpty;
            var isPhoneValido = _editedContact!.phone != null &&
                _editedContact!.phone!.isNotEmpty;

            if (!isNameValido) {
              await _showMyDialog(context, "Campo obrigatório",
                  "O nome do contato é obrigatório.");
              FocusScope.of(context).requestFocus(_nameFocus);
              return;
            } else if (!isPhoneValido) {
              await _showMyDialog(context, "Campo obrigatório",
                  "O número de telefone é obrigatório.");
              return;
            } else {
              var isRegistered =
                  await helper.isContactRegistered(_editedContact!.name!);

              if (isRegistered &&
                  nomeNaPrimeiraInstanciacaoDaPagina
                          .compareTo(_editedContact!.name!) !=
                      0) {
                await _showMyDialog(context, "Contato duplicado",
                    "O contato já está cadastrado.");
                return;
              }

              Navigator.pop(context, _editedContact);
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              _componenteDeFoto(),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact?.name = text;
                  });
                },
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: _emailController,
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.email = text;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "E-mail"),
              ),
              TextField(
                controller: _phoneController,
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.phone = text;
                },
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _componenteDeFoto() {
    return Stack(
      children: <Widget>[
        Container(
          width: 140.0,
          height: 140.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.cover,
                image: _editedContact?.img != null
                    ? FileImage(
                        File(_editedContact?.img ??
                            'sem_diretorio_na_coluna_imgColumn'),
                      )
                    : const AssetImage("images/avatar.png") as ImageProvider),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 12,
          child: Container(
            width: 35,
            height: 35,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                border: Border.all(width: 0.7),
                color: Colors.white,
                shape: BoxShape.circle),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 26,
              icon: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                openCamera(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  void openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCamera(
          onFile: (file) {
            Navigator.pop(context);
            setState(() {
              _editedContact!.img = file.path;
            });
          },
        ),
      ),
    );
  }

  Future<void> _showMyDialog(
      BuildContext context, String titulo, String mensagem) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(mensagem),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Descartar alterações?",
                  style: TextStyle(
                    color: Colors.red,
                  )),
              content: const Text(
                  "Se sair as alterações serão perdidas, deseja confirmar?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Sim"),
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
