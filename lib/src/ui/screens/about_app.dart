import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
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
        title: Text('App Info'),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
        child: ListView(
          children: [
            Card(
              child: ExpansionTile(
                expandedAlignment: Alignment.topLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: EdgeInsets.only(left: 25, bottom: 20, top: 20),
                leading: Icon(Icons.mail),
                title: Text('Kontakt zum Entwickler'),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          'Entwickler: ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Text('Privatperson'),
                      Text('Moritz Wettig'),
                      Text('info@cluster-tagebuch.de'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 20),
                        child: Text(
                          'Icon Design: ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Text('Privatperson'),
                      Text(
                        'Julia Schain',
                      ),
                      InkWell(
                        onTap: () {
                          _launchURL('http://juliaschain.com');
                        },
                        child: Text('JuliaSchain.com'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Card(
              child: ExpansionTile(
                expandedAlignment: Alignment.topLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding:
                    EdgeInsets.only(left: 25, bottom: 20, top: 20, right: 25),
                leading: Icon(Icons.privacy_tip),
                title: Text('Datenschutz'),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Datenverarbeitung',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App "Cluster Tagebuch" speichert und verarbeitet die vom Nutzer hinzugefügten Daten ausschließlich lokal auf dem Smartphone des jeweiligen Nutzers. Alle personen- und ortsbezogenen Daten werden lokal in einer Datenbank auf dem Smartphone gespeichert. Zu keiner Zeit werden Daten an den Entwickler oder Dritte weitergegeben. Der Quellcode der App kann über den Button "Quellcode" auf dieser Seite aufgerufen werden.'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, top: 30),
                    child: Text(
                      'Personenbezogene Daten',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App "Cluster Tagebuch" bietet den Nutzern die Möglichkeit personenbezogene Daten von Kontakten zu speichern, sowie die eigenen personenbezogenen Daten über einen QR-Code mit anderen zu teilen. Zusätzlich können die Nutzer Kontaktinformationen aus dem Adressbuch des Smartphones importieren. Alle personen- und ortsbezogenen Daten werden in einer lokalen Datenbank auf dem Smartphone des Nutzers gespeichert. Der Nutzer bestimmt selbst, wem er seine eigenen Kontaktdaten weitergibt. In der Datenbank werden folgende Informationen abspeichert: Cluster ID, Cluster Name, Cluster Ort, Cluster Anzahl der Personen, Cluster Datum, Kontakt ID, Kontakt Vorname, Kontakt Nachname, Kontakt Adresse, Kontakt Telefonnummer und Kontakt Datum (Datum als der Kontakt hinzugefügt wurde). Den Aufbau der Datenbank finden Sie im Quellcode wieder.'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, top: 30),
                    child: Text(
                      'Ortsbezogene Daten',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App "Cluster Tagebuch" bietet den Nutzern die Möglichkeit ortsbezogene Daten einem Cluster-Eintrag hinzuzufügen. Das Eintragen der ortsbezogenen Daten wird vom Nutzer manuell durchgeführt und wird in einer lokalen Datenbank auf dem Smartphone gespeichert. Zu keiner Zeit werden Positionsdienste wie z.B. GPS verwendet.'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, top: 30),
                    child: Text(
                      'App Berechtigungen',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App "Cluster Tagebuch" benötigt zur Verwendung der QR-Code-Scan Funktion die Kamera-Berechtigung, um Kontaktdaten von Personen zu scannen und in der lokalen Datenbank zu speichern. Für die Funktion der täglichen Benachrichtigungen benötigt die App für IOS die Berechtigung Benachrichtigungen zu erstellen und zu erhalten. Alle Benachrichtigungen werden lokal erstellt und zu keiner Zeit wird ein Push-Benachrichtigungsdienst von Dritten verwendet. Zum Importieren von Kontaktinformationen aus dem Adressbuch des Smartphones benötigt die App die Berechtigung auf das Adressbuch des Smartphones zugreifen zu dürfen.'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, top: 30),
                    child: Text(
                      'QR-Code und Weitergabe',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App "Cluster Tagebuch" bietet dem Nutzer die Möglichkeit einen QR-Code lokal zu generieren, welcher die von ihm eingegebenen personenbezogen Daten repräsentiert. Die Weitergabe der personenbezogenen Daten in Form des QR-Codes liegt einzig und allein in der Verantwortung des Nutzers. Der Entwickler tritt hierbei von jeglicher Verantwortung bei der Weitergabe der personenbezogenen Daten über den QR-Code zurück. Der Nutzer selbst entscheidet, wer seine personenbezogenen Daten einscannen darf. Bei der Erstellung des QR-Codes werden die Nutzerkontaktdaten in Base64 kodiert. Die Kodierung mit Base64 stellt keine Verschlüsselung dar. Wenn nun eine andere Partei den QR-Code mit der App „Cluster Tagebuch“ einscannt, werden die Kontaktdaten dekodiert und in der lokalen Datenbank auf dem Smartphone der anderen Partei gespeichert.'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, top: 30),
                    child: Text(
                      'PDF-Report Export',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App „Cluster Tagebuch“ bietet den Nutzern die Möglichkeit einen PDF-Report zu erstellen, der die Kontakte der letzten X Tage (maximal 14 Tage) auflistet. Dieser PDF-Report enthält personenbezogene Daten und soll den Gesundheitsbehörden bei der Kontaktnachverfolgung helfen. Diesen PDF-Report sollte der Nutzer nur nach Aufforderung durch die Gesundheitsbehörden erstellen. Die Verantwortung der sicheren und datenschutzkonformen Übertragung trägt hierbei der Nutzer der App. Der Entwickler tritt von jeglicher Verantwortung bei der Weitergabe der personenbezogenen Daten zurück. Die Weitergabe der personenbezogenen Daten an Dritte darf nur mit dem ausdrücklichen Einverständnis der jeweiligen im PDF-Report enthaltenen Personen geschehen. Der Nutzer muss vor der Erstellung des Dokuments diesem Hinweis zustimmen.'),
                ],
              ),
            ),
            Card(
              child: ExpansionTile(
                expandedAlignment: Alignment.topLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding:
                    EdgeInsets.only(left: 25, bottom: 20, top: 20, right: 20),
                leading: Icon(Icons.link),
                title: Text('Haftung für Links'),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Haftung für Links',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App "Cluster Tagebuch" enthält Links zu externen Webseiten, auf deren Inhalte der Entwickler keinen Einfluss hat. Für die fremden Inhalte auf den externen Webseiten kann der Entwickler keine Verantwortung übernehmen. Lediglich die Betreiber der externen Webseiten sind für die dort vorhanden Inhalte verantwortlich. Die verlinkten Webseiten wurden bei der Verlinkung auf rechtswidrige Inhalte überprüft. Es waren keine Rechtsverstöße erkennbar. Die permanente Kontrolle, für die in der App angegeben Verlinkungen, ist jedoch für den Entwickler nicht zumutbar. Bei Meldung an den Entwickler werden rechtsverletzende Verlinkungen entfernt.'),
                ],
              ),
            ),
            Card(
              child: ExpansionTile(
                expandedAlignment: Alignment.topLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding:
                    EdgeInsets.only(left: 25, bottom: 20, top: 20, right: 25),
                leading: Icon(Icons.code),
                title: Text('Quellcode und Lizenen'),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Quellcode',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App "Cluster Tagebuch" ist Open Source und wurde mit dem Open Source Framework Flutter\u2122 SDK geschrieben. Der Quellcode kann über die URL cluster-tagebuch.de aufgerufen werden. Hier findet eine Weiterleitung zum GitHub Repository statt. Drücken Sie den Button „Quellcode“, um direkt dorthin zu gelangen:'),
                  Container(
                    color: Colors.teal,
                    margin: EdgeInsets.only(
                        top: 20, right: 50, left: 50, bottom: 20),
                    child: FlatButton(
                      onPressed: () {
                        _launchURL('http://cluster-tagebuch.de');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link,
                            color: Colors.white,
                          ),
                          Text(
                            'Quellcode',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Lizenzen',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                      'Die App wurde unter der BSD-3-Clause License auf GitHub veröffentlicht. Die App wurde mit dem Open Source Flutter SDK und Packages von Dritten entwickelt. Die Lizenzen aller verwendeten Packages finden Sie auf folgendem Button:'),
                  Container(
                    color: Colors.teal,
                    margin: EdgeInsets.only(
                        top: 20, right: 50, left: 50, bottom: 20),
                    child: FlatButton(
                      onPressed: () {
                        showLicensePage(
                            context: context,
                            applicationName: 'Cluster Tagebuch',
                            applicationVersion: '1.1.0');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.source,
                            color: Colors.white,
                          ),
                          Text(
                            'Lizenen',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
