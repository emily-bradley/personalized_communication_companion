import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:personalized_communication_companion/services/ai_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personalized Communication Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Tap a Food to Speak'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterTts flutterTts = FlutterTts();
  String selectedMessage = '';

  final List<TileOption> tileOptions = [
    TileOption(image: 'assets/images/carrot.png', message: 'I want a carrot.'),
    TileOption(image: 'assets/images/asparagus.png', message: 'I want asparagus.'),
    TileOption(image: 'assets/images/donut.png', message: 'I want a donut.'),
    TileOption(image: 'assets/images/chorizo.png', message: 'I want chorizo.'),
    TileOption(image: 'assets/images/chocolate.png', message: 'I want chocolate.'),
    TileOption(image: 'assets/images/food.png', message: 'I want food.'),
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void updateMessage(String message) async {
    setState(() {
      selectedMessage = message;
    });
    await flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tileOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final option = tileOptions[index];
                return GestureDetector(
                  onTap: () => updateMessage(option.message),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(option.image),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.message,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (selectedMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                selectedMessage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
        ],
      ),
    );
  }
}

class TileOption {
  final String image;
  final String message;

  const TileOption({required this.image, required this.message});
}
