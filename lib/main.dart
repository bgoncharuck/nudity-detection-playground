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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String verdict = '';
  bool isFemale = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Text(verdict),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 7),
                child: TextButton(
                  child: Text('For Female body parts: $isFemale'),
                  onPressed: () {
                    setState(() => isFemale = !isFemale);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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

          final result = await const DetectNudity().execute(
            params: DetectNudityParams(
              imagePath: image.path,
              isFemale: isFemale,
            ),
          );
          // debugPrint('Nudity is ${result.toString()}');
          setState(() => verdict = 'Nudity is ${result.toString()}');
        },
      ),
    );
  }
}
