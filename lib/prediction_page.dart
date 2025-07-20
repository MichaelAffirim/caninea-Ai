// ignore_for_file: must_be_immutable

import 'package:canine_ai/prediction_score.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class PredictionPage extends StatefulWidget {
  final List _heap;
  const PredictionPage(this._heap, {super.key});

  @override
  _PredictionPageState createState() => _PredictionPageState(_heap);
}

class _PredictionPageState extends State<PredictionPage>
    with SingleTickerProviderStateMixin {
  final List _heap;
  _PredictionPageState(this._heap);
  late PageController _pageController;
  int totalPage = 1;

  Future<Map<String, dynamic>> fetchBreedInfo(String breed) async {
    // Dog CEO API: https://dog.ceo/api/breed/{breed}/images/random
    final breedLower = breed.toLowerCase().replaceAll(' ', '');
    final imageUrlResp = await http.get(Uri.parse('https://dog.ceo/api/breed/$breedLower/images/random'));
    String imageUrl = '';
    if (imageUrlResp.statusCode == 200) {
      final data = jsonDecode(imageUrlResp.body);
      imageUrl = data['message'];
    }
    // Fun fact API (random dog fact)
    final factResp = await http.get(Uri.parse('https://dog-api.kinduff.com/api/facts'));
    String funFact = '';
    if (factResp.statusCode == 200) {
      final data = jsonDecode(factResp.body);
      funFact = data['facts'][0];
    }
    return {
      'imageUrl': imageUrl,
      'funFact': funFact,
    };
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 0)..addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For demo, use the top prediction
    final top = _heap[0];
    final breedName = getBreedName(top['index']);
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchBreedInfo(breedName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Lottie.asset('assets/lottie/loading.json'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching breed info'));
          } else {
            final imageUrl = snapshot.data?['imageUrl'] ?? '';
            final funFact = snapshot.data?['funFact'] ?? '';
            // Save prediction to history
            savePredictionToHistory(breedName, top['score'], imageUrl);
            return Container(
              decoration: BoxDecoration(
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    stops: const [0.3, 0.9],
                    colors: [
                      Colors.black.withOpacity(.9),
                      Colors.black.withOpacity(.2),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            breedName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ConfidenceScoreWidget(confidence: top['score']),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (imageUrl.isNotEmpty)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              imageUrl,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Text(
                        'Fun Fact:',
                        style: TextStyle(
                          color: Colors.amber[200],
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        funFact,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              final shareText =
                                  '🐶 CanineAI Prediction\nBreed: $breedName\nConfidence: ${(top['score'] * 100).toStringAsFixed(2)}%\nFun Fact: $funFact\n$imageUrl';
                              Share.share(shareText);
                            },
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> savePredictionToHistory(String breed, double confidence, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    final prediction = {
      'breed': breed,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'date': now,
    };
    List<String> history = prefs.getStringList('prediction_history') ?? [];
    history.insert(0, jsonEncode(prediction)); // newest first
    await prefs.setStringList('prediction_history', history);
  }

  // Helper to map index to breed name (replace with your actual mapping)
  String getBreedName(int index) {
    // Full ordered breed list from file_list.mat
    List<String> breeds = [
      'Chihuahua', 'Japanese_spaniel', 'Maltese_dog', 'Pekinese', 'Shih', 'Blenheim_spaniel', 'papillon', 'toy_terrier',
      'Rhodesian_ridgeback', 'Afghan_hound', 'basset', 'beagle', 'bloodhound', 'bluetick', 'black', 'Walker_hound',
      'English_foxhound', 'redbone', 'borzoi', 'Irish_wolfhound', 'Italian_greyhound', 'whippet', 'Ibizan_hound',
      'Norwegian_elkhound', 'otterhound', 'Saluki', 'Scottish_deerhound', 'Weimaraner', 'Staffordshire_bullterrier',
      'American_Staffordshire_terrier', 'Bedlington_terrier', 'Border_terrier', 'Kerry_blue_terrier', 'Irish_terrier',
      'Norfolk_terrier', 'Norwich_terrier', 'Yorkshire_terrier', 'wire', 'Lakeland_terrier', 'Sealyham_terrier',
      'Airedale', 'cairn', 'Australian_terrier', 'Dandie_Dinmont', 'Boston_bull', 'miniature_schnauzer',
      'giant_schnauzer', 'standard_schnauzer', 'Scotch_terrier', 'Tibetan_terrier', 'silky_terrier', 'soft',
      'West_Highland_white_terrier', 'Lhasa', 'flat', 'curly', 'golden_retriever', 'Labrador_retriever',
      'Chesapeake_Bay_retriever', 'German_short', 'vizsla', 'English_setter', 'Irish_setter', 'Gordon_setter',
      'Brittany_spaniel', 'clumber', 'English_springer', 'Welsh_springer_spaniel', 'cocker_spaniel', 'Sussex_spaniel',
      'Irish_water_spaniel', 'kuvasz', 'schipperke', 'groenendael', 'malinois', 'briard', 'kelpie', 'komondor',
      'Old_English_sheepdog', 'Shetland_sheepdog', 'collie', 'Border_collie', 'Bouvier_des_Flandres', 'Rottweiler',
      'German_shepherd', 'Doberman', 'miniature_pinscher', 'Greater_Swiss_Mountain_dog', 'Bernese_mountain_dog',
      'Appenzeller', 'EntleBucher', 'boxer', 'bull_mastiff', 'Tibetan_mastiff', 'French_bulldog', 'Great_Dane',
      'Saint_Bernard', 'Eskimo_dog', 'malamute', 'Siberian_husky', 'affenpinscher', 'basenji', 'pug', 'Leonberg',
      'Newfoundland', 'Great_Pyrenees', 'Samoyed', 'Pomeranian', 'chow', 'keeshond', 'Brabancon_griffon',
      'Pembroke', 'Cardigan', 'toy_poodle', 'miniature_poodle', 'standard_poodle', 'Mexican_hairless', 'dingo',
      'dhole', 'African_hunting_dog'
    ];
    if (index < breeds.length) {
      return breeds[index];
    }
    return breeds[0];
  }
}
