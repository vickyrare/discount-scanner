class TextParser {
  static Map<String, double?> parse(String text) {
    // Normalize the text: replace commas with dots for consistent decimal parsing
    final normalizedText = text.replaceAll(',', '.');

    double? price;
    double? discount;

    // Stricter regex: requires a preceding '
    final priceRegex = RegExp(r'\$(\d+\.?\d*)');
    
    // Stricter regex: requires a suffix '%'
    final discountRegex = RegExp(r'(\d{1,2})%');

    final priceMatch = priceRegex.firstMatch(normalizedText);
    if (priceMatch != null) {
      price = double.tryParse(priceMatch.group(1)!);
    }

    final discountMatch = discountRegex.firstMatch(normalizedText);
    if (discountMatch != null) {
      discount = double.tryParse(discountMatch.group(1)!);
    }

    return {'price': price, 'discount': discount};
  }
}
