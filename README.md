# Cluster-Tagebuch
<img src="/assets/icon/Cluster_Tagebuch_Icon.png" width="150" height="150"/>

## Jetzt Verfügbar
Dokumentiere deine Cluster mit der Cluster-Tagebuch App für Android und iOS, geschrieben in Dart und Flutter SDK.

### Apple App Store
<a href='https://apps.apple.com/de/app/cluster-tagebuch/id1536726307'><img alt='Jetzt bei Google Play' src='/docs/badge/appstore_badge.svg' width="355" height="100"/></a>

### Google Play Store
<a href='https://play.google.com/store/apps/details?id=com.moritzwettig.cluster_tagebuch&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Jetzt bei Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/de_badge_web_generic.png' width="350" height="150"/></a>

## Screenshots
<img src="/docs/screenshots/screenshot_clusterlist_light.png" width="250" height="500"/> <img src="/docs/screenshots/screenshot_clusterlist_dark.png" width="250" height="500"/> <img src="/docs/screenshots/screen_contactlist.png" width="250" height="500"/> <img src="/docs/screenshots/screenshot_qrcode.png" width="250" height="500"/> <img src="/docs/screenshots/screenshot_editcluster.png" width="250" height="500"/> <img src="/docs/screenshots/screenshot_editcontact.png" width="250" height="500"/> <img src="/docs/screenshots/screenshot_notification.png" width="250" height="500"/>

## Dokumentation

### Datenbank

Die hinzugefügten Daten werden in einer lokalen SQLite Datenbank auf dem Smartphone gespeichert. Folgende Flutter Packages werden dazu verwendet:

- [sqflite](https://pub.dev/packages/sqflite)
- [path](https://pub.dev/packages/path)
- [path_provider](https://pub.dev/packages/path_provider)

Das Schema und die CRUD-Operationen sind im File [sqflite_service.dart](/lib/src/services/sqflite_service.dart) definiert.

#### Datenbanktabellen / Schema

Die Datenbank enthält folgende vier Tabellen:

- clusters

  In dieser Tabelle werden alle Cluster, die der Nutzer anlegt, abgespeichert.

  | id | name | ort| anzahlpersonen | datum| 
  | :-: |:-:|:-:|:-:|:-:|
  | 1 | Mein erstes Cluster | Eschweiler | 8 | 012345678909 |

  - id    => PRIMARY KEY und AUTOINCREMENT; 
  - datum => Millisekunden seit Unix Epoch


- Contacts

  In dieser Tabelle werden alle Kontakte, die der Nutzer anlegt, abgespeichert.

  | id | vorname | nachname | strasse | ort | plz | telefonnummer | adddatum |
  |:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
  | 1 | Peter | Schmidt | Haupstraße 10 | Eschweiler | 52249 | 01234567890 | 10987654321 |

  - id        => PRIMARY KEY und AUTOINCREMENT
  - adddatum  => Millisekunden seit Unix Epoch

- qrontact

  In dieser Tabelle werden die Kontaktdaten abgespeichert, die für die Erstellung des QR-Codes genutzt werden.

  | id | vorname | nachname | strasse | ort | plz | telefonnummer | adddatum |
  |:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
  | 1 | Peter | Schmidt | Haupstraße 10 | Eschweiler | 52249 | 01234567890 | 10987654321 |

  - id        => Always 1
  - adddatum  => Millisekunden seit Unix Epoch

- clusterhistory

  Diese Tabelle dient als Junction-Table, um eine Relation zwischen Cluster und Kontakten zu ermöglichen.

  | id | clusterID | contactID |
  |:-:|:-:|:-:|
  | 1 | 2 | 3 |

  - id          => PRIMARY KEY und AUTOINCREMENT
  - clusterID   => FOREIGN KEY REFERENCES clusters(id)
  - contactID   => FOREIGN KEY REFERENCES Contacts(id)

##### INNER JOINS

 - Um alle Kontakte zu erhalten, die einem Cluster zugeordnet sind, wird folgende Query ausgeführt:
 ```
SELECT Contacts.* FROM Contacts INNER JOIN clusterhistory ON Contacts.id = clusterhistory.contactID WHERE 
clusterhistory.clusterID = ? ORDER BY Contacts.nachname, [clusterID]);
  ```

 - Um alle Cluster zu erhalten, die einem Kontakt zugeordnet sind, wird folgende Query ausgeführt:
 ```
SELECT clusters.* FROM clusters INNER JOIN clusterhistory ON clusters.id = clusterhistory.clusterID WHERE
clusterhistory.contactID = ? ORDER BY clusters.datum DESC, [contactID]);
  ```

 - Um alle Kontakte zu erhalten, die einem Cluster zugeordnet und nicht älter als 14 Tage sind, wird folgende Query ausgeführt:
 ```
 SELECT DISTINCT Contacts.* FROM Contacts INNER JOIN clusterhistory ON Contacts.id = clusterhistory.contactID INNER JOIN clusters ON clusterhistory.clusterID = clusters.id  WHERE clusters.datum >= ? ORDER BY Contacts.nachname,
[DateTime.now().add(Duration(days: -days)).millisecondsSinceEpoch],);
  ```

## Lokale Benachrichtigungen

Zur täglichen Benachrichtigung werden folgende Flutter Packages verwendet:
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

## QR-Code

Zum Scannen und Erstellen von QR-Codes werden folgende zwei Flutter Packages verwendet:
- [barcode_scanner](https://pub.dev/packages/barcode_scanner)
- [qr_flutter](https://pub.dev/packages/qr_flutter)

## URL Launcher

Zum Öffnen von Links wird folgendes Flutter Package verwendet:
- [url_launcher](https://pub.dev/packages/url_launcher)

## Liste und Suche

Zum Erstellen von Listen und zum Suchen werden folgende zwei Flutter Packages verwendet:
- [sticky_grouped_list](https://pub.dev/packages/sticky_grouped_list)
- [search_page](https://pub.dev/packages/search_page)

## Adressbuch Import

Zum Importieren von Kontakten aus dem Adressbuch werden folgende zwei Flutter Packages verwendet:
- [contacts_service](https://pub.dev/packages/contacts_service)
- [permission_handler](https://pub.dev/packages/permission_handler)

## PDF-Report

Zum Erstellen des PDF-Reports wird folgendes Flutter Package verwendet:
- [printing](https://pub.dev/packages/printing)
