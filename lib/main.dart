import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; 
import 'dart:io';
import 'ocr_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Prescription OCR',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: OCRHomePage(),
    );
  }
}

class OCRHomePage extends StatefulWidget {
  @override
  _OCRHomePageState createState() => _OCRHomePageState();
}

class _OCRHomePageState extends State<OCRHomePage> {
  File? _image;
  String _extractedText = '';
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _drugDictionary = {
    'Ferrous': 'Pain relief and fever reduction',
    'Coversgl-plus': 'Anti-inflammatory and pain relief',
    'Crestor': 'Antibiotic for bacterial infections',
    'Ciprofloxacin': 'Broad-spectrum antibiotic',
    'Paracetamol':'The active ingredient is Paracetamol, also known as Acetaminophen , It is used as a pain reliever and fever reducer.',
    'Ibuprofen':'The active ingredient is Ibuprofen , It belongs to the nonsteroidal anti-inflammatory drugs (NSAIDs) class and is used to relieve pain, inflammation, and fever.',
    'Azithromycin': 'The active ingredient is Azithromycin , It is an antibiotic belonging to the macrolide class, used to treat bacterial infections such as respiratory and skin infections.',
    'Montelukast': 'The active ingredient is Montelukast , It is a leukotriene receptor antagonist used to manage asthma and treat allergic rhinitis.',

  };

  List<String> _matchedDrugs = []; 

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _performOCR();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _performOCR();
    }
  }

  Future<void> _performOCR() async {
    if (_image == null) return;
    final text = await OCRService.extractTextFromImage(_image!);
    setState(() {
      _extractedText = text;
      _findMatchedDrugs();
    });
  }


  void _findMatchedDrugs() {
    _matchedDrugs = [];
    _drugDictionary.forEach((drug, info) {
      if (_extractedText.contains(drug)) {
        _matchedDrugs.add('$drug: $info');
      }
    });
  }

  
  void _copyText() {
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Prescription OCR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueGrey, width: 1.5),
              ),
              padding: EdgeInsets.all(10),
              child: _image != null
                  ? Image.file(_image!)
                  : Column(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 100,
                    color: Colors.blueGrey[400],
                  ),
                  Text(
                    'No image selected.',
                    style: TextStyle(
                        fontSize: 16, color: Colors.blueGrey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Capture Prescription'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueGrey[700],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: Icon(Icons.photo),
                  label: Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueGrey[500],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(thickness: 1, color: Colors.blueGrey[300]),
            SizedBox(height: 20),
            Text(
              'Extracted Text:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueGrey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Text(
                      _extractedText.isNotEmpty
                          ? _extractedText
                          : 'No text extracted.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _extractedText.isNotEmpty ? _copyText : null,
                    icon: Icon(Icons.copy),
                    label: Text('Copy Text'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_matchedDrugs.isNotEmpty) ...[
              Divider(thickness: 1, color: Colors.blueGrey[300]),
              SizedBox(height: 10),
              Text(
                'Matched Drugs:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 10),
              ..._matchedDrugs.map((drug) => Text(
                drug,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
