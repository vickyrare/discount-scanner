class TextParser {
  static Map<String, double?> parse(String text) {
    double? price;
    double? discount;

    // Regex to find price (e.g., $19.99, 25.50, £10)
    final priceRegex = RegExp(r'(\$|€|£)?\s?(\d+([.,]\d{1,2})?)');
    final priceMatch = priceRegex.firstMatch(text);
    if (priceMatch != null) {
      String priceString = priceMatch.group(2)!.replaceAll(',', '.');
      price = double.tryParse(priceString);
    }

    // Regex to find discount (e.g., 20% off, 15% off, discount 30%)
    final discountRegex = RegExp(r'(\d{1,2})\s?(%|off|discount)', caseSensitive: false);
    final discountMatch = discountRegex.firstMatch(text);
    if (discountMatch != null) {
      String discountString = discountMatch.group(1)!;
      discount = double.tryParse(discountString);
    }

    return {'price': price, 'discount': discount};
  }
}
