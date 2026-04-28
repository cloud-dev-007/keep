extension StringExtension on String {
  String capitalize() {
    List<String> text = split(" ");

    return text
        .map((element) =>
            "${element[0].toUpperCase()}${element.substring(1).toLowerCase()}")
        .join(" ");
  }
}
