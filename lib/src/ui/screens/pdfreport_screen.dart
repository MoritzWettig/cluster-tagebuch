import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PDFReportScreen extends StatelessWidget {
  final pdf;
  const PDFReportScreen({this.pdf});
  @override
  Widget build(BuildContext context) {
    final df = new DateFormat('yyyyMMddHHmm');
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
        title: Text('PDF Report'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.print,
              size: 29,
            ),
            onPressed: () async {
              await Printing.layoutPdf(onLayout: (format) async => pdf);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 9),
            child: IconButton(
              icon: Icon(
                Icons.share,
                size: 29,
              ),
              onPressed: () async {
                var _pdf = await pdf;
                String docname =
                    'Cluster-Tagebuch-Report_' + df.format(DateTime.now());
                await Printing.sharePdf(bytes: _pdf, filename: docname);
              },
            ),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 0),
        child: PdfPreview(
          useActions: false,
          build: (format) => pdf,
        ),
      ),
    );
  }
}
