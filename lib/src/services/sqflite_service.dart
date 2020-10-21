import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../datamodels/cluster_model.dart';
import '../datamodels/contact_model.dart';
import '../datamodels/clusterhistory_model.dart';

class ClusterHistoryDB {
  static final ClusterHistoryDB _instance = ClusterHistoryDB._();
  static Database _database;

  ClusterHistoryDB._();

  factory ClusterHistoryDB() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await init();
    return _database;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String pathtoDB = join(directory.path, 'ct.db');
    var database = openDatabase(pathtoDB, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return database;
  }

  // Erstellt das Datenbank Schema, wenn die Datenbank angelegt wurde.
  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE clusters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ort TEXT NOT NULL,
        anzahlpersonen TEXT DEFAULT '0',
        datum INTEGER)
    ''');
    db.execute('''
      CREATE TABLE Contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vorname TEXT DEFAULT '',
        nachname TEXT DEFAULT '',
        strasse TEXT DEFAULT '',
        ort TEXT DEFAULT '',
        plz TEXT DEFAULT '',
        telefonnummer  TEXT DEFAULT '',
        adddatum INTEGER NOT NULL)
    ''');
    db.execute('''
      CREATE TABLE qrcontact(
        id INTEGER PRIMARY KEY,
        vorname TEXT DEFAULT '',
        nachname TEXT DEFAULT '',
        strasse TEXT DEFAULT '',
        ort TEXT DEFAULT '',
        plz TEXT DEFAULT '',
        telefonnummer  TEXT DEFAULT '',
        adddatum INTEGER NOT NULL)
    ''');
    db.execute('''
      CREATE TABLE clusterhistory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clusterID REFERENCES clusters(id) ON DELETE CASCADE ON UPDATE NO ACTION,
        contactID REFERENCES Contacts(id) ON DELETE CASCADE ON UPDATE NO ACTION
        )''');
  }

  // Function notwendig, wenn man das Datenbank-Schema ändern möchte in einer neuen Version
  void _onUpgrade(Database db, int oldVersion, int newVersion) {}

// #####################################
// ## CRUD-Operationen ##
// #####################################

  // Legt ein Cluster in der Tabel clusters an
  Future<int> addCluster(Clusters cluster) async {
    var client = await db;
    return client.insert('clusters', cluster.maptodb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Legt einen Kontakt in der Tabel Contacts an
  Future<int> addcontact(Contacts contact) async {
    var client = await db;
    return client.insert('Contacts', contact.maptodb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Legt die Kontaktinformationen an, woraus der QR-Code generiert wird
  Future<int> addQRcontact(Contacts contact) async {
    var client = await db;
    return client.insert('qrcontact', contact.maptodb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Holt die Kontaktdaten aus der Tabel qrcontact, um den QR-Code zu generieren
  // Der QR-User bekommt immer die ID = 1
  Future<Contacts> getQRcontact() async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('qrcontact', where: 'id = 1');
    var maps = await futureMaps;

    if (maps.length != 0) {
      return Contacts.mapfromdb(maps.first);
    }

    return null;
  }

  // Holt einen Contact aus der Datenbank
  Future<Contacts> getContact(int id) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('Contacts', where: 'id = ?', whereArgs: [id]);
    var maps = await futureMaps;

    if (maps.length != 0) {
      return Contacts.mapfromdb(maps.first);
    }

    return null;
  }


  // Diese Function überprüft, ob ein Kontaktinformationen, die eingescannt wurde, schon vorhanden sind.
  // Wenn die Kontaktdaten vorhanden sind, wird die contactID zurückgegeben
  Future<int> checkQRScanexist(Contacts contact) async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
        'Contacts',
        where:
            'vorname = ? AND nachname = ? AND strasse = ? AND ort = ? AND plz = ? AND telefonnummer = ?',
        whereArgs: [
          contact.vorname,
          contact.nachname,
          contact.strasse,
          contact.ort,
          contact.plz,
          contact.telefonnummer
        ]);
    var maps = await futureMaps;

    if (maps.length != 0) {
      int contactID = Contacts.mapfromdb(maps.first).id;
      return contactID;
    }

    return null;
  }

  // Holt die Kontaktinformationen aus der Tabel qrcontact und erstellt einen Base64 Code, um daraus einen QR-Code zu generieren.
  // Um die contactID und das ADDDATUM aus dem String zu entfernen, wird die MAP mapfromdbforJSON verwendet.
  // TO-DO Bessere Möglichkeit suchen
  Future<String> getQRcontactJSONString() async {
    var client = await db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        client.query('qrcontact', where: 'id = 1');
    var maps = await futureMaps;

    if (maps.length != 0) {
      Contacts tmpconvert = Contacts.mapfromdbforJSON(maps.first);
      String jsonstringqrcontact = jsonEncode(tmpconvert.maptodb());
      String base64encodedQRcontact =
          base64.encode(utf8.encode(jsonstringqrcontact));
      return base64encodedQRcontact;
    }

    return null;
  }

  // Updated Kontakt-Informationen
  Future<int> updatecontact(Contacts contact) async {
    var client = await db;
    return client.update('Contacts', contact.maptodb(),
        where: 'id= ?',
        whereArgs: [contact.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Updated Kontakt-Informationen für den QR-Code
  Future<int> updateQRcontact(Contacts qrcontact) async {
    var client = await db;
    return client.update('qrcontact', qrcontact.maptodb(),
        where: 'id= ?',
        whereArgs: [qrcontact.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Updated Cluster-Informationen
  Future<int> updateCluster(Clusters cluster) async {
    var client = await db;
    return client.update('clusters', cluster.maptodb(),
        where: 'id= ?',
        whereArgs: [cluster.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Holt alle Clusters und sortiert diese nach Datum
  // Das Datum liegt als INT in milliseconds since Epoch vor
  Future<List<Clusters>> getAllClusters() async {
    var client = await db;
    var result = await client.query('clusters', orderBy: 'datum');

    if (result.isNotEmpty) {
      var clusters =
          result.map((clusterMap) => Clusters.mapfromdb(clusterMap)).toList();
      return clusters;
    }
    return [];
  }

  // Holt alle Kontaktinformationene und sortiert diese nach Vornamen
  Future<List<Contacts>> getAllContacts() async {
    var client = await db;
    var result = await client.query('Contacts', orderBy: 'vorname');

    if (result.isNotEmpty) {
      var contacts =
          result.map((contactMap) => Contacts.mapfromdb(contactMap)).toList();
      return contacts;
    }
    return [];
  }

  // Holt alle Kontaktinformationen die einem Cluster zugeordnet sind. Dazu wird ein INNER JOIN mit der Junction Table clusterhistory gemacht
  Future<List<Contacts>> getAllContactsFromClusterID(int clusterID) async {
    var client = await db;
    var result = await client.rawQuery(
        'SELECT Contacts.* FROM Contacts INNER JOIN clusterhistory ON Contacts.id = clusterhistory.contactID WHERE clusterhistory.clusterID = ? ORDER BY Contacts.nachname',
        [clusterID]);

    if (result.isNotEmpty) {
      var contacts =
          result.map((contactMap) => Contacts.mapfromdb(contactMap)).toList();
      return contacts;
    }
    return [];
  }

  // Holt alle Clusters die einem Kontakt zugeordnet sind. Dazu wird ein INNER JOIN mit der Junction Table clusterhistory gemacht
  Future<List<Clusters>> getAllClustersFromcontactID(int contactID) async {
    var client = await db;
    var result = await client.rawQuery(
        'SELECT clusters.* FROM clusters INNER JOIN clusterhistory ON clusters.id = clusterhistory.clusterID WHERE clusterhistory.contactID = ? ORDER BY clusters.datum DESC',
        [contactID]);

    if (result.isNotEmpty) {
      var clusters =
          result.map((clusterMap) => Clusters.mapfromdb(clusterMap)).toList();
      return clusters;
    }
    return [];
  }

  // Speichert die Verknüpfung von Cluster und Kontaktinformationen in einer Junction Table
  Future<bool> addClusterHistory(ClusterHistory clusterHistory) async {
    var client = await db;
    var checkexisting = await client.query('clusterhistory',
        where: 'clusterID = ? AND contactID = ?',
        whereArgs: [clusterHistory.clusterID, clusterHistory.contactID]);
    if (checkexisting.isEmpty) {
      client.insert('clusterhistory', clusterHistory.maptodb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } else {
      return false;
    }
  }

  // Löscht ein Cluster
  Future<void> deleteCluster(int id) async {
    var client = await db;
    client.delete('clusters', where: 'id = ?', whereArgs: [id]);
    return client
        .delete('clusterhistory', where: 'clusterID = ?', whereArgs: [id]);
  }

  // Löscht Clusters welche älter sind als day in milliseconds since Epoch
  Future<void> deleteClusterAfterDays(int day) async {
    var client = await db;
    client.delete('clusters', where: 'datum < ?', whereArgs: [day]).then(
        (clientID) => client.delete('clusterhistory',
            where: 'clusterID = ?', whereArgs: [clientID]));
  }

  // Löscht einen Kontakt
  Future<void> deletecontact(int id) async {
    var client = await db;
    client.delete('Contacts', where: 'id = ?', whereArgs: [id]);
    return client
        .delete('clusterhistory', where: 'contactID = ?', whereArgs: [id]);
  }

  // Löscht Kontaktinformationen welche älter sind als day in milliseconds since Epoch
  Future<void> deleteContactsAfterDays(int day) async {
    var client = await db;
    client.delete('Contacts', where: 'adddatum < ?', whereArgs: [day]);
  }

  // Löscht einen Eintrag in der Junction Table
  Future<void> deleteClusterHistoryRelation(int clusterID, contactID) async {
    var client = await db;
    return client.delete('clusterhistory',
        where: 'clusterID = ? AND contactID = ?',
        whereArgs: [clusterID, contactID]);
  }

  // Löscht alle Cluster, aktuell nicht in Verwendung
  Future<void> deleteAllCluster() async {
    var client = await db;
    return client.delete('clusters');
  }

  // Löscht alle Kontakte, aktuell nicht in Verwendung
  Future<void> deleteAllcontact() async {
    var client = await db;
    return client.delete('Contacts');
  }

  // Schließt die Datenbank-Instanz, benötigt?
  Future closeDB() async {
    var client = await db;
    client.close();
  }
}
