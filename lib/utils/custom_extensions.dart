extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension NullStringExtension on String? {
  String value() {
    return this ?? '';
  }
}