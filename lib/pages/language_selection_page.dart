import 'package:flutter/material.dart';
import 'package:samadhan_app/pages/center_selection_page.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguage; // To hold the currently selected language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page (Login Page)
          },
        ),
        title: const Text('Choose Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLanguageButton(context, 'English'),
            const SizedBox(height: 20),
            _buildLanguageButton(context, 'Hindi'),
            const SizedBox(height: 20),
            _buildLanguageButton(context, 'Marathi'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String language) {
    bool isSelected = _selectedLanguage == language;
    return SizedBox(
      width: 200, // Make buttons larger
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary // Highlight selected
              : Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            _selectedLanguage = language;
          });
          // TODO: Implement logic to save selected language
          print('Selected Language: $language');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CenterSelectionPage()),
          );
        },
        child: Text(language),
      ),
    );
  }
}
