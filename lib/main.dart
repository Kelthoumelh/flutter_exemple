// import 'package:atdevmobile/sections/chat.dart';
// import 'package:atdevmobile/sections/chat_stream.dart';
// import 'package:atdevmobile/sections/embed_batch_contents.dart';
// import 'package:atdevmobile/sections/embed_content.dart';
// import 'package:atdevmobile/sections/response_widget_stream.dart';
import 'package:atdevmobile/sections/stream.dart';
import 'package:atdevmobile/sections/text_and_image.dart';
// import 'package:atdevmobile/sections/text_only.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  /// flutter run --dart-define=apiKey='Your Api Key'
  Gemini.init(apiKey: const String.fromEnvironment('apiKey'), enableDebugging: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flumini',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 15, 15, 15)),
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardTheme(
          color: const Color.fromARGB(255, 94, 80, 61).withOpacity(0.85), // Couleur semi-transparente pour les cartes
          shadowColor: Colors.black.withOpacity(0.5),
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 94, 80, 61).withOpacity(0.6), // Barre d'app semi-transparente
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontSize: 22,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          
        ),
      ),

      home: const MyHomePage(),
    );
  }
}

class SectionItem {
  final int index;
  final String title;
  final Widget widget;

  SectionItem(this.index, this.title, this.widget);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedItem = 0;

  final _sections = <SectionItem>[
    SectionItem(0, 'Flumini', const SectionTextStreamInput()),
    SectionItem(1, 'Historique', const SectionTextAndImageInput()),
    // SectionItem(2, 'Chat', const SectionChat()),
    // SectionItem(3, 'Stream Chat', const SectionStreamChat()),
    // SectionItem(4, 'Text Input', const SectionTextInput()),
    // SectionItem(5, 'Embed Content', const SectionEmbedContent()),
    // SectionItem(6, 'Batch Embed Contents', const SectionBatchEmbedContents()),
    // SectionItem(7, 'Response w/o SetState', const ResponseWidgetSection()),
  ];

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      
      appBar: AppBar(
        title: Text(_selectedItem == 0 ? 'Flumini' : _sections[_selectedItem].title),
        actions: [
          PopupMenuButton<int>(
            initialValue: _selectedItem,
            onSelected: (value) => setState(() => _selectedItem = value),
            itemBuilder: (context) => _sections.map((e) {
              return PopupMenuItem<int>(value: e.index, child: Text(e.title));
            }).toList(),
            child: const Icon(Icons.more_vert_rounded),
          )
        ],
        
      ),
      body: 
      
      Stack(
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bureau.png'), // Chemin de l'image
                fit: BoxFit.cover, // Ajuste l'image pour couvrir tout l'écran
              ),
            ),
          ),
          // Flou sur l'image de fond pour améliorer la lisibilité
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4), // Assombrit légèrement l'image
            ),
          ),
          // Contenu de l'application

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IndexedStack(
              index: _selectedItem,
              children: _sections.map((e) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85), // Contenu avec fond semi-transparent
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4), // Ombre plus douce
                      ),
                    ],
                  ),
                  child: e.widget,
                );
              }).toList(),
            ),
          ),
        ],
        
      ),
      
    );
    return scaffold;
    
  }
  
}
