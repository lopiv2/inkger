import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/feeds_provider.dart';
import 'package:provider/provider.dart';

class FeedsScreen extends StatefulWidget {
  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {

  int selectedIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final feedsProvider = Provider.of<FeedsProvider>(context);
    final sources = feedsProvider.groupedFeedsBySource;

    if (sources.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Fuentes')),
        body: Center(child: Text('No hay feeds disponibles.')),
      );
    }

    final selectedFeeds = sources[selectedIndex]['feeds'] as List;
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuentes'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: sources.length,
              options: CarouselOptions(
                height: 20,
                viewportFraction: 0.28,
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        elevation: selectedIndex == i ? 6 : 1,
                        borderRadius: BorderRadius.circular(50),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            source['logo'],
                            width: 70,
                            height: 70,
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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: -22,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            source['name'],
                            style: TextStyle(
                              fontWeight: selectedIndex == i ? FontWeight.bold : FontWeight.normal,
                              color: selectedIndex == i ? Theme.of(context).colorScheme.primary : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
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
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: selectedFeeds.length,
                itemBuilder: (context, i) {
                  final feed = selectedFeeds[i];
                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(feed['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(feed['desc'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
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
