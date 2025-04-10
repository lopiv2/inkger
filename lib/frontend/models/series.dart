class Series {
  final String title;
  final String coverPath;
  final int seriesNumber;
  final int itemCount; // Campo que almacena el número de elementos en la serie

  Series({
    required this.title,
    required this.coverPath,
    required this.seriesNumber,
    required this.itemCount, // Asegúrate de pasarlo al constructor
  });
}
