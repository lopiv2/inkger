import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:inkger/frontend/models/recommendations.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendedBooksCarousel extends StatefulWidget {
  const RecommendedBooksCarousel({Key? key}) : super(key: key);

  @override
  _RecommendedBooksCarouselState createState() =>
      _RecommendedBooksCarouselState();
}

class _RecommendedBooksCarouselState extends State<RecommendedBooksCarousel> {
  List<AuthorRecommendation> _books = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final tree = await CommonServices.fetchBookRecommendations();
      final List<AuthorRecommendation> authors = tree
          .map((json) => AuthorRecommendation.fromJson(json))
          .toList();

      setState(() {
        _books = authors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      //return const Center(child: CustomLoader(size: 60.0, color: Colors.blue)());
      return const Center(
        child: CustomLoader(size: 60.0, color: Colors.blue)
      );
    }

    // Mostrar todos los libros de todos los autores en un solo carrusel
    final allBooks = _books.expand((author) => author.books).toList();

    if (_hasError || _books.isEmpty) {
      return const Center(
        child: Text('No se pudieron cargar recomendaciones.'),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          // <-- Cambiado a columna para poner el título arriba
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Center(
                child: Text(
                  'Recomendaciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
              child: CarouselSlider.builder(
                itemCount: allBooks.length,
                itemBuilder: (context, index, realIndex) {
                  final book = allBooks[index];
                  return Column(
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: book.description,
                          child: InkWell(
                            onTap: () async {
                              final url = book.link;
                              if (url == null) {
                                CustomSnackBar.show(
                                  context,
                                  AppLocalizations.of(context)!.cantOpenLink,
                                  Colors.red,
                                  duration: Duration(seconds: 4),
                                );
                                return;
                              }
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                CustomSnackBar.show(
                                  context,
                                  AppLocalizations.of(context)!.cantOpenLink,
                                  Colors.red,
                                  duration: Duration(seconds: 4),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: book.cover != null
                                  ? Image.network(
                                      book.cover!,
                                      height: 180,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 180,
                                      width: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.book, size: 50),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.author,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black),
                      ),
                      book.rating!.isNotEmpty ?
                      Icon(Icons.star, color: Colors.amber,) : Center()
                    ],
                  );
                },
                options: CarouselOptions(
                  viewportFraction: 0.28,
                  height: MediaQuery.of(context).size.height * 0.28,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 2.0,
                  enableInfiniteScroll: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
