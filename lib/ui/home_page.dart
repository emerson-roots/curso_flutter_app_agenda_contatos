import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();


  @override
  void initState() {
    super.initState();
    Contact c = Contact();

    // exemplo para salvar contato (aula 169)
  /*  c.name = "Joséfa Tester";
    c.email = "Joséfa@Joséfa.com";
    c.phone = "99-8888-1111";
    c.img = "img teste 2";

    helper.saveContact(c);*/

    // exemplo para recuperar contatos (aula 169)
    helper.getAllContacts().then((list) {
      print(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
