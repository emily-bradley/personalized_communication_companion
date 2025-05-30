String suggestIntentResponse(String prompt) {
  if (prompt.toLowerCase().contains("eat")) {
    return "food";
  } else if (prompt.toLowerCase().contains("drink")) {
    return "drink";
  } else {
    return "all";
  }
}