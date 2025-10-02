import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert' as convert;
import '../models/patient_data.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../theme/shadcn_colors.dart';
import 'package:http/http.dart' as http;
import '../utils/urdu_decoder.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  DateTime? _dateOfBirth;
  String? _gender; // 'Male' or 'Female'
  String? _emergencyRelation; // dropdown
  String? _bloodGroup; // dropdown
  String? _registrationType; // 'Self' or 'Others'
  String? _parentType; // 'Father' or 'Mother'
  int _tabIndex = 0; // 0 = manual, 1 = from CNIC
  XFile? _capturedImage;
  Uint8List? _capturedBytes; // for web preview
  bool _isOcrRunning = false;
  String _ocrRawText = '';
  String _ocrSanitizedText = '';
  bool _showOcrOverlay = false;
  String? _parsedCnic;
  DateTime? _parsedDob;
  String? _parsedGender;
  List<String> _urduDecoded = [];
  bool _overlayIsBarcode = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactNameController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_registrationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select registration type (Self or Others)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      // Calculate age from date of birth
      int age = 0;
      if (_dateOfBirth != null) {
        final now = DateTime.now();
        age = now.year - _dateOfBirth!.year;
        if (now.month < _dateOfBirth!.month || 
            (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
          age--;
        }
      }

      // Create patient data
      final patient = PatientData(
        fullName: _fullNameController.text.trim(),
        age: age,
        bloodGroup: _bloodGroup ?? '',
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        cnic: _cnicController.text.trim(),
        gender: _gender ?? '',
        dateOfBirth: _dateOfBirth ?? DateTime.now(),
      );

      // Save patient data
      PatientManager.setPatient(patient);

      // Show success dialog and return to dashboard
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Patient Registration'),
          content: Text('Patient "${patient.fullName}" registered successfully for $_registrationType registration.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to dashboard
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTabButton(String label, int index) {
    final bool selected = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(index == 0 ? 12 : 0),
              right: Radius.circular(index == 1 ? 12 : 0),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.black : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCnicCaptureSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Capture CNIC',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _captureFromCamera,
                child: const Text('Open Camera'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _ocrRawText.isNotEmpty
                    ? () => setState(() => _showOcrOverlay = !_showOcrOverlay)
                    : null,
                child: Text(_showOcrOverlay ? 'Hide OCR' : 'Show OCR'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _capturedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _capturedBytes ?? Uint8List(0),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _isOcrRunning
                              ? const CircularProgressIndicator()
                              : Text(
                                  'No image captured',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                        ),
                ),
                if (_showOcrOverlay && _ocrRawText.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.black.withOpacity(0.65),
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _overlayIsBarcode ? 'Barcode Preview' : 'OCR Preview',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => setState(() => _showOcrOverlay = false),
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  tooltip: 'Close',
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_overlayIsBarcode ? 'Raw (Barcode)' : 'Raw (OCR)', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(_ocrRawText, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
                                    const SizedBox(height: 8),
                                    Text(_overlayIsBarcode ? 'Sanitized (Barcode)' : 'Sanitized (OCR)', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(_ocrSanitizedText, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Fields detected', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 6),
                                          Text('CNIC: ${_parsedCnic ?? '-'}', style: const TextStyle(color: Colors.white70)),
                                          Text('DOB: ${_parsedDob != null ? (_parsedDob!.year.toString().padLeft(4,'0') + '-' + _parsedDob!.month.toString().padLeft(2,'0') + '-' + _parsedDob!.day.toString().padLeft(2,'0')) : '-'}', style: const TextStyle(color: Colors.white70)),
                                          Text('Gender: ${_parsedGender ?? '-'}', style: const TextStyle(color: Colors.white70)),
                                          if (_urduDecoded.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text('Urdu decoded', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            ..._urduDecoded.map((s) => Text(s, style: const TextStyle(color: Colors.white70)))
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        try {
          final bytes = await image.readAsBytes();
          setState(() {
            _capturedBytes = bytes;
          });
        } catch (_) {}
        if (kIsWeb) {
          if (_capturedBytes != null) {
            await _runOcrOnImageWeb(_capturedBytes!);
          }
        } else {
          // Mobile/desktop: try barcode first, then OCR
          final decoded = await _runBarcodeOnImage(image);
          if (!decoded) {
            await _runOcrOnImage(image);
          }
        }
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _runOcrOnImage(XFile image) async {
    setState(() {
      _isOcrRunning = true;
    });
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final String raw = recognizedText.text;
      final String fullText = _sanitizeOcr(raw);
      _ocrRawText = raw;
      _ocrSanitizedText = fullText;
      _overlayIsBarcode = false;
      _populateFieldsFromCnicText(fullText);
      _decodeUrduCandidates(fullText);
    } catch (_) {
      // ignore errors silently for now
    } finally {
      if (mounted) {
        setState(() {
          _isOcrRunning = false;
        });
      }
    }
  }

  Future<bool> _runBarcodeOnImage(XFile image) async {
    setState(() {
      _isOcrRunning = true;
    });
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodeScanner = BarcodeScanner(
        formats: [
          BarcodeFormat.pdf417,
          BarcodeFormat.code128,
          BarcodeFormat.qrCode,
        ],
      );
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      if (barcodes.isEmpty) return false;

      // Prefer PDF417 (commonly used on IDs)
      barcodes.sort((a, b) {
        int score(BarcodeFormat f) => f == BarcodeFormat.pdf417 ? 2 : (f == BarcodeFormat.code128 ? 1 : 0);
        return score(b.format).compareTo(score(a.format));
      });

      final StringBuffer buffer = StringBuffer();
      for (final b in barcodes) {
        if (b.rawValue != null && b.rawValue!.trim().isNotEmpty) {
          buffer.writeln(b.rawValue);
        }
      }
      final raw = buffer.toString();
      final text = _sanitizeOcr(raw);
      if (text.trim().isEmpty) return false;
      _ocrRawText = raw;
      _ocrSanitizedText = text;
      _overlayIsBarcode = true;
      _populateFieldsFromCnicText(text);
      _decodeUrduCandidates(text);
      return true;
    } catch (_) {
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isOcrRunning = false;
        });
      }
    }
  }

  void _populateFieldsFromCnicText(String text) {
    // CNIC pattern 12345-1234567-1
    final RegExp cnicPattern = RegExp(r'(\d{5}-\d{7}-\d)');
    final RegExp datePattern = RegExp(r'(\d{2})[\/-](\d{2})[\/-](\d{4})'); // DD/MM/YYYY or DD-MM-YYYY
    final RegExp namePattern = RegExp(r'Name\s*:?\s*([A-Za-z ]{3,})', caseSensitive: false);

    // 1) Prefer date directly under the "Date of Birth" label in sanitized OCR
    try {
      final List<String> lines = text.split(RegExp(r'\r?\n'));
      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i].toLowerCase().trim();
        if (line.contains('date of birth')) {
          for (int j = i + 1; j < lines.length && j <= i + 3; j++) {
            final String next = lines[j].trim();
            final RegExp dobDot = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$');
            final RegExp dobSlashDash = RegExp(r'^(\d{2})[\/-](\d{2})[\/-](\d{4})$');
            final RegExpMatch? m = dobDot.firstMatch(next) ?? dobSlashDash.firstMatch(next);
            if (m != null) {
              final int d = int.tryParse(m.group(1)!) ?? 1;
              final int mth = int.tryParse(m.group(2)!) ?? 1;
              final int y = int.tryParse(m.group(3)!) ?? 1900;
              try {
                final dob = DateTime(y, mth, d);
                _dateOfBirth = dob;
                _parsedDob = dob;
              } catch (_) {}
              break;
            }
          }
          break;
        }
      }
    } catch (_) {}

    final cnicMatch = cnicPattern.firstMatch(text);
    if (cnicMatch != null) {
      final String rawCnic = cnicMatch.group(1)!;
      _cnicController.text = _formatCnic(rawCnic);
      _parsedCnic = _formatCnic(rawCnic);

      // Infer gender via NADRA rule from CNIC last digit (odd=Male, even=Female)
      final String digitsOnly = rawCnic.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length >= 13) {
        final int lastDigit = int.tryParse(digitsOnly[digitsOnly.length - 1]) ?? -1;
        if (lastDigit != -1) {
          _gender = (lastDigit % 2 == 1) ? 'Male' : 'Female';
        }
      }

      // Prefer date in format dd.MM.yyyy immediately after CNIC (separated by space)
      final RegExp dotDatePattern = RegExp(r'\b(\d{2})\.(\d{2})\.(\d{4})\b');
      final String tail = text.substring(cnicMatch.end);
      final RegExpMatch? dotAfter = dotDatePattern.firstMatch(tail);
      if (dotAfter != null) {
        final int d = int.tryParse(dotAfter.group(1)!) ?? 1;
        final int m = int.tryParse(dotAfter.group(2)!) ?? 1;
        final int y = int.tryParse(dotAfter.group(3)!) ?? 1900;
        try {
          if (_dateOfBirth == null) {
            _dateOfBirth = DateTime(y, m, d);
            _parsedDob = _dateOfBirth;
          }
        } catch (_) {}
      }
    }

    // If DOB not already set, collect dates (slashes, dashes, and dots) and choose oldest
    final RegExp dotDatePatternAll = RegExp(r'(\d{2})\.(\d{2})\.(\d{4})');
    final Iterable<RegExpMatch> allDates = [
      ...datePattern.allMatches(text),
      ...dotDatePatternAll.allMatches(text),
    ];
    DateTime? oldest;
    for (final m in allDates) {
      final String day = m.group(1)!;
      final String month = m.group(2)!;
      final String year = m.group(3)!;
      final int d = int.tryParse(day) ?? 1;
      final int mm = int.tryParse(month) ?? 1;
      final int y = int.tryParse(year) ?? 1900;
      try {
        final candidate = DateTime(y, mm, d);
        if (oldest == null || candidate.isBefore(oldest!)) {
          oldest = candidate;
        }
      } catch (_) {}
    }
    if (_dateOfBirth == null && oldest != null) {
      _dateOfBirth = oldest;
      _parsedDob = oldest;
    }

    final nameMatch = namePattern.firstMatch(text);
    if (nameMatch != null) {
      final String name = nameMatch.group(1)!.trim();
      if (name.length >= 3) {
        _fullNameController.text = name;
      }
    }

    // If CNIC didn't set gender, fallback to labeled/token heuristics (M/F or MALE/FEMALE)
    if (_gender == null) {
      final genderLabel = RegExp(r'\b(GENDER|SEX)\s*[:\-]?\s*([A-Z])([A-Z]*)\b', caseSensitive: false).firstMatch(text);
      String? g;
      if (genderLabel != null) {
        final String letter = genderLabel.group(2)!.toUpperCase();
        final String rest = (genderLabel.group(3) ?? '').toUpperCase();
        g = rest.isNotEmpty ? (letter + rest) : letter;
      } else {
        final mToken = RegExp(r'\bMALE\b', caseSensitive: false).hasMatch(text);
        final fToken = RegExp(r'\bFEMALE\b', caseSensitive: false).hasMatch(text);
        if (mToken) g = 'MALE';
        if (fToken) g = 'FEMALE';
      }
      if (g != null) {
        if (g == 'M' || g == 'MALE') _gender = 'Male';
        if (g == 'F' || g == 'FEMALE') _gender = 'Female';
      }
    }

    _parsedGender = _gender;

    setState(() {});
  }

  // Web OCR using OCR.space (requires API key)
  static const String _ocrSpaceEndpoint = 'https://api.ocr.space/parse/image';
  static const String _ocrSpaceApiKey = String.fromEnvironment('OCR_SPACE_API_KEY', defaultValue: '');

  Future<void> _runOcrOnImageWeb(Uint8List bytes) async {
    setState(() {
      _isOcrRunning = true;
    });
    try {
      if (_ocrSpaceApiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Set OCR_SPACE_API_KEY to enable web OCR')),
        );
        return;
      }
      final String base64Image = 'data:image/jpeg;base64,' + convert.base64Encode(bytes);
      final response = await http.post(
        Uri.parse(_ocrSpaceEndpoint),
        headers: {
          'apikey': _ocrSpaceApiKey,
        },
        body: {
          'base64Image': base64Image,
          'OCREngine': '2',
          'language': 'eng',
        },
      );
      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['ParsedResults'] as List<dynamic>?;
        final raw = (results != null && results.isNotEmpty)
            ? (results.first['ParsedText'] as String? ?? '')
            : '';
        final text = _sanitizeOcr(raw);
        if (text.isNotEmpty) {
          _ocrRawText = raw;
          _ocrSanitizedText = text;
          _overlayIsBarcode = false;
          _populateFieldsFromCnicText(text);
          _decodeUrduCandidates(text);
        }
      } else {
        // ignore errors quietly; could show a toast
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _isOcrRunning = false;
        });
      }
    }
  }

  String _sanitizeOcr(String text) {
    String t = text;
    // Fix stray 'O' between CNIC and DOB (treat as space)
    t = t.replaceAll(RegExp(r'(\d{5}-\d{7}-\d)\s*[oO]\s*(\d{2}[./-]\d{2}[./-]\d{4})'), r'$1 $2');
    // Fix between Identity Number and date
    t = t.replaceAll(RegExp(r'(Identity\s*Number)\s*[oO]\s*(\d{2}[./-]\d{2}[./-]\d{4})', caseSensitive: false), r'$1 $2');
    // Fix between Gender and Country of Stay
    t = t.replaceAll(RegExp(r'(Gender)\s*[oO]\s*(Country\s*of\s*Stay)', caseSensitive: false), r'$1 $2');

    // If CNIC and DOB are on the same line, move DOB to the next line
    final cnDobSameLine = RegExp(r'^(\s*\d{5}-\d{7}-\d)\s+(\d{2}[./-]\d{2}[./-]\d{4})(.*)$', multiLine: true);
    t = t.replaceAllMapped(cnDobSameLine, (m) => '${m.group(1)}\n${m.group(2)}${m.group(3) ?? ''}');
    // Also handle when the line includes the Identity Number label
    final idLabelSameLine = RegExp(r'^(.*\bIdentity\s*Number\b.*\d{5}-\d{7}-\d)\s+(\d{2}[./-]\d{2}[./-]\d{4})(.*)$', caseSensitive: false, multiLine: true);
    t = t.replaceAllMapped(idLabelSameLine, (m) => '${m.group(1)}\n${m.group(2)}${m.group(3) ?? ''}');
    return t;
  }

  void _decodeUrduCandidates(String sanitized) {
    // Heuristic: find comma-separated hex sequences possibly spanning multiple tokens/lines
    // Example: "A0,U1,20,07,08,09,12,32" or lines containing repeated ",[0-9A-F]{2}"
    final RegExp hexSeq = RegExp(r'(?:(?:\b[0-9A-Fa-f]{2}\b),){2,}(?:\b[0-9A-Fa-f]{2}\b)');
    final matches = hexSeq.allMatches(sanitized);
    final List<String> decoded = [];
    for (final m in matches) {
      final csv = m.group(0)!;
      final urdu = UrduDecoder.convertToUrdu(csv);
      if (urdu.trim().isNotEmpty) decoded.add(urdu);
    }
    setState(() {
      _urduDecoded = decoded;
    });
  }

  String? _requiredValidator(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String _getCnicLabel() {
    if (_registrationType == 'Others') {
      if (_parentType == 'Father') {
        return 'Father\'s CNIC';
      } else if (_parentType == 'Mother') {
        return 'Mother\'s CNIC';
      } else {
        return 'Parent\'s CNIC';
      }
    }
    return 'CNIC';
  }

  // Formats numeric input into 12345-1234567-1 as the user types.
  static final RegExp _nonDigit = RegExp(r'[^0-9]');
  static String _formatCnic(String raw) {
    final String digits = raw.replaceAll(_nonDigit, '');
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      out.write(digits[i]);
      if (i == 4 || i == 11) {
        if (i != digits.length - 1) out.write('-');
      }
    }
    return out.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double deviceWidth = MediaQuery.of(context).size.width;
    double formScale = 1.0;
    if (deviceWidth < 600) {
      formScale = 0.5; // mobile
    } else if (deviceWidth < 1024) {
      formScale = 0.8; // tablet
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Tabs
          Container(
            margin: const EdgeInsets.only(top: 16, left: 40, right: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                _buildTabButton('Enter Data Manually', 0),
                _buildTabButton('Enter from CNIC', 1),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Transform.scale(
                    scale: formScale,
                    alignment: Alignment.topCenter,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (_tabIndex == 1) ...[
                        const SizedBox(height: 16),
                        _buildCnicCaptureSection(theme),
                        const SizedBox(height: 16),
                      ],
                      // Registration type radio buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Register as:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Self'),
                                    value: 'Self',
                                    groupValue: _registrationType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _registrationType = value;
                                        if (value == 'Self') {
                                          _parentType = null; // Reset parent type when Self is selected
                                        }
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Others'),
                                    value: 'Others',
                                    groupValue: _registrationType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _registrationType = value;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            // Parent type dropdown (only show when Others is selected)
                            if (_registrationType == 'Others') ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _parentType,
                                decoration: const InputDecoration(
                                  labelText: 'Parent Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: const <String>[
                                  'Father', 'Mother'
                                ].map((p) => DropdownMenuItem<String>(value: p, child: Text(p))).toList(),
                                onChanged: (value) => setState(() => _parentType = value),
                                validator: (v) => v == null || v.isEmpty ? 'Select parent type' : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _fullNameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => _requiredValidator(v, fieldName: 'Full name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cnicController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: _getCnicLabel(),
                                hintText: '12345-1234567-1',
                                border: const OutlineInputBorder(),
                              ),
                              inputFormatters: <TextInputFormatter>[
                                _CnicInputFormatter(),
                              ],
                              validator: (value) {
                                final String? requiredResult = _requiredValidator(value, fieldName: 'CNIC');
                                if (requiredResult != null) return requiredResult;
                                final RegExp pattern = RegExp(r'^\d{5}-\d{7}-\d{1}$');
                                if (!pattern.hasMatch(value!.trim())) {
                                  return 'Enter CNIC as 12345-1234567-1';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final DateTime now = DateTime.now();
                                final DateTime first = DateTime(now.year - 120);
                                final DateTime last = now;
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dateOfBirth ?? DateTime(now.year - 30, 1, 1),
                                  firstDate: first,
                                  lastDate: last,
                                );
                                if (picked != null) {
                                  setState(() {
                                    _dateOfBirth = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of birth',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _dateOfBirth == null
                                      ? 'Select date'
                                      : '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Gender'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  children: <Widget>[
                                    ChoiceChip(
                                      label: const Text('Male'),
                                      selected: _gender == 'Male',
                                      onSelected: (selected) {
                                        setState(() => _gender = selected ? 'Male' : null);
                                      },
                                    ),
                                    ChoiceChip(
                                      label: const Text('Female'),
                                      selected: _gender == 'Female',
                                      onSelected: (selected) {
                                        setState(() => _gender = selected ? 'Female' : null);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final String? requiredResult = _requiredValidator(value, fieldName: 'Email');
                                if (requiredResult != null) return requiredResult;
                                final String trimmed = value!.trim();
                                final bool looksValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
                                if (!looksValid) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                                hintText: '0300-1234567',
                              ),
                              validator: (value) {
                                final String? requiredResult = _requiredValidator(value, fieldName: 'Phone');
                                if (requiredResult != null) return requiredResult;
                                final String digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
                                if (digits.length < 7) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: _addressController,
                                keyboardType: TextInputType.streetAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => _requiredValidator(v, fieldName: 'Address'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(), // Empty container to maintain spacing
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _bloodGroup,
                                decoration: const InputDecoration(
                                  labelText: 'Blood group',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                                ].map((g) => DropdownMenuItem<String>(value: g, child: Text(g))).toList(),
                                onChanged: (value) => setState(() => _bloodGroup = value),
                                validator: (v) => v == null || v.isEmpty ? 'Select blood group' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(), // Empty container to maintain spacing
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyContactNameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Emergency contact name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => _requiredValidator(v, fieldName: 'Emergency contact name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _emergencyRelation,
                              decoration: const InputDecoration(
                                labelText: 'Emergency contact relation',
                                border: OutlineInputBorder(),
                              ),
                              items: const <String>[
                                'Parent', 'Spouse', 'Child', 'Sibling', 'Relative', 'Friend', 'Guardian'
                              ].map((r) => DropdownMenuItem<String>(value: r, child: Text(r))).toList(),
                              onChanged: (value) => setState(() => _emergencyRelation = value),
                              validator: (v) => v == null || v.isEmpty ? 'Select relation' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Action buttons: Cancel and Save
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            width: 160,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                              style: OutlinedButton.styleFrom(
                                textStyle: theme.textTheme.titleMedium,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 200,
                            height: 56,
                            child: FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                textStyle: theme.textTheme.titleMedium,
                              ),
                              child: const Text('Save Patient'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String formatted = _AddPatientPageState._formatCnic(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
