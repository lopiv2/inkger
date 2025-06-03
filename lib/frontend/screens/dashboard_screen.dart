import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/widgets/document_format_counter.dart';
import 'package:inkger/frontend/widgets/library_counter.dart';
import 'package:inkger/frontend/widgets/recommendations_carousel.dart';
import 'package:inkger/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Imagen de fondo
            Positioned.fill(
              child: Image.asset(
                'assets/images/back_home.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila de Cards
                  Wrap(
                    spacing: 20, // Espacio horizontal entre elementos
                    runSpacing: 20, // Espacio vertical entre filas
                    children: [
                      // Card de libros
                      CounterWidget(
                        title: AppLocalizations.of(context)!.books,
                        fetchCount: CommonServices.fetchBookCount,
                        color: Colors.blue,
                        icon: Icons.menu_book,
                      ),
                      // Card de comics
                      CounterWidget(
                        title: 'Comic',
                        fetchCount: CommonServices.fetchComicCount,
                        color: Colors.green,
                        icon: Icons.question_answer,
                      ),
                      // Card de series
                      CounterWidget(
                        title: 'Series',
                        fetchCount: CommonServices.fetchSeriesCount,
                        color: Colors.orange,
                        icon: Icons.collections_bookmark,
                      ),
                      CounterWidget(
                        title: AppLocalizations.of(context)!.readingLists,
                        fetchCount: CommonServices.fetchReadingListCount,
                        color: Colors.red,
                        icon: Icons.list,
                      ),
                      CounterWidget(
                        title: AppLocalizations.of(context)!.readBooks,
                        fetchCount: CommonServices.fetchReadBooksCount,
                        color: Colors.brown,
                        icon: Icons.task,
                      ),
                      DocumentFormatCounterWidget(),
                    ],
                  ),
                  SizedBox(height: 86),
                  RecommendedBooksCarousel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
