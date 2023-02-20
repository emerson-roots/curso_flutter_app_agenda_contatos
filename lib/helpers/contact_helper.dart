import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();
  bool _createdDatabase = false;

  Database? _db;

  Future<Database?> get db async {
    if (_createdDatabase) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db3");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      String sql =
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, "
          "$phoneColumn TEXT, $imgColumn TEXT)";

      await db.execute(sql);
      _createdDatabase = true;
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database? dbContact = await db;

    contact.id = await dbContact?.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;

    List<Map> maps = await dbContact!.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database? dbContact = await db;
    return await dbContact!.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database? dbContact = await db;
    return await dbContact!.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List<Contact>> getAllContacts() async {
    Database? dbContact = await db;
    List listMap = await dbContact!.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<List<Contact>> findContactsByName(String name) async {
    Database? dbContact = await db;
    List listMap = await dbContact!.rawQuery("SELECT * FROM $contactTable where $nameColumn like '%$name%'");
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<bool> isContactRegistered(String name) async {
    Database? dbContact = await db;
    List listMap = await dbContact!.query(contactTable, where: '$nameColumn = ?', whereArgs: [ name ]);
    var isRegistered = listMap.isNotEmpty;
    return isRegistered;
  }

  Future<int?> getNumber() async {
    Database? dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact!.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database? dbContact = await db;
    dbContact!.close();
  }
}

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  // construtor
  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
