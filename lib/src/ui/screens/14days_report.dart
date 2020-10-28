import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

import '../../datamodels/contact_model.dart';
import '../../services/sqflite_service.dart';
import '../colorscheme.dart';
import 'edit_contactscreen.dart';
import 'pdfreport_screen.dart';

class DaysReportScreen extends StatefulWidget {
  @override
  _DaysReportScreenState createState() => _DaysReportScreenState();
}

class _DaysReportScreenState extends State<DaysReportScreen> {
  final db = ClusterHistoryDB();
  List<Contacts> contacts = [];
  int kontaktcount = 0;
  int clustercount = 0;
  double currentSliderdaysValue = 14;
  final df = new DateFormat('dd.MM.yyyy');
  @override
  void initState() {
    super.initState();
    _setupContactsList();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                Icons.download_sharp,
                size: 29,
              ),
              onPressed: () async {
                if (await _getQRContact() != null) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return showDatenschutzAlertDialog();
                    },
                  );
                } else {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return showQRUserAlertDialog();
                    },
                  );
                }
              },
            ),
          ),
        ],
        title: Text(currentSliderdaysValue.round().toString() + '-Tage-Report'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(bottom: 90),
          child: Column(
            children: [
              Card(
                elevation: 8,
                margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                child: Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: Slider(
                    value: currentSliderdaysValue,
                    min: 1,
                    max: 14,
                    onChanged: (double value) {
                      setState(() {
                        currentSliderdaysValue = value;
                      });
                      _setupContactsList();
                    },
                  ),
                ),
              ),
              Card(
                elevation: 8,
                margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 20, right: 30),
                  leading: Icon(Icons.note),
                  title: Text('Anzahl der Cluster'),
                  trailing: CircleAvatar(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      child: Text(clustercount.toString())),
                ),
              ),
              Card(
                elevation: 8,
                margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 20, right: 30),
                  leading: Icon(Icons.people),
                  title: Text('Anzahl der Kontakte'),
                  trailing: CircleAvatar(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      child: Text(kontaktcount.toString())),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
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
                      'Kontakte',
                      style:
                          TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
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
                    return customUserListView(context, contacts[index]);
                  }),
            ],
          ),
        ),
      ),
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

  Future<Uint8List> _generatePdf() async {
    final font = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);
    final pdf = pw.Document();
    Contacts _owncontact = await _getQRContact();

    final PdfImage image = PdfImage.file(
      pdf.document,
      bytes: (await rootBundle.load('assets/icon/Cluster_Tagebuch_Icon.png'))
          .buffer
          .asUint8List(),
    );
    pdf.addPage(
      pw.MultiPage(
        maxPages: 100,
        header: (context) => pw.Container(
          margin: pw.EdgeInsets.only(top: 50, bottom: 50),
          child: pw.Column(
            children: [
              pw.Row(children: [
                pw.Container(
                  height: 50,
                  width: 50,
                  child: pw.Image(image),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  'Cluster-Tagebuch Report',
                  style: pw.TextStyle(font: ttf, fontSize: 32),
                ),
              ]),
              pw.SizedBox(height: 80),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Der Report wurde erstellt von:',
                            style: pw.TextStyle(font: ttf, fontSize: 16)),
                        pw.SizedBox(height: 20),
                        pw.Text(
                            _owncontact.vorname + ' ' + _owncontact.nachname,
                            style: pw.TextStyle(font: ttf)),
                        pw.Text(_owncontact.strasse,
                            style: pw.TextStyle(font: ttf)),
                        pw.Text(_owncontact.plz + ' ' + _owncontact.ort,
                            style: pw.TextStyle(font: ttf)),
                        pw.Text(_owncontact.telefonnummer,
                            style: pw.TextStyle(font: ttf)),
                      ]),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 30),
                      pw.Text('Erstellt am: ' + df.format(DateTime.now()),
                          style: pw.TextStyle(font: ttf)),
                      pw.Text('Alle Kontakte der',
                          style: pw.TextStyle(font: ttf)),
                      pw.Text(
                          'letzten ' +
                              currentSliderdaysValue.round().toString() +
                              ' Tage.',
                          style: pw.TextStyle(font: ttf)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                  'Erstellt mit "Cluster-Tagebuch" - Quellcode: cluster-tagebuch.de',
                  style: pw.TextStyle(font: ttf)),
              pw.Text(
                  'Seite ' +
                      context.pageNumber.toString() +
                      ' von ' +
                      context.pagesCount.toString(),
                  style: pw.TextStyle(font: ttf)),
            ],
          ),
        ),
        build: (context) => [
          pw.Text('Kontaktliste ',
              style: pw.TextStyle(font: ttf, fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>[
                'Vorname',
                'Nachname',
                'Straße',
                'Postleitzahl',
                'Ort',
                'Telefonnummer'
              ],
              ...contacts.map((contact) => [
                    contact.vorname,
                    contact.nachname,
                    contact.strasse,
                    contact.plz,
                    contact.ort,
                    contact.telefonnummer
                  ])
            ],
            headerStyle: pw.TextStyle(font: ttf),
            cellStyle: pw.TextStyle(font: ttf),
            cellAlignment: pw.Alignment.center,
            oddCellStyle: pw.TextStyle(font: ttf),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  showQRUserAlertDialog() {
    return AlertDialog(
      title: Text('Kontaktdaten'),
      content: SingleChildScrollView(
        child: Text(
            'Ihre Kontaktdaten werden im PDF-Report hinterlegt, um dieses Dokument Ihnen zuordnen zu können. Hierzu werden die Daten aus dem QR-Kontaktfeld entnommen. Bitte geben Sie Ihre Kontaktdaten zunächst ein und versuchen Sie es erneut.'),
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('Eingeben'),
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/qrscreen');
          },
        ),
      ],
    );
  }

  showDatenschutzAlertDialog() {
    return AlertDialog(
      title: Text('Datenschutzhinweis'),
      content: SingleChildScrollView(
        child: Text(
            'Das folgende PDF-Dokument enthält personenbezogene Daten. Geben Sie diese Daten nur den Gesundheitsbehörden zur Kontaktnachverfolgung, wenn Sie dazu aufgefordert werden. Die Weitergabe an Dritte ist nur mit der ausdrücklichen Zustimmung der jeweiligen Person, auf denen sich die Daten beziehen, zulässig. Beim Drücken auf den Button "Verstanden und Bestätigen" nehmen Sie diese Hinweise zur Kenntnis und sind für die sichere und datenschutzkonforme Weitergabe verantwortlich.'),
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('Verstanden und Bestätigen'),
          onPressed: () async {
            Navigator.pop(context);
            _navigateToPDFReportScreen(context, _generatePdf());
          },
        ),
      ],
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

  _navigateToPDFReportScreen(BuildContext context, pdf) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PDFReportScreen(
                pdf: pdf,
              )),
    );
    if (result != null) {}
  }

  Future<Contacts> _getQRContact() async {
    Contacts qruser = await db.getQRcontact();
    return qruser;
  }

  void _setupContactsList() async {
    var _contacts =
        await db.getAllContacts14DaysReport(currentSliderdaysValue.round());
    int _clustercount =
        await db.getClustersCount14Days(currentSliderdaysValue.round());
    setState(() {
      kontaktcount = _contacts.length;
      clustercount = _clustercount;
      contacts = _contacts;
    });
  }
}
