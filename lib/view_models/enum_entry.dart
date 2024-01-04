class EnumEntry<T> {
  String description;
  T value;

  EnumEntry({required this.description, required this.value});

  @override
  String toString() {
    return description;
  }
}
