import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';

import '../helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  ContactPage({this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? _editedContact;
  bool _userEdited = false;

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
          onPressed: () {
            if (_editedContact!.name != null &&
                _editedContact!.name!.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _editedContact?.img != null
                            ? FileImage(File(_editedContact?.img ??
                                'sem_diretorio_na_coluna_imgColumn'))
                            : const AssetImage("images/avatar.png")
                                as ImageProvider),
                  ),
                ),
                onTap: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file == null) {
                      return;
                    } else {
                      setState(() {
                        _editedContact!.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact?.name = text;
                  });
                },
                decoration: InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: _emailController,
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.email = text;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "E-mail"),
              ),
              TextField(
                controller: _phoneController,
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.phone = text;
                },
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone"),
              )
            ],
          ),
        ),
      ),
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
