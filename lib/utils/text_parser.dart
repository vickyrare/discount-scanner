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

    // Regex to find discount (e.g., 20% off, 15%, discount 30)
    final discountRegex = RegExp(r'(\d{1,2})\s?%?\s?(off|discount)?', caseSensitive: false);
    final discountMatches = discountRegex.allMatches(text);

    for (var match in discountMatches) {
      // Avoid matching parts of the price as a discount
      if (priceMatch != null && match.start >= priceMatch.start && match.end <= priceMatch.end) {
        continue;
      }
      String discountString = match.group(1)!;
      double? potentialDiscount = double.tryParse(discountString);
      if (potentialDiscount != null && potentialDiscount < 100) {
        discount = potentialDiscount;
        break; // Take the first valid discount found
      }
    }

    return {'price': price, 'discount': discount};
  }
}
