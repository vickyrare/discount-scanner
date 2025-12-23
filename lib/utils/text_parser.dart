class TextParser {
  static Map<String, double?> parse(String text) {
    // Normalize the text: replace commas with dots for consistent decimal parsing
    final normalizedText = text.replaceAll(',', '.');

    // Regex to find numbers that are explicitly discounts (e.g., 50%, 20% off)
    final discountRegex = RegExp(r'(\d{1,2})\s?(%|off|discount)', caseSensitive: false);
    
    // Regex to find all numbers, including decimals. This is a broad net.
    final numberRegex = RegExp(r'\d+\.?\d*');

    double? price;
    double? discount;

    final List<double> potentialPrices = [];
    final List<double> potentialDiscounts = [];

    // First, specifically look for discounts
    final discountMatches = discountRegex.allMatches(normalizedText);
    for (var match in discountMatches) {
      final discountValue = double.tryParse(match.group(1)!);
      if (discountValue != null && discountValue > 0 && discountValue < 100) {
        potentialDiscounts.add(discountValue);
      }
    }

    // If a discount is found, we can be more confident. Take the first valid one.
    if (potentialDiscounts.isNotEmpty) {
      discount = potentialDiscounts.first;
    }

    // Now, find all numbers and treat them as potential prices
    final numberMatches = numberRegex.allMatches(normalizedText);
    for (var match in numberMatches) {
      final numberValue = double.tryParse(normalizedText.substring(match.start, match.end));
      if (numberValue != null) {
        // Heuristic: If we have a discount, don't add the discount value to the list of potential prices.
        if (discount != null && numberValue == discount) {
          continue;
        }
        potentialPrices.add(numberValue);
      }
    }

    // Heuristic: The largest number is most likely the price.
    if (potentialPrices.isNotEmpty) {
      potentialPrices.sort((a, b) => b.compareTo(a)); // Sort descending
      price = potentialPrices.first;
    }

    // Final check: If price and discount are the same, something is likely wrong.
    // This can happen if the only number on the tag is "50%".
    // In this case, we likely only have a discount, not a price.
    if (price != null && discount != null && price == discount) {
      // If the text for the price was just the number (e.g. "50"), but a discount was found
      // it's more likely that this number was actually the discount.
      // Let's clear the price if there are no other strong indicators.
      // A simple check: does the original text contain a currency symbol? If not, be less sure about the price.
      if (!text.contains(RegExp(r'(\$|€|£)'))) {
         // If there's another potential price, take that one.
        if (potentialPrices.length > 1) {
          price = potentialPrices[1];
        } else {
          // Otherwise, we probably don't have a price.
          price = null;
        }
      }
    }

    return {'price': price, 'discount': discount};
  }
}