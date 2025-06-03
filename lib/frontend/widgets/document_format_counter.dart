import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: isSmallScreen ? screenWidth * 0.8 : screenWidth * 0.2,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.file_copy_sharp,
              size: isSmallScreen ? 30 : 40,
              color: Colors.blue,
            ),
            SizedBox(height: isSmallScreen ? 10 : 20),
            Text(
              AppLocalizations.of(context)!.documentFormats,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: isSmallScreen ? 10 : 20),
            FutureBuilder<Map<String, int>>(
              future: _documentFormatCount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomLoader(size: isSmallScreen ? 40.0 : 60.0, color: Colors.blue);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: data.entries
                        .map(
                          (entry) => Text(
                            '${entry.key}: ${entry.value}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 18,
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
      ),
    );
  }
}
