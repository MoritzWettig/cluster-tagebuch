import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../datamodels/contact_model.dart';
import '../../services/sqflite_service.dart';
import '../colorscheme.dart';

class QRScreen extends StatefulWidget {
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  final _formKey = GlobalKey<FormState>();
  final db = ClusterHistoryDB();
  final vornameController = TextEditingController();
  final nachnameController = TextEditingController();
  final strasseController = TextEditingController();
  final ortController = TextEditingController();
  final plzController = TextEditingController();
  final telefonnummerController = TextEditingController();
  Contacts qruser;
  String qrdata = 'Willkommen beim Cluster Tagebuch';

  @override
  void initState() {
    super.initState();
    initQRUser();
  }

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
        key: _scaffoldKey,
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
          title: Text('QR Kontaktdaten'),
        ),
        body: ListView(
          controller: _scrollController,
          children: [
            qrCodeShow(qrdata),
            textFieldsQRUser(),
          ],
        ),
      ),
    );
  }

  Widget qrCodeShow(String qrdata) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(left: 3, right: 3, top: 5),
      child: QrImage(
        data: qrdata,
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        version: QrVersions.auto,
        foregroundColor: Theme.of(context).colorScheme.qrcodeforeground,
        size: 360.0,
      ),
    );
  }

  Widget textFieldsQRUser() {
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.only(left: 3, right: 3, top: 6, bottom: 15),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    'Deine Kontaktdaten',
                    style: TextStyle(fontSize: 22),
                  )),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: customTextFieldForm(
                          'Name', nachnameController, TextInputType.text),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: customTextFieldForm(
                          'Vorname', vornameController, TextInputType.text),
                    ),
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
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: Theme.of(context).primaryColor,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Bitte Daten eingeben';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onTap: () {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  },
                  decoration: InputDecoration(
                    labelText: 'Telefonnummer',
                  ),
                  controller: telefonnummerController,
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(top: 30, right: 100, left: 100, bottom: 20),
                color: Colors.teal,
                child: FlatButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (qruser != null) {
                          await db.updateQRcontact(Contacts(
                              id: 1,
                              vorname: vornameController.text,
                              nachname: nachnameController.text,
                              strasse: strasseController.text,
                              ort: ortController.text,
                              plz: plzController.text,
                              telefonnummer: telefonnummerController.text,
                              adddatum: DateTime.now().millisecondsSinceEpoch));
                          _displaySnackBar(context,
                              'Deine Kontaktdaten wurden aktualisiert!');
                          initQRUser();
                        } else {
                          await db.addQRcontact(Contacts(
                              id: 1,
                              vorname: vornameController.text,
                              nachname: nachnameController.text,
                              strasse: strasseController.text,
                              ort: ortController.text,
                              plz: plzController.text,
                              telefonnummer: telefonnummerController.text,
                              adddatum: DateTime.now().millisecondsSinceEpoch));
                          _displaySnackBar(context,
                              'Deine Kontaktdaten wurden hinzugefügt!');
                          initQRUser();
                        }
                        FocusScope.of(context).unfocus();
                        _scrollController.animateTo(
                            _scrollController.position.minScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut);
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

  TextFormField customTextFieldForm(String label, controller, keyboardtype) {
    return TextFormField(
      keyboardType: keyboardtype,
      textCapitalization: TextCapitalization.sentences,
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

  _displaySnackBar(BuildContext context, message) {
    final snackBar = SnackBar(
        backgroundColor: Colors.teal,
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void initQRUser() async {
    var _qruser = await db.getQRcontact();
    String _qruserjsonstring = await db.getQRcontactJSONString();
    if (_qruser != null && _qruserjsonstring != null) {
      setState(
        () {
          qruser = _qruser;
          vornameController.text = _qruser.vorname;
          nachnameController.text = _qruser.nachname;
          strasseController.text = _qruser.strasse;
          plzController.text = _qruser.plz.toString();
          ortController.text = _qruser.ort;
          telefonnummerController.text = _qruser.telefonnummer.toString();
          qrdata = _qruserjsonstring;
        },
      );
    }
  }
}
