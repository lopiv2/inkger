import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/comic_filter_provider.dart';
import 'package:inkger/frontend/utils/filter_fields.dart';
import 'package:provider/provider.dart';

class ComicsFiltersLayout extends StatelessWidget {
  const ComicsFiltersLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<ComicFilterProvider>(context);
    final hasActiveFilters =
        filters.selectedWriters.isNotEmpty ||
        filters.selectedCharacters.isNotEmpty ||
        filters.selectedLocations.isNotEmpty ||
        filters.selectedSeries.isNotEmpty ||
        filters.selectedStoryArcs.isNotEmpty ||
        filters.selectedTeams.isNotEmpty ||
        filters.selectedPublishers.isNotEmpty;

    return Visibility(
      visible: filters.isFilterMenuVisible,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasActiveFilters) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Filtros activos:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ...filters.selectedWriters.map((author) {
                    return Chip(
                      label: Text('Autor: $author'),
                      onDeleted: () {
                        filters.removeWriter(author);
                      },
                    );
                  }),
                  ...filters.selectedPublishers.map((publisher) {
                    return Chip(
                      label: Text('Editorial: $publisher'),
                      onDeleted: () {
                        filters.removePublisher(publisher);
                      },
                    );
                  }),
                  ...filters.selectedCharacters.map((character) {
                    return Chip(
                      label: Text('Personajes: $character'),
                      onDeleted: () {
                        filters.removeCharacter(character);
                      },
                    );
                  }),
                  ...filters.selectedLocations.map((location) {
                    return Chip(
                      label: Text('Localizacion: $location'),
                      onDeleted: () {
                        filters.removeLocation(location);
                      },
                    );
                  }),
                  ...filters.selectedTeams.map((team) {
                    return Chip(
                      label: Text('Equipos: $team'),
                      onDeleted: () {
                        filters.removeTeam(team);
                      },
                    );
                  }),
                  ...filters.selectedSeries.map((serie) {
                    return Chip(
                      label: Text('Series: $serie'),
                      onDeleted: () {
                        filters.removeSeries(serie);
                      },
                    );
                  }),
                  ...filters.selectedStoryArcs.map((storyArc) {
                    return Chip(
                      label: Text('Arco: $storyArc'),
                      onDeleted: () {
                        filters.removeStoryArc(storyArc);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterFields(
                  title: "Autor",
                  hint: 'Selecciona autores',
                  availableFilters: filters.availableWriters,
                  toggle: filters.toggleWriter,
                ),
                const SizedBox(width: 32),
                FilterFields(
                  title: "Editorial",
                  hint: 'Selecciona Editorial',
                  availableFilters: filters.availablePublishers,
                  toggle: filters.togglePublisher,
                ),
                const SizedBox(width: 32),
                FilterFields(
                  title: "Personajes",
                  hint: 'Selecciona personaje',
                  availableFilters: filters.availableCharacters,
                  toggle: filters.toggleCharacter,
                ),
                const SizedBox(width: 32),
                FilterFields(
                  title: "Equipos",
                  hint: 'Selecciona equipo',
                  availableFilters: filters.availableTeams,
                  toggle: filters.toggleTeam,
                ),
                const SizedBox(width: 32),
                FilterFields(
                  title: "Localizaciones",
                  hint: 'Selecciona localizacion',
                  availableFilters: filters.availableLocations,
                  toggle: filters.toggleLocation,
                ),
                const SizedBox(width: 32),
                FilterFields(
                  title: "Series",
                  hint: 'Selecciona serie',
                  availableFilters: filters.availableSeries,
                  toggle: filters.toggleSeries,
                ),
                const SizedBox(width: 32),
                FilterFields(
                  title: "Arcos",
                  hint: 'Selecciona arco',
                  availableFilters: filters.availableStoryArcs,
                  toggle: filters.toggleStoryArc,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}