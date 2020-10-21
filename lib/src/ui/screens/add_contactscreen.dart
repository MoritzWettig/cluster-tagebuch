import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../datamodels/contact_model.dart';
import '../../services/sqflite_service.dart';

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final db = ClusterHistoryDB();
  final vornameController = TextEditingController();
  final nachnameController = TextEditingController();
  final strasseController = TextEditingController();
  final ortController = TextEditingController();
  final plzController = TextEditingController();
  final telefonnummerController = TextEditingController();

  @override
  void dispose() {
    vornameController.dispose();
    nachnameController.dispose();
    strasseController.dispose();
    ortController.dispose();
    plzController.dispose();
    telefonnummerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
          title: Text('Kontakt hinzufügen'),
        ),
        body: Column(
          children: [contactInputField(context), customImportContactButton()],
        ),
      ),
    );
  }

  Form contactInputField(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        child: Card(
          elevation: 9,
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                        margin: EdgeInsets.only(left: 30, right: 30),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Bitte ausfüllen';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Name',
                          ),
                          controller: nachnameController,
                        )),
                  ),
                  Flexible(
                    child: Container(
                        margin: EdgeInsets.only(left: 30, right: 30),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Bitte ausfüllen';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Vorname',
                          ),
                          controller: vornameController,
                        )),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: customTextFieldForm('Straße und Hausnummer',
                    strasseController, TextInputType.text),
              ),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: customTextFieldForm(
                          'Postleitzahl', plzController, TextInputType.number),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: customTextFieldForm(
                        'Ort',
                        ortController,
                        TextInputType.text,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: customTextFieldForm(
                  'Telefonnummer',
                  telefonnummerController,
                  TextInputType.numberWithOptions(),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(top: 30, right: 100, left: 100, bottom: 20),
                color: Colors.teal,
                child: FlatButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        await db.addcontact(Contacts(
                            vorname: vornameController.text,
                            nachname: nachnameController.text,
                            strasse: strasseController.text,
                            ort: ortController.text,
                            plz: plzController.text,
                            telefonnummer: telefonnummerController.text,
                            adddatum: DateTime.now().millisecondsSinceEpoch));
                        Navigator.pop(context, true);
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
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customImportContactButton() {
    return Container(
      margin: EdgeInsets.only(top: 30, right: 50, left: 50, bottom: 20),
      color: Colors.teal,
      child: FlatButton(
        onPressed: () async {
          if (await Permission.contacts.request().isGranted) {
            _pickContact();
          } else if (await Permission.contacts.isPermanentlyDenied |
              await Permission.contacts.isDenied) {
            await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return showContactAlertDialog();
              },
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts,
              color: Colors.white,
            ),
            SizedBox(width:20),
            Text(
              'Aus Adressbuch importieren',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickContact() async {
    try {
      final Contact _contact = await ContactsService.openDeviceContactPicker();
      if (_contact.phones.isNotEmpty && _contact.phones.length != 1) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Telefonnummer auswählen'),
              content: setupAlertDialoadContainer(_contact.phones),
              actions: [
                FlatButton(
                    child: Text('Keine Nummer übernehmen'),
                    onPressed: () {
                      setState(() {
                        telefonnummerController.text = "";
                      });
                      Navigator.of(context).pop();
                    }),
              ],
            );
          },
        );
      } else if (_contact.phones.isNotEmpty && _contact.phones.length == 1) {
        setState(() {
          vornameController.text = _contact.givenName;
          nachnameController.text = _contact.familyName;
          telefonnummerController.text = _contact.phones.elementAt(0).value;
        });
      }
      setState(() {
        vornameController.text = _contact.givenName;
        nachnameController.text = _contact.familyName;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Widget setupAlertDialoadContainer(phones) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        height: 200,
        width: 300,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: phones.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.teal,
              child: ListTile(
                onTap: () {
                  setState(() {
                    telefonnummerController.text =
                        phones.elementAt(index).value;
                  });
                  Navigator.of(context).pop();
                },
                leading: Icon(
                  Icons.phone,
                  color: Colors.white,
                ),
                title: Text(
                  phones.elementAt(index).value,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  showContactAlertDialog() {
    return AlertDialog(
      title: Text('Fehlende Berechtigung'),
      content: Text(
          'Sie haben Cluster Tagebuch das Lesen Ihrer Kontakte verboten. Zum Nutzen der Funktion bitte Cluster Tagebuch den Zugriff auf Ihre Kontakte gewähren.'),
      actions: <Widget>[
        FlatButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('Einstellungen öffnen'),
          onPressed: () async {
            openAppSettings();
          },
        ),
      ],
    );
  }

  TextFormField customTextFieldForm(String label, controller, keyboardtype) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      keyboardType: keyboardtype,
      cursorColor: Theme.of(context).primaryColor,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
      ),
      controller: controller,
    );
  }
}
