import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/l10n/app_localizations.dart';

class DocumentFormatCounterWidget extends StatefulWidget {
  @override
  _DocumentFormatCounterWidgetState createState() =>
      _DocumentFormatCounterWidgetState();
}

class _DocumentFormatCounterWidgetState
    extends State<DocumentFormatCounterWidget> {
  Future<Map<String, int>>? _documentFormatCount;

  @override
  void initState() {
    super.initState();
    _documentFormatCount = CommonServices.fetchDocumentFormatsCount();
  }

  // Función para obtener los datos desde el endpoint

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.file_copy_sharp, size: 40, color: Colors.blue),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.documentFormats,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  // FutureBuilder para obtener los datos y mostrar los contadores
                  FutureBuilder<Map<String, int>>(
                    future: _documentFormatCount,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: data.entries
                              .map(
                                (entry) => Text(
                                  '${entry.key}: ${entry.value}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      } else {
                        return Text('No data available');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
