import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../datamodels/cluster_model.dart';
import '../../datamodels/contact_model.dart';
import '../../services/sqflite_service.dart';
import '../colorscheme.dart';
import 'edit_clusterscreen.dart';
import 'edit_contactscreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _initpage = 0;
  bool _loading;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = ClusterHistoryDB();
  final df = new DateFormat('dd.MM.yyyy HH:mm');
  final dfnew = new DateFormat('EEEE, dd.MM.yyyy', 'DE');
  final dfnewh = new DateFormat('HH:mm');
  List<Clusters> clusters = [];
  List<Contacts> contacts = [];
  @override
  void initState() {
    super.initState();
    _loading = true;
    setupContactsList();
    setupClusterList();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: customDrawer(),
      endDrawer: customDrawer(),
      appBar: customAppBar(),
      body: _showList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: customFAB(context),
      bottomNavigationBar: customBottomAppBar(),
    );
  }

  Container customDrawer() {
    return Container(
      padding: EdgeInsets.only(),
      height: 200,
      width: 250,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              color: Colors.teal,
              child: ListTile(
                onTap: () async {
                  await Navigator.pushNamed(context, '/notification_screen');
                  Navigator.pop(context);
                },
                trailing: Icon(Icons.notifications, color: Colors.white),
                title: Text(
                  'Benachrichtungen',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Card(
              color: Colors.teal,
              child: ListTile(
                onTap: () {
                  _navigateToDeleteScreen(context);
                },
                trailing: Icon(Icons.delete, color: Colors.white),
                title: Text(
                  'Lösche alte Daten',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Card(
              color: Colors.teal,
              child: ListTile(
                onTap: () {
                  _navigateToAboutAppScreen(context);
                },
                trailing: Icon(Icons.info, color: Colors.white),
                title: Text(
                  'Über die App',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSize customAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(64.0),
      child: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
              icon: Icon(
                Icons.menu,
                size: 29,
              ),
              onPressed: () => _scaffoldKey.currentState.openEndDrawer()),
        ),
        elevation: 12,
        title: Text('Cluster-Tagebuch'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code,
              size: 29,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/qrscreen');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 9),
            child: IconButton(
              icon: Icon(
                Icons.search,
                size: 29,
              ),
              onPressed: () {
                (_initpage == 0) ? _searchClusterlist() : _searchUserlist();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _showList() {
    if (_initpage == 0) {
      return _buildClusterList();
    } else if (_initpage == 1) {
      return _buildUserList();
    } else {
      return Container(child: Text('Fehler beim Laden'));
    }
  }

  Widget _buildClusterList() {
    if (clusters.length > 0) {
      return Container(
        child: StickyGroupedListView(
          padding: EdgeInsets.only(bottom: 150),
          floatingHeader: true,
          elements: clusters,
          groupBy: (Clusters element) => DateTime(
              DateTime.fromMillisecondsSinceEpoch(element.datum).year,
              DateTime.fromMillisecondsSinceEpoch(element.datum).month,
              DateTime.fromMillisecondsSinceEpoch(element.datum).day),
          groupSeparatorBuilder: (Clusters element) => Container(
            margin: EdgeInsets.only(bottom: 30, top: 30),
            height: 50,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 190,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: Chip(
                      backgroundColor: Theme.of(context).colorScheme.chipcolor,
                      label: Text(dfnew.format(DateTime(
                          DateTime.fromMillisecondsSinceEpoch(element.datum)
                              .year,
                          DateTime.fromMillisecondsSinceEpoch(element.datum)
                              .month,
                          DateTime.fromMillisecondsSinceEpoch(element.datum)
                              .day))),
                    ),
                  ),
                ),
              ),
            ),
          ),
          itemBuilder: (context, Clusters cluster) => Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return showClusterAlertDialog(cluster.id, cluster.name);
                },
              );
            },
            child: customClusterCardList(cluster),
          ),
          order: StickyGroupedListOrder.DESC,
        ),
      );
    } else if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Keine Cluster vorhanden',
              style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.withOpacity(1)),
            ),
            Text(
              'Zum Hinzufügen auf das Plus-Icon drücken',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.withOpacity(1)),
            ),
          ],
        ),
      );
    }
  }

  Card customClusterCardList(Clusters cluster) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: ListTile(
        onTap: () {
          _navigateToEditClusterScreen(context, cluster);
        },
        contentPadding: EdgeInsets.only(left: 10, right: 10),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.people),
            Flexible(child: Text(cluster.anzahlpersonen.toString()))
          ],
        ),
        title: Row(
          children: [
            Icon(Icons.notes),
            SizedBox(width: 10),
            Flexible(
                child: Text(
              cluster.name,
            )),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_pin),
            SizedBox(width: 10),
            Flexible(child: Text(cluster.ort)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.timelapse),
            Text(dfnewh.format(DateTime(
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).year,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).month,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).day,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).hour,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).minute))),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (contacts.length > 0) {
      return Container(
        child: StickyGroupedListView(
          padding: EdgeInsets.only(bottom: 150),
          floatingHeader: true,
          elements: contacts,
          groupBy: (Contacts user) => user.nachname.toUpperCase().codeUnits[0],
          groupSeparatorBuilder: (Contacts user) => Container(
            margin: EdgeInsets.only(bottom: 30, top: 30, right: 15),
            height: 40,
            child: Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Theme.of(context).colorScheme.circleAvatarBackgroundColor,
                  child: Text(user.nachname[0].toUpperCase()),
                )),
          ),
          itemBuilder: (context, Contacts contact) => Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  String contactname =
                      contact.nachname + ', ' + contact.vorname;
                  return showContactAlertDialog(contact.id, contactname);
                },
              );
            },
            child: customUserListView(context, contact),
          ),
          order: StickyGroupedListOrder.ASC,
        ),
      );
    } else if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Keine Kontakte vorhanden',
              style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.withOpacity(1)),
            ),
            Text(
              'Zum Hinzufügen auf das Plus-Icon drücken',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.withOpacity(1)),
            ),
          ],
        ),
      );
    }
  }

  Card customUserListView(BuildContext context, Contacts contact) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(left: 10, right: 10, top: 20),
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

  FloatingActionButton customFAB(context) {
    return FloatingActionButton(
      elevation: 9,
      child: Icon(Icons.add),
      onPressed: () {
        _customBottomSheet(context);
      },
    );
  }

  BottomAppBar customBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 15,
      color: Colors.teal,
      child: Container(
        height: 70,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 40, top: 4),
                child: FlatButton(
                  color: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    setState(() {
                      _initpage = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.note,
                        color:
                            (_initpage == 0) ? Colors.white : Colors.grey[400],
                      ),
                      Text(
                        'Clusters',
                        style: TextStyle(
                            color: (_initpage == 0)
                                ? Colors.white
                                : Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 40, top: 4),
                child: FlatButton(
                  color: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    setState(() {
                      _initpage = 1;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.people,
                        color:
                            (_initpage == 1) ? Colors.white : Colors.grey[400],
                      ),
                      Text(
                        'Kontakte',
                        style: TextStyle(
                            color: (_initpage == 1)
                                ? Colors.white
                                : Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        Contacts qruser = await db.getContact(checkqrexisting);
        await _navigateToEditContactScreen(context, qruser);
        Navigator.pop(context);
      } else {
        int newcontactid = await db.addcontact(Contacts(
            vorname: qruserfromqr.vorname,
            nachname: qruserfromqr.nachname,
            strasse: qruserfromqr.strasse,
            ort: qruserfromqr.ort,
            plz: qruserfromqr.plz,
            telefonnummer: qruserfromqr.telefonnummer,
            adddatum: DateTime.now().millisecondsSinceEpoch));
        Contacts qruser = await db.getContact(newcontactid);
        await _navigateToEditContactScreen(context, qruser);
        Navigator.pop(context);
      }
    }
  }

  showClusterAlertDialog(int clusterid, String clustername) {
    return AlertDialog(
      title: Text('Löschvorgang'),
      content: Text('Wollen Sie das Cluster "$clustername" wirklich löschen?'),
      actions: <Widget>[
        FlatButton(
            child: Text('Abbrechen'),
            onPressed: () {
              setupClusterList();
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('Löschen'),
          onPressed: () {
            onDeleteCluster(clusterid);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  showContactAlertDialog(int contactid, String contactname) {
    return AlertDialog(
      title: Text('Löschvorgang'),
      content: Text('Wollen Sie den Kontakt "$contactname" wirklich löschen?'),
      actions: <Widget>[
        FlatButton(
            child: Text('Abbrechen'),
            onPressed: () {
              setupContactsList();
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('Löschen'),
          onPressed: () {
            onDeleteContact(contactid);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  _searchUserlist() {
    showSearch(
      context: context,
      delegate: SearchPage<Contacts>(
        items: contacts,
        searchLabel: 'Suche nach Kontakten',
        suggestion: _buildUserList(),
        failure: Center(
          child: Text('Keine Kontakte gefunden'),
        ),
        filter: (user) => [user.vorname, user.nachname, user.telefonnummer],
        builder: (user) => customUserListView(context, user),
      ),
    );
  }

  _searchClusterlist() {
    showSearch(
      context: context,
      delegate: SearchPage<Clusters>(
        items: clusters,
        searchLabel: 'Suche nach Clustern',
        suggestion: _buildClusterList(),
        failure: Center(
          child: Text('Keine Cluster gefunden'),
        ),
        filter: (cluster) => [cluster.name, cluster.ort],
        builder: (cluster) => Card(
          elevation: 5,
          margin: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(dfnew.format(DateTime(
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum).year,
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum).month,
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum).day,
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum).hour,
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                        .minute))),
              ),
              ListTile(
                onTap: () {
                  _navigateToEditClusterScreen(context, cluster);
                },
                contentPadding: EdgeInsets.only(left: 10, right: 10),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.people),
                    Flexible(child: Text(cluster.anzahlpersonen.toString()))
                  ],
                ),
                title: Row(
                  children: [
                    Icon(Icons.notes),
                    SizedBox(width: 10),
                    Flexible(
                        child: Text(
                      cluster.name,
                    )),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.location_pin),
                    SizedBox(width: 10),
                    Flexible(child: Text(cluster.ort)),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.timelapse),
                    Text(dfnewh.format(DateTime(
                        DateTime.fromMillisecondsSinceEpoch(cluster.datum).year,
                        DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                            .month,
                        DateTime.fromMillisecondsSinceEpoch(cluster.datum).day,
                        DateTime.fromMillisecondsSinceEpoch(cluster.datum).hour,
                        DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                            .minute))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _customBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            height: 305,
            child: Column(
              children: <Widget>[
                Card(
                  color:
                      Theme.of(context).colorScheme.circleAvatarBackgroundColor,
                  child: ListTile(
                      title: Text(
                        'Füge ein neues Cluster hinzu',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      trailing: Icon(
                        Icons.note_add,
                        color: Colors.white,
                      ),
                      onTap: () {
                        _navigateToAddClusterScreen(context);
                      }),
                ),
                Card(
                  color:
                      Theme.of(context).colorScheme.circleAvatarBackgroundColor,
                  child: ListTile(
                      title: Text(
                        'Füge einen Kontakt hinzu',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      trailing: Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                      onTap: () {
                        _navigateToAddContactScreen(context);
                      }),
                ),
                Card(
                  color:
                      Theme.of(context).colorScheme.circleAvatarBackgroundColor,
                  child: ListTile(
                      title: Text(
                        'Scanne QR-Kontaktinformationen',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      trailing: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                      onTap: () {
                        qrscan();
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _navigateToAddClusterScreen(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/add_clusterscreen');
    setState(() {
      _initpage = 0;
    });
    if (result != null) {
      setupClusterList();
      setupContactsList();
      Navigator.pop(context);
    } else {
      setupClusterList();
      setupContactsList();
      Navigator.pop(context);
    }
  }

  _navigateToAddContactScreen(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/add_contactscreen');
    setState(() {
      _initpage = 1;
    });
    if (result != null) {
      setupContactsList();
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  _navigateToDeleteScreen(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/delete_screen');
    if (result != null) {
      setupContactsList();
      setupClusterList();
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  _navigateToAboutAppScreen(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/aboutapp_screen');
    if (result != null) {
      setupContactsList();
      setupClusterList();
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  _navigateToEditClusterScreen(BuildContext context, Clusters cluster) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditClusterScreen(cluster: cluster)),
    );
    if (result != null) {
      setupContactsList();
      setupClusterList();
    }
  }

  _navigateToEditContactScreen(BuildContext context, Contacts contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditContactScreen(contact: contact)),
    );
    setState(() {
      _initpage = 1;
    });
    if (result != null) {
      setupContactsList();
      setupClusterList();
    } else {
      setupContactsList();
      setupClusterList();
    }
  }

  onDeleteCluster(int id) async {
    await db.deleteCluster(id);
    db.getAllClusters().then((clusterdb) => clusters = clusterdb);
    setupClusterList();
  }

  onDeleteContact(int id) async {
    await db.deletecontact(id);
    db.getAllContacts().then((contactdb) => contacts = contactdb);
    setupContactsList();
  }

  void setupContactsList() async {
    var _contacts = await db.getAllContacts();
    setState(() {
      _loading = false;
      contacts = _contacts;
    });
  }

  void setupClusterList() async {
    var _clusters = await db.getAllClusters();
    setState(() {
      _loading = false;
      clusters = _clusters;
    });
  }
}
