import 'package:flutter/material.dart';

class CustomizePage extends StatelessWidget {
  const CustomizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customize Companion"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.volume_up),
            title: Text("Voice Settings"),
            subtitle: Text("Adjust voice speed and pitch"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.image),
            title: Text("Tile Images"),
            subtitle: Text("Upload or change pictogram images"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text("Theme Colors"),
            subtitle: Text("Customize app theme colors"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About"),
            subtitle: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}
