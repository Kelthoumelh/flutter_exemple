import 'package:atdevmobile/sections/text_and_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:atdevmobile/widgets/chat_input_box.dart';
import 'package:atdevmobile/widgets/item_image_view.dart';

class SectionTextStreamInput extends StatefulWidget {
  const SectionTextStreamInput({super.key});

  @override
  State<SectionTextStreamInput> createState() => _SectionTextInputStreamState();
}

class _SectionTextInputStreamState extends State<SectionTextStreamInput> {
  final ImagePicker picker = ImagePicker();
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  String? searchedText, _finishReason;
  List<Uint8List>? images;

  String? get finishReason => _finishReason;
  
  get border => null;
  
  get radius => null;

  set finishReason(String? set) {
    if (set != _finishReason) {
      setState(() => _finishReason = set);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Fond transparent pour voir l'image de fond
      body: Stack(
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bureau.png"), // Image de fond
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Container blanc semi-transparent par-dessus le fond
          
    Container(
  color: Colors.white.withOpacity(0.7), // Couleur du conteneur extérieur
  padding: const EdgeInsets.all(16.0), // Padding autour du conteneur
  child: Column(
    children: [
      // Premier conteneur indépendant
      Container(
        color: const Color.fromARGB(255, 94, 80, 61),
        margin: const EdgeInsets.all(8.0),
        height: 50,
        width: double.infinity, // Prend toute la largeur
         child: const Center(
         child: Text(
          'Comment puis-je vous aider ?',
          style: TextStyle(
          fontSize: 18, // Taille du texte
          color: Color.fromARGB(255, 255, 255, 255), // Couleur du texte
         ),
        ),
        ),
      ),
      
      // Conteneurs alignés horizontalement
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 110, 94, 72),
              margin: const EdgeInsets.all(8.0),
              height: 100,
              child: const Center(
              child: Text(
                'Exemple 1',
                style: TextStyle(
                fontSize: 18, // Taille du texte
                color: Color.fromARGB(255, 255, 255, 255), // Couleur du texte
              ),
              ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 110, 94, 72),
              margin: const EdgeInsets.all(8.0),
              height: 100,
              child: const Center(
              child: Text(
                'Exemple 2',
                style: TextStyle(
                fontSize: 18, // Taille du texte
                color: Color.fromARGB(255, 255, 255, 255), // Couleur du texte
              ),
              ),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
),



          Column(
            children: [
              if (searchedText != null)
                MaterialButton(
                  color: Colors.white, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onPressed: () {
                    setState(() {
                      searchedText = null;
                      finishReason = null;
                    });
                  },
                  child: Text(
                    'Rechercher à nouveau: $searchedText',
                    style: const TextStyle(color: Colors.black), // Texte noir sur beige
                  ),
                ),
              Expanded(
                child: GeminiResponseTypeView(
                  builder: (context, child, response, loading) {
                    if (loading) {
                      return Center(
                        child: Lottie.asset('assets/lottie/ai.json'),
                      );
                    }

                    if (response != null) {
                      return Markdown(
                        data: response,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: Colors.black), // Texte noir
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('Aucun résultat trouvé.', style: TextStyle(color: Colors.black)),
                      );
                    }
                  },
                ),
              ),
              if (finishReason != null)
                Text(finishReason!, style: const TextStyle(color: Colors.black)),
              if (images != null)
                AnimatedOpacity(
                  opacity: images != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.centerLeft,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.5),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images!.length,
                        itemBuilder: (context, index) {
                          return ItemImageView(bytes: images![index]);
                        },
                      ),
                    ),
                  ),
                ),
              ChatInputBox(
                controller: controller,
                onClickCamera: () {
                  picker.pickMultiImage().then((value) async {
                    final imagesBytes = <Uint8List>[];
                    for (final file in value) {
                      imagesBytes.add(await file.readAsBytes());
                    }

                    if (imagesBytes.isNotEmpty) {
                      setState(() {
                        images = imagesBytes;
                      });
                    }
                  });
                },
                onSend: () {
                  if (controller.text.isNotEmpty) {
                    if (kDebugMode) {
                      print('request');
                    }

                    searchedText = controller.text;
                    controller.clear();
                    gemini
                        .streamGenerateContent(searchedText!,
                            images: images,
                            modelName: 'models/gemini-1.5-flash-latest')
                        .handleError((e) {
                      if (e is GeminiException) {
                        if (kDebugMode) {
                          print(e);
                        }
                      }
                    }).listen((value) {
                      setState(() {
                        images = null;
                      });

                      if (value.finishReason != 'STOP') {
                        finishReason = 'Finish reason is `${value.finishReason}`';
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
