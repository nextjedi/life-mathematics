import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Change app appearance'),
            onTap: () {
              // TODO: Implement theme settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            subtitle: const Text('Manage calculation history'),
            onTap: () {
              // TODO: Implement history settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('App information and credits'),
            onTap: () {
              // TODO: Implement about screen
            },
          ),
        ],
      ),
    );
  }
}
