import 'package:flutter/material.dart';

import '../../services/sqflite_service.dart';

class DeleteScreen extends StatefulWidget {
  @override
  _DeleteScreenState createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
  double _currentSliderClusterValue = 14;
  double _currentSliderContactValue = 14;
  final db = ClusterHistoryDB();
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
        title: Text('Löschung'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20, top: 30, right: 20),
          child: Column(
            children: [
              Card(
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        'Lösche Cluster die älter sind als',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: _currentSliderClusterValue,
                        min: 1,
                        max: 90,
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderClusterValue = value;
                          });
                        },
                      ),
                      Text(
                        _currentSliderClusterValue.round().toString() + ' Tage',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                        child: FlatButton(
                          color: Colors.teal,
                          onPressed: () async {
                            await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return showClusterAlertDialog(
                                    _currentSliderClusterValue
                                        .round()
                                        .toString());
                              },
                            );
                            Navigator.pop(context, true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              Text(
                                'Löschen',
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
              SizedBox(height: 20),
              Card(
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        'Lösche Kontakte die älter sind als',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: _currentSliderContactValue,
                        min: 1,
                        max: 90,
                        onChanged: (double value) {
                          setState(() {
                            _currentSliderContactValue = value;
                          });
                        },
                      ),
                      Text(
                        _currentSliderContactValue.round().toString() + ' Tage',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                        child: FlatButton(
                          color: Colors.teal,
                          onPressed: () async {
                            await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return showContactAlertDialog(
                                    _currentSliderContactValue
                                        .round()
                                        .toString());
                              },
                            );
                            Navigator.pop(context, true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              Text(
                                'Löschen',
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
            ],
          ),
        ),
      ),
    );
  }

  showClusterAlertDialog(String day) {
    return AlertDialog(
      title: Text('Löschvorgang'),
      content: Text(
          'Wollen Sie alle Cluster, die älter als $day Tage sind, löschen?'),
      actions: <Widget>[
        FlatButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('Löschen'),
          onPressed: () async {
            int day = DateTime.now()
                .add(Duration(days: -_currentSliderClusterValue.round()))
                .millisecondsSinceEpoch;
            await db.deleteClusterAfterDays(day);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  showContactAlertDialog(String day) {
    return AlertDialog(
      title: Text('Löschvorgang'),
      content: Text(
          'Wollen Sie alle Kontakte, die älter als $day Tage sind, löschen?'),
      actions: <Widget>[
        FlatButton(
            child: Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
          child: Text('Löschen'),
          onPressed: () async {
            int day = DateTime.now()
                .add(Duration(days: -_currentSliderContactValue.round()))
                .millisecondsSinceEpoch;
            await db.deleteContactsAfterDays(day);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
