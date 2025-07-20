import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:canine_ai/prediction_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:canine_ai/history_page.dart';
import 'package:canine_ai/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:canine_ai/news_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Canine AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: themeProvider.themeMode, // Now controlled from settings
      home: const SplashScreen(), // Placeholder for splash screen
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('logo.png', width: 160, height: 160),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  Interpreter? _interpreter;
  bool _isLoading = true;
  late List heap;

  @override
  void initState() {
    super.initState();
    loadModel().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> loadModel() async {
    try {
      String modelPath = 'assets/model/canine_ai_model.tflite';
      // Load model
      final ByteData modelData = await rootBundle.load(modelPath);
      final Uint8List modelBytes = modelData.buffer.asUint8List();
      // Initialize interpreter
      _interpreter = Interpreter.fromBuffer(modelBytes);
    } catch (e) {
      print('Failed to load the model or labels: $e');
    }
  }

  Future<void> runInference(img.Image image) async {
    // Preprocess the image
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    var input = Float32List(1 * 224 * 224 * 3); // Reshape input tensor

    var index = 0;
    for (var i = 0; i < 224; i++) {
      for (var j = 0; j < 224; j++) {
        var pixel = resizedImage.getPixel(j, i);
        input[index++] = (pixel.r - 128) / 255.0; // Red
        input[index++] = (pixel.g - 128) / 255.0; // Green
        input[index++] = (pixel.b - 128) / 255.0; // Blue
      }
    }

    // Allocate output tensor
    var output = Float32List(1 * 120);

    // Prepare input tensor
    var inputBuffer = input.reshape([1, 224, 224, 3]);

    // Prepare output tensor
    var outputBuffer = output.reshape([1, 120]);

    // Run inference
    _interpreter!.run(inputBuffer, outputBuffer);

    List<Map<String, dynamic>> pairs = [];
    for (int i = 0; i < outputBuffer[0].length; i++) {
      pairs.add({'score': outputBuffer[0][i], 'index': i});
    }

    pairs.sort((a, b) => -a['score'].compareTo(b['score']));

    heap = [pairs[0], pairs[1], pairs[2]];
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _isLoading = true;
        _image = File(pickedImage.path);
      });
      final bytes = await pickedImage.readAsBytes();
      final image = img.decodeImage(bytes);

      await runInference(image!);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Size screenSize = MediaQuery.of(context).size;
    final double containerWidth = screenSize.width * 0.9;
    final double containerHeight = screenSize.height * 0.45;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CanineAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.article),
            tooltip: 'Dog News',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Prediction History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
        backgroundColor: isDark ? Colors.black : Colors.brown[700],
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF232526), Color(0xFF414345)]
                : [Color(0xFFf6e0b7), Color(0xFF3b3333)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App Logo
              Center(
                child: Image.asset(
                  'logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),
              // Welcome Text / Tagline Placeholder
              Text(
                'Welcome to CanineAI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.brown[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Identify any dog breed instantly!',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.brown[700],
                ),
              ),
              const SizedBox(height: 30),
              // Image Preview or Placeholder
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _image!,
                                width: containerWidth,
                                height: containerHeight,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: containerWidth,
                                height: containerHeight,
                                color: isDark
                                    ? Colors.white10
                                    : Colors.black.withOpacity(0.05),
                                child: Image.asset(
                                  'assets/images/placeholder.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 20),
              // Camera & Gallery Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 24),
                  _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Predict Button
              _image != null
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: isDark
                            ? Colors.amber[700]
                            : Colors.brown[700],
                        foregroundColor: Colors.white,
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.pets),
                      label: const Text(
                        'Predict',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PredictionPage(heap),
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.brown[100],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.amber[700] : Colors.brown[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.amber[700] : Colors.brown[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
