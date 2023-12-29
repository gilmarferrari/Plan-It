class Extensions {
  static Map<dynamic, List<T>> groupBy<T>(
      List<T> list, dynamic Function(T) getKey) {
    Map<dynamic, List<T>> result = {};

    for (var item in list) {
      var key = getKey(item);
      result.putIfAbsent(key, () => []);
      result[key]!.add(item);
    }

    return result;
  }

  static Map<T, int> mostFrequent<T>(
      List<T> list, dynamic Function(T) comparator, int count) {
    if (list.isEmpty || count > list.length) {
      return {};
    }

    var groupedList = groupBy(list, comparator);
    Map<T, int> countMap = {};

    for (var entry in groupedList.entries) {
      var element = entry.value[0];

      if (!countMap.containsKey(element)) {
        countMap.addAll({element: entry.value.length});
      }
    }

    var sortedEntries = countMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(count));
  }

  static Map<T, double> highestValue<T>(List<T> list,
      dynamic Function(T) comparator, dynamic Function(T) sorter, int count) {
    if (list.isEmpty || count > list.length) {
      return {};
    }

    Map<T, double> countMap = {};

    for (var entry in list) {
      var key = comparator(entry);

      if (!countMap.keys.any((k) => comparator(k) == key)) {
        countMap.addAll({
          entry: list
              .where((l) => comparator(l) == key)
              .map((l) => sorter(l))
              .fold<double>(0, (a, b) => a + b)
        });
      }
    }

    var sortedEntries = countMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(count));
  }
}
