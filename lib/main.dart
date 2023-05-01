import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/use_cases/detect_nudity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: Placeholder()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: 100,
          );

          if (image == null) {
            debugPrint('image is null');
            return;
          }

          final result = await const DetectNudity().execute(params: image.path);
          debugPrint('Nudity is ${result.toString()}');
        },
      ),
    );
  }
}
