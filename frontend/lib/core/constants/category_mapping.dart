class CategoryMapping {
  CategoryMapping._();

  static const Map<String, String> displayNames = {
    "electronics": 'Tech & Lifestyle',
    "jewelery": 'Fine Jewellery',
    "men's clothing": "Men's Edit",
    "women's clothing": "Women's Edit",
  };

  static const Map<String, String> descriptions = {
    "electronics": 'Gadgets & smart accessories',
    "jewelery": 'Statement jewellery & fine pieces',
    "men's clothing": 'Refined menswear essentials',
    "women's clothing": 'Curated womenswear & accents',
  };

  static String displayName(String apiCategory) {
    return displayNames[apiCategory.toLowerCase()] ?? _titleCase(apiCategory);
  }

  static String description(String apiCategory) {
    return descriptions[apiCategory.toLowerCase()] ??
        'Curated fashion & lifestyle picks';
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}