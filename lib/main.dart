import 'package:flutter/material.dart';
import 'package:personalized_communication_companion/services/ai_service.dart';
import 'package:personalized_communication_companion/services/stt_service.dart';
import 'package:personalized_communication_companion/services/tts_service.dart';
import 'package:personalized_communication_companion/screens/customize_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Communication Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Let\'s Talk!'),
    );
  }
}

class CategoryChip {
  final IconData icon;
  final String label;
  final String id;

  CategoryChip({required this.icon, required this.label, required this.id});
}

class TileOption {
  final String image;
  final String message;
  final String category;

  const TileOption({
    required this.image,
    required this.message,
    this.category = 'all',
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final STTService sttService = STTService();
  final TTSService ttsService = TTSService();

  bool _isListening = false;
  String _lastWords = '';
  String _suggestedCategory = 'all';
  String selectedMessage = '';

  final List<CategoryChip> categories = [
    CategoryChip(icon: Icons.home, label: 'All', id: 'all'),
    CategoryChip(icon: Icons.restaurant, label: 'Food', id: 'food'),
    CategoryChip(icon: Icons.local_drink, label: 'Drink', id: 'drink'),
    CategoryChip(icon: Icons.emoji_emotions, label: 'Emotions', id: 'emotions'),
    CategoryChip(icon: Icons.sports_soccer, label: 'Activities', id: 'activities'),
    CategoryChip(icon: Icons.chat_bubble_outline, label: 'Response', id: 'response'),
  ];

  final List<TileOption> tileOptions = [
    TileOption(image: 'assets/images/carrot.png', message: 'I want a carrot.', category: 'food'),
    TileOption(image: 'assets/images/asparagus.png', message: 'I want asparagus.', category: 'food'),
    TileOption(image: 'assets/images/donut.png', message: 'I want a donut.', category: 'food'),
    TileOption(image: 'assets/images/chorizo.png', message: 'I want chorizo.', category: 'food'),
    TileOption(image: 'assets/images/chocolate.png', message: 'I want chocolate.', category: 'food'),
    TileOption(image: 'assets/images/food.png', message: 'I want food.', category: 'food'),
  ];

  List<TileOption> get filteredTiles {
    if (_suggestedCategory == 'all') return tileOptions;
    return tileOptions.where((tile) => tile.category == _suggestedCategory).toList();
  }

  @override
  void dispose() {
    ttsService.dispose();
    sttService.stopListening();
    super.dispose();
  }

  void updateMessage(String message) async {
    setState(() {
      selectedMessage = message;
    });
    await ttsService.speak(message);
  }

  void _startListening() async {
    final success = await sttService.startListening(
      onResult: (transcribed) {
        setState(() {
          _lastWords = transcribed;
          _suggestedCategory = suggestIntentResponse(_lastWords);
        });
      },
      onStatus: (status) => print("STT status: \$status"),
      onError: (error) {
        print("STT error: \$error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Speech recognition error: \$error")),
        );
      },
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition not available")),
      );
      return;
    }

    setState(() => _isListening = true);
  }

  void _stopListening() {
    sttService.stopListening();
    setState(() => _isListening = false);
  }

  Color _getTileColor(String category) {
    switch (category) {
      case 'food':
        return Colors.pink.shade50;
      case 'drink':
        return Colors.blue.shade50;
      case 'emotions':
        return Colors.orange.shade50;
      case 'activities':
        return Colors.green.shade50;
      case 'response':
        return Colors.purple.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  String _emojiFor(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('carrot')) return '🥕';
    if (msg.contains('asparagus')) return '🌿';
    if (msg.contains('donut')) return '🍩';
    if (msg.contains('chorizo')) return '🌭';
    if (msg.contains('chocolate')) return '🍫';
    if (msg.contains('food')) return '🍽️';
    return '🧩';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomizePage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
                        Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text("Customize Companion"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomizePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.black12),
                    elevation: 2,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.volume_up, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(
                                'Listen Mode',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the microphone to listen for context and get suggestions',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _isListening ? Icons.hearing_disabled : Icons.mic,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isListening && _lastWords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'You said: $_lastWords',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categories.map((cat) {
                        final bool isSelected = _suggestedCategory == cat.id;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon, size: 18),
                              const SizedBox(width: 6),
                              Text(cat.label),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (_) {
                            setState(() {
                              _suggestedCategory = cat.id;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Tiles
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Pictograms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filteredTiles.map((tile) {
                        return GestureDetector(
                          onTap: () => updateMessage(tile.message),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 24,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: _getTileColor(tile.category),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _emojiFor(tile.message),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tile.message.replaceAll('I want ', '').replaceAll('.', ''),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            if (selectedMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speaking:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedMessage,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
