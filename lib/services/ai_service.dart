/// AI service for intent recognition from transcribed speech
/// Used to determine which pictogram category should be shown or highlighted

String suggestIntentResponse(String prompt) {
  final lowerPrompt = prompt.toLowerCase();

  if (_containsAny(lowerPrompt, ['eat', 'food', 'hungry', 'snack'])) {
    return 'food';
  } else if (_containsAny(lowerPrompt, ['drink', 'thirsty', 'beverage'])) {
    return 'drink';
  } else {
    return 'all';
  }
}

/// Utility function to check if prompt contains any of the keywords
bool _containsAny(String input, List<String> keywords) {
  for (final keyword in keywords) {
    if (input.contains(keyword)) return true;
  }
  return false;
}
