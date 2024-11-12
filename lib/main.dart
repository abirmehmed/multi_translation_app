import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _translatedTexts = [];
  final translator = GoogleTranslator();
  String _selectedSourceLanguage = 'en';
  String _selectedSingleTargetLanguage = 'es';
  List<String> _selectedTargetLanguages = [];
  bool _isMultiLanguageMode = false;

  final Map<String, String> languages = {
    'en': 'English',
    'es': 'Spanish',
    'bn': 'Bengali',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'hi': 'Hindi',
    'ur': 'Urdu',
    'ar': 'Arabic',
    'fr': 'French',
    'de': 'German',
    'fa': 'Persian',
    'he': 'Hebrew',
    'el': 'Greek',
    'la': 'Latin',
  };

  @override
  void initState() {
    super.initState();
    _controller.addListener(_translateText);
  }

  @override
  void dispose() {
    _controller.removeListener(_translateText);
    _controller.dispose();
    super.dispose();
  }

  void _translateText() async {
    final input = _controller.text;
    if (input.isNotEmpty) {
      List<String> translations = [];
      if (_isMultiLanguageMode) {
        for (String language in _selectedTargetLanguages) {
          final translation = await translator.translate(input, from: _selectedSourceLanguage, to: language);
          translations.add(translation.text);
        }
      } else {
        final translation = await translator.translate(input, from: _selectedSourceLanguage, to: _selectedSingleTargetLanguage);
        translations.add(translation.text);
      }
      setState(() {
        _translatedTexts = translations;
      });
    } else {
      setState(() {
        _translatedTexts = [];
      });
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSourceLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSourceLanguage = newValue!;
                        _translateText();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: languages.entries.map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _isMultiLanguageMode
                      ? MultiSelectDialogField(
                    items: languages.entries.map((entry) => MultiSelectItem(entry.key, entry.value)).toList(),
                    title: Text("Select Target Languages"),
                    selectedColor: Colors.blue,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    buttonIcon: Icon(
                      Icons.language,
                      color: Colors.blue,
                    ),
                    buttonText: Text(
                      "To",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      setState(() {
                        _selectedTargetLanguages = results.cast<String>();
                        _translateText();
                      });
                    },
                  )
                      : DropdownButtonFormField<String>(
                    value: _selectedSingleTargetLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSingleTargetLanguage = newValue!;
                        _translateText();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: languages.entries.map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: Icon(_isMultiLanguageMode ? Icons.close : Icons.add),
                  onPressed: () {
                    setState(() {
                      _isMultiLanguageMode = !_isMultiLanguageMode;
                      _translateText();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _translatedTexts.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.primaries[index % Colors.primaries.length].shade50,
                      border: Border.all(color: Colors.primaries[index % Colors.primaries.length], width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _translatedTexts[index],
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () => _copyText(_translatedTexts[index]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
