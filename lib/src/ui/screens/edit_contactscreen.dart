import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:search_page/search_page.dart';

import '../../datamodels/cluster_model.dart';
import '../../datamodels/clusterhistory_model.dart';
import '../../datamodels/contact_model.dart';
import '../../services/sqflite_service.dart';
import 'edit_clusterscreen.dart';

class EditContactScreen extends StatefulWidget {
  final Contacts contact;
  @override
  _EditContactScreenState createState() => _EditContactScreenState();
  EditContactScreen({this.contact});
}

class _EditContactScreenState extends State<EditContactScreen> {
  List<Clusters> clusters = [];
  final db = ClusterHistoryDB();
  final vornameController = TextEditingController();
  final nachnameController = TextEditingController();
  final strasseController = TextEditingController();
  final ortController = TextEditingController();
  final plzController = TextEditingController();
  final telefonnummerController = TextEditingController();
  final df = new DateFormat('dd.MM.yyyy HH:mm');
  final dfnew = new DateFormat('EEEE, dd.MM.yyyy', 'DE');
  final dfnewh = new DateFormat('HH:mm');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    vornameController.text = widget.contact.vorname;
    nachnameController.text = widget.contact.nachname;
    strasseController.text = widget.contact.strasse;
    ortController.text = widget.contact.ort;
    plzController.text = widget.contact.plz.toString();
    telefonnummerController.text = widget.contact.telefonnummer.toString();
    setupClusterList();
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
              Navigator.pop(context, true);
            },
          ),
        ),
        title: Text('Kontakt bearbeiten'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            children: [contactInputField(context), _buildClusterList()],
          ),
        ),
      ),
      floatingActionButton: _customFAB(),
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
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Bitte Daten eingeben';
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
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Bitte Daten eingeben';
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
                        await db.updatecontact(Contacts(
                            id: widget.contact.id,
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

  Widget _buildClusterList() {
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
                'Verknüpfte Cluster',
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
            itemCount: clusters.length,
            itemBuilder: (context, index) {
              return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) async {
                    await db.deleteClusterHistoryRelation(
                        clusters[index].id, widget.contact.id);
                    setupClusterList();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.teal,
                        content: Text('Verknüpfung entfernt',
                            style: TextStyle(color: Colors.white)),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: customClusterCardList(clusters[index]));
            }),
      ],
    );
  }

  Card customClusterCardList(Clusters cluster) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(left: 16, right: 16, top: 20),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Text(dfnew.format(DateTime(
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).year,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).month,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).day,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).hour,
                DateTime.fromMillisecondsSinceEpoch(cluster.datum).minute))),
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
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum).month,
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum).day,
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum).hour,
                    DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                        .minute))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customFAB() {
    return FloatingActionButton(
      child: Icon(Icons.note_add),
      tooltip: 'Verknüpfe ein Cluster',
      onPressed: () async {
        var _allcluster = await db.getAllClusters();
        showSearch(
          context: context,
          delegate: SearchPage(
            items: _allcluster,
            searchLabel: 'Suche nach Clustern',
            failure: Center(
              child: Text('Keine Cluster gefunden'),
            ),
            filter: (cluster) => [
              cluster.name,
              cluster.ort,
            ],
            suggestion: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: _allcluster.length,
              itemBuilder: (context, index) {
                Clusters cluster = _allcluster[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.only(left: 16, right: 16, top: 20),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(dfnew.format(DateTime(
                            DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                .year,
                            DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                .month,
                            DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                .day,
                            DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                .hour,
                            DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                .minute))),
                      ),
                      ListTile(
                        onTap: () async {
                          bool result = await db.addClusterHistory(
                            ClusterHistory(
                                clusterID: cluster.id,
                                contactID: widget.contact.id),
                          );
                          if (result) {
                            Navigator.pop(context);
                            setupClusterList();
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
                                clusterID: cluster.id,
                                contactID: widget.contact.id),
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
                            setupClusterList();
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
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.people),
                            Flexible(
                                child: Text(cluster.anzahlpersonen.toString()))
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
                                DateTime.fromMillisecondsSinceEpoch(
                                        cluster.datum)
                                    .year,
                                DateTime.fromMillisecondsSinceEpoch(
                                        cluster.datum)
                                    .month,
                                DateTime.fromMillisecondsSinceEpoch(
                                        cluster.datum)
                                    .day,
                                DateTime.fromMillisecondsSinceEpoch(
                                        cluster.datum)
                                    .hour,
                                DateTime.fromMillisecondsSinceEpoch(
                                        cluster.datum)
                                    .minute))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            builder: (cluster) => Builder(
              builder: (context) => Card(
                elevation: 5,
                margin: EdgeInsets.only(left: 16, right: 16, top: 20),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(dfnew.format(DateTime(
                          DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                              .year,
                          DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                              .month,
                          DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                              .day,
                          DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                              .hour,
                          DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                              .minute))),
                    ),
                    ListTile(
                      onTap: () async {
                        bool result = await db.addClusterHistory(
                          ClusterHistory(
                              clusterID: cluster.id,
                              contactID: widget.contact.id),
                        );
                        if (result) {
                          Navigator.pop(context);
                          setupClusterList();
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
                              clusterID: cluster.id,
                              contactID: widget.contact.id),
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
                          setupClusterList();
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
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.people),
                          Flexible(
                              child: Text(cluster.anzahlpersonen.toString()))
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
                              DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                  .year,
                              DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                  .month,
                              DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                  .day,
                              DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                  .hour,
                              DateTime.fromMillisecondsSinceEpoch(cluster.datum)
                                  .minute))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  _navigateToEditClusterScreen(BuildContext context, Clusters cluster) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditClusterScreen(cluster: cluster)),
    );
    if (result != null) {
      setupClusterList();
    }
  }

  void setupClusterList() async {
    var _clusters = await db.getAllClustersFromcontactID(widget.contact.id);
    setState(() {
      clusters = _clusters;
    });
  }
}
