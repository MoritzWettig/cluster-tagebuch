import 'dart:convert';
import 'package:search_page/search_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barcode_scan/barcode_scan.dart';

import '../../datamodels/cluster_model.dart';
import '../../datamodels/clusterhistory_model.dart';
import '../../datamodels/contact_model.dart';
import '../../services/sqflite_service.dart';
import '../colorscheme.dart';
import 'edit_contactscreen.dart';

class EditClusterScreen extends StatefulWidget {
  final Clusters cluster;
  @override
  _EditClusterScreenState createState() => _EditClusterScreenState();
  EditClusterScreen({this.cluster});
}

class _EditClusterScreenState extends State<EditClusterScreen> {
  final db = ClusterHistoryDB();
  List<Contacts> contacts = [];
  final nameController = TextEditingController();
  final ortController = TextEditingController();
  final anzahlController = TextEditingController();
  final datumController = TextEditingController();
  final df = new DateFormat('dd.MM.yyyy HH:mm');
  int selectedtime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.cluster.name;
    ortController.text = widget.cluster.ort;
    anzahlController.text = widget.cluster.anzahlpersonen.toString();
    datumController.text = df.format(
      DateTime.fromMillisecondsSinceEpoch(widget.cluster.datum),
    );
    _setupContactsList();
  }

  @override
  void dispose() {
    nameController.dispose();
    ortController.dispose();
    anzahlController.dispose();
    datumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            icon: Icon(
              Icons.navigate_before,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text('Cluster bearbeiten'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: Icon(
                Icons.qr_code_scanner,
                size: 28,
              ),
              onPressed: () {
                qrscan();
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            children: [customEditField(context), _buildUserList()],
          ),
        ),
      ),
      floatingActionButton: _customFAB(),
    );
  }

  Form customEditField(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        child: Card(
          elevation: 9,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: 5),
                child: customTextFieldForm(
                    'Name des Clusters', nameController, TextInputType.text),
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: 5),
                child: customTextFieldForm(
                    'Ort des Clusters', ortController, TextInputType.text),
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: 5),
                child: customTextFieldForm('Geschätze Anzahl an Personen',
                    anzahlController, TextInputType.number),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 30),
                child: GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    _customdatepicker();
                  },
                  child: AbsorbPointer(
                    child: Row(
                      children: [
                        Flexible(
                          child: customTextFieldForm('Datum des Clusters',
                              datumController, TextInputType.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(top: 10, right: 100, left: 100, bottom: 20),
                color: Colors.teal,
                child: FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      if (selectedtime != null) {
                        await db.updateCluster(Clusters(
                            id: widget.cluster.id,
                            name: nameController.text,
                            ort: ortController.text,
                            anzahlpersonen: anzahlController.text,
                            datum: selectedtime));
                        Navigator.pop(context, true);
                      } else {
                        await db.updateCluster(Clusters(
                            id: widget.cluster.id,
                            name: nameController.text,
                            ort: ortController.text,
                            anzahlpersonen: anzahlController.text,
                            datum: df
                                .parse(datumController.text)
                                .millisecondsSinceEpoch));
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      Text(
                        'Speichern',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  indent: 16,
                  endIndent: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Verknüpfte Kontakte',
                style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
              ),
              Expanded(
                child: Divider(
                  indent: 16,
                  endIndent: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) async {
                    await db.deleteClusterHistoryRelation(
                        widget.cluster.id, contacts[index].id);
                    _setupContactsList();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.teal,
                        content: Text(
                          'Verknüpfung entfernt',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: customUserListView(context, contacts[index]));
            }),
      ],
    );
  }

  Card customUserListView(BuildContext context, Contacts contact) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(left: 15, right: 15, top: 20),
      child: ListTile(
        onTap: () {
          _navigateToEditContactScreen(context, contact);
        },
        contentPadding: EdgeInsets.only(left: 10, right: 10),
        leading: Container(
          child: CircleAvatar(
            foregroundColor: Colors.white,
            backgroundColor:
                Theme.of(context).colorScheme.circleAvatarBackgroundColor,
            child: Text(contact.nachname[0].toUpperCase() +
                contact.vorname[0].toUpperCase()),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.person_pin),
            SizedBox(width: 10),
            Flexible(child: Text(contact.nachname + ', ' + contact.vorname)),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(Icons.home),
            SizedBox(width: 10),
            Flexible(
              child: (contact.ort.isNotEmpty && contact.strasse.isNotEmpty)
                  ? Text(contact.ort + ', ' + contact.strasse)
                  : (contact.ort.isNotEmpty && contact.strasse.isEmpty)
                      ? Text(contact.ort)
                      : (contact.ort.isEmpty && contact.strasse.isNotEmpty)
                          ? Text(contact.strasse)
                          : Text('Keine Angaben'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customFAB() {
    return FloatingActionButton(
      child: Icon(Icons.person_add_alt_1),
      tooltip: 'Verknüpfe einen Contact',
      onPressed: () async {
        var _allcontacts = await db.getAllContacts();
        showSearch(
          context: context,
          delegate: SearchPage(
            items: _allcontacts,
            searchLabel: 'Suche nach Kontakten',
            failure: Center(
              child: Text('Keine Kontakte gefunden'),
            ),
            filter: (user) => [
              user.vorname,
              user.nachname,
            ],
            suggestion: ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: _allcontacts.length,
                itemBuilder: (context, index) {
                  Contacts contact = _allcontacts[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                    child: ListTile(
                      onTap: () async {
                        bool result = await db.addClusterHistory(
                          ClusterHistory(
                              clusterID: widget.cluster.id,
                              contactID: contact.id),
                        );
                        if (result) {
                          Navigator.pop(context);
                          _setupContactsList();
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.teal,
                              content: Text('Verknüpfung existiert bereits',
                                  style: TextStyle(color: Colors.white)),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      onLongPress: () async {
                        bool result = await db.addClusterHistory(
                          ClusterHistory(
                              clusterID: widget.cluster.id,
                              contactID: contact.id),
                        );
                        if (result) {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.teal,
                              content: Text('Verknüpfung wurde erstellt',
                                  style: TextStyle(color: Colors.white)),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          _setupContactsList();
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.teal,
                              content: Text('Verknüpfung existiert bereits',
                                  style: TextStyle(color: Colors.white)),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      leading: Container(
                        child: CircleAvatar(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .circleAvatarBackgroundColor,
                          child: Text(contact.nachname[0].toUpperCase() +
                              contact.vorname[0].toUpperCase()),
                        ),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.person_pin),
                          SizedBox(width: 10),
                          Flexible(
                              child: Text(
                                  contact.nachname + ', ' + contact.vorname)),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.home),
                          SizedBox(width: 10),
                          Flexible(
                            child: (contact.ort.isNotEmpty &&
                                    contact.strasse.isNotEmpty)
                                ? Text(contact.ort + ', ' + contact.strasse)
                                : (contact.ort.isNotEmpty &&
                                        contact.strasse.isEmpty)
                                    ? Text(contact.ort)
                                    : (contact.ort.isEmpty &&
                                            contact.strasse.isNotEmpty)
                                        ? Text(contact.strasse)
                                        : Text('Keine Angaben'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            builder: (contact) => Builder(
              builder: (context) => Card(
                elevation: 5,
                margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                child: ListTile(
                  onTap: () async {
                    bool result = await db.addClusterHistory(
                      ClusterHistory(
                          clusterID: widget.cluster.id, contactID: contact.id),
                    );
                    if (result) {
                      Navigator.pop(context);
                      _setupContactsList();
                    } else {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.teal,
                          content: Text('Verknüpfung existiert bereits',
                              style: TextStyle(color: Colors.white)),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  onLongPress: () async {
                    bool result = await db.addClusterHistory(
                      ClusterHistory(
                          clusterID: widget.cluster.id, contactID: contact.id),
                    );
                    if (result) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.teal,
                          content: Text('Verknüpfung wurde erstellt',
                              style: TextStyle(color: Colors.white)),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      _setupContactsList();
                    } else {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.teal,
                          content: Text('Verknüpfung existiert bereits',
                              style: TextStyle(color: Colors.white)),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  leading: Container(
                    child: CircleAvatar(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .circleAvatarBackgroundColor,
                      child: Text(contact.nachname[0].toUpperCase() +
                          contact.vorname[0].toUpperCase()),
                    ),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.person_pin),
                      SizedBox(width: 10),
                      Flexible(
                          child:
                              Text(contact.nachname + ', ' + contact.vorname)),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.home),
                      SizedBox(width: 10),
                      Flexible(
                        child: (contact.ort.isNotEmpty &&
                                contact.strasse.isNotEmpty)
                            ? Text(contact.ort + ', ' + contact.strasse)
                            : (contact.ort.isNotEmpty &&
                                    contact.strasse.isEmpty)
                                ? Text(contact.ort)
                                : (contact.ort.isEmpty &&
                                        contact.strasse.isNotEmpty)
                                    ? Text(contact.strasse)
                                    : Text('Keine Angaben'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  qrscan() async {
    var scanresult = await BarcodeScanner.scan(
        options: ScanOptions(
      strings: {"cancel": 'Abbrechen'},
    ));
    if (scanresult.rawContent.isNotEmpty) {
      String decodejsonstring =
          utf8.decode(base64.decode(scanresult.rawContent));
      Contacts qruserfromqr = Contacts.mapfromdb(jsonDecode(decodejsonstring));
      int checkqrexisting = await db.checkQRScanexist(Contacts(
        vorname: qruserfromqr.vorname,
        nachname: qruserfromqr.nachname,
        strasse: qruserfromqr.strasse,
        ort: qruserfromqr.ort,
        plz: qruserfromqr.plz,
        telefonnummer: qruserfromqr.telefonnummer,
      ));
      if (checkqrexisting != null) {
        await db.addClusterHistory(ClusterHistory(
            clusterID: widget.cluster.id, contactID: checkqrexisting));
        _setupContactsList();
      } else {
        int contactid = await db.addcontact(Contacts(
            vorname: qruserfromqr.vorname,
            nachname: qruserfromqr.nachname,
            strasse: qruserfromqr.strasse,
            ort: qruserfromqr.ort,
            plz: qruserfromqr.plz,
            telefonnummer: qruserfromqr.telefonnummer,
            adddatum: DateTime.now().millisecondsSinceEpoch));
        await db.addClusterHistory(
            ClusterHistory(clusterID: widget.cluster.id, contactID: contactid));
        _setupContactsList();
      }
    }
  }

  _customdatepicker() async {
    final datepicker = await showDatePicker(
        helpText: 'Datum des Clusters',
        cancelText: 'Abbrechen',
        confirmText: 'Datum übernehmen',
        context: context,
        firstDate: DateTime(2020),
        initialDate: DateTime.now(),
        lastDate: DateTime(2030));
    if (datepicker != null) {
      final timepicker = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          helpText: 'Uhrzeit des Clusters',
          confirmText: 'Uhrzeit übernehmen',
          cancelText: 'Abbrechen');
      if (timepicker != null) {
        final date = DateTime(datepicker.year, datepicker.month, datepicker.day,
            timepicker.hour, timepicker.minute);
        setState(() {
          selectedtime = date.millisecondsSinceEpoch;
          datumController.text = df.format(date).toString();
        });
      }
    }
  }

  TextFormField customTextFieldForm(String label, controller, keyboardtype) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      keyboardType: keyboardtype,
      cursorColor: Theme.of(context).primaryColor,
      validator: (value) {
        if (value.isEmpty) {
          return 'Bitte Daten eingeben';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
      ),
      controller: controller,
    );
  }

  _navigateToEditContactScreen(BuildContext context, Contacts contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditContactScreen(contact: contact)),
    );
    if (result != null) {
      _setupContactsList();
    }
  }

  void _setupContactsList() async {
    var _contacts = await db.getAllContactsFromClusterID(widget.cluster.id);
    setState(() {
      contacts = _contacts;
    });
  }
}
