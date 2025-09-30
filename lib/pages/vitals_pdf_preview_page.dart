import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/patient_data.dart';
import '../theme/shadcn_colors.dart';

class VitalsData {
  final int systolic;
  final int diastolic;
  final double weight;
  final double temperature;
  final int pulse;
  final double height;

  VitalsData({
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.temperature,
    required this.pulse,
    required this.height,
  });
}

class VitalsPdfPreviewPage extends StatefulWidget {
  final VitalsData vitals;
  final PatientData patient;

  const VitalsPdfPreviewPage({
    super.key,
    required this.vitals,
    required this.patient,
  });

  @override
  State<VitalsPdfPreviewPage> createState() => _VitalsPdfPreviewPageState();
}

class _VitalsPdfPreviewPageState extends State<VitalsPdfPreviewPage> {
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'Punjab Health Management System',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Patient Vitals Report',
                  style: pw.TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Patient Information Section
              pw.Text(
                'PATIENT INFORMATION',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Full Name: ${widget.patient.fullName}'),
                        pw.Text('Age: ${widget.patient.age} years'),
                        pw.Text('Gender: ${widget.patient.gender}'),
                        pw.Text('CNIC: ${widget.patient.cnic}'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Blood Group: ${widget.patient.bloodGroup}'),
                        pw.Text('Phone: ${widget.patient.phone}'),
                        pw.Text('Email: ${widget.patient.email}'),
                        pw.Text('Date of Birth: ${_formatDate(widget.patient.dateOfBirth)}'),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.Text('Address: ${widget.patient.address}'),
              pw.SizedBox(height: 20),
              
              // Vitals Information Section
              pw.Text(
                'VITAL SIGNS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Systolic BP: ${widget.vitals.systolic} mmHg'),
                        pw.Text('Diastolic BP: ${widget.vitals.diastolic} mmHg'),
                        pw.Text('Weight: ${widget.vitals.weight} kg'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Temperature: ${widget.vitals.temperature}°C'),
                        pw.Text('Pulse Rate: ${widget.vitals.pulse} bpm'),
                        pw.Text('Height: ${widget.vitals.height} cm'),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Report Generated: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'HMS - Punjab Health Management System',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    _pdfBytes = await pdf.save();
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _printPdf() async {
    if (_pdfBytes != null) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _pdfBytes!,
        name: 'Patient_Vitals_Report_${widget.patient.fullName.replaceAll(' ', '_')}',
      );
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes != null) {
      await Printing.sharePdf(
        bytes: _pdfBytes!,
        filename: 'Patient_Vitals_Report_${widget.patient.fullName.replaceAll(' ', '_')}.pdf',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Content
          Expanded(
            child: _pdfBytes == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : PdfPreview(
                    build: (format) => _pdfBytes!,
                    allowPrinting: true,
                    allowSharing: true,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    pdfFileName: 'Patient_Vitals_Report_${widget.patient.fullName.replaceAll(' ', '_')}.pdf',
                  ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: _printPdf,
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _sharePdf,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: FilledButton.styleFrom(
                    backgroundColor: ShadcnColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
