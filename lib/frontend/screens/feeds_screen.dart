import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/feed_item.dart';
import 'package:inkger/frontend/utils/feeds_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedsScreen extends StatefulWidget {
  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  int selectedIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final feedsProvider = Provider.of<FeedsProvider>(context);
    final allSources = feedsProvider.groupedFeedsBySource;
    // Filtramos solo los activos
    final sources = allSources
        .where((source) => source['active'] == true)
        .toList();

    if (sources.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.feeds)),
        body: Center(child: Text('No hay feeds disponibles.')),
      );
    }

    final selectedFeeds = sources[selectedIndex]['feeds'] as List;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.feeds)),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: sources.length,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.28,
                viewportFraction: 0.18,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() => selectedIndex = index);
                },
                initialPage: selectedIndex,
              ),
              itemBuilder: (context, i, realIdx) {
                final source = sources[i];
                return GestureDetector(
                  onTap: () {
                    _carouselController.animateToPage(i);
                    setState(() => selectedIndex = i);
                  },
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Material(
                            elevation: selectedIndex == i ? 6 : 1,
                            borderRadius: BorderRadius.circular(50),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                source['logo'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (source['new'] > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red,
                                child: Text(
                                  '${source['new']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          source['name'],
                          style: TextStyle(
                            fontWeight: selectedIndex == i
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selectedIndex == i
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: selectedFeeds.length,
                itemBuilder: (context, i) {
                  final feed = selectedFeeds[i] as FeedItem;
                  return InkWell(
                    onTap: () async {
                      final url =
                          feed.link; // asegúrate que 'link' sea la URL del feed
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Opcional: mostrar mensaje de error
                        CustomSnackBar.show(
                          context,
                          AppLocalizations.of(context)!.cantOpenLink,
                          Colors.red,
                          duration: Duration(seconds: 4),
                        );
                      }
                    },
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              feed.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              feed.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              feed.pubDate?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
