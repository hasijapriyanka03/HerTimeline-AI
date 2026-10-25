import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class MenopauseReportScreen extends StatefulWidget {
  final String userId;

  const MenopauseReportScreen({super.key, required this.userId});

  @override
  State<MenopauseReportScreen> createState() => _MenopauseReportScreenState();
}

class _MenopauseReportScreenState extends State<MenopauseReportScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _report;
  String? _error;

  static const Color _lightPurple = Color(0xFFF0E6FA);
  static const Color _accentPurple = Color(0xFFD4C4E8);
  static const Color _darkPurple = Color(0xFF9B7FC8);
  static const Color _backgroundColor = Color(0xFFFAF5FF);
  static const Color _greenAccent = Color(0xFFB8D4C8);

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      final report = await apiService.generateMenopauseReport(widget.userId);

      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportToPDF() async {
    if (_report == null) return;

    try {
      // Get user profile for personal details
      final apiService = ApiService();
      final userProfile = await apiService.getUserProfile(widget.userId);

      final pdf = pw.Document();

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.purple300),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Menopause Health Report',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Patient Information
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Patient Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildPDFInfoRow(
                    'Name',
                    userProfile?['name'] ?? 'Not provided',
                  ),
                  _buildPDFInfoRow(
                    'Age',
                    userProfile?['age']?.toString() ?? 'Not provided',
                  ),
                  _buildPDFInfoRow('User ID', widget.userId),
                  if (userProfile?['medical_conditions'] != null)
                    _buildPDFInfoRow(
                      'Medical Conditions',
                      (userProfile!['medical_conditions'] as List).join(', '),
                    ),
                  if (userProfile?['allergies'] != null)
                    _buildPDFInfoRow(
                      'Allergies',
                      (userProfile!['allergies'] as List).join(', '),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Statistics
            pw.Text(
              'Health Statistics',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple700,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  _buildPDFStatRow(
                    'Tracking Period',
                    '${_report!['statistics']['totalDays']} days',
                  ),
                  pw.Divider(),
                  _buildPDFStatRow(
                    'Average Hot Flashes',
                    '${_report!['statistics']['avgHotFlashes']} per day',
                  ),
                  pw.Divider(),
                  _buildPDFStatRow(
                    'Average Sleep Quality',
                    '${_report!['statistics']['avgSleepQuality']}/10',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Summary
            pw.Text(
              'Clinical Summary',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple700,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                _report!['summary'],
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
              ),
            ),

            pw.SizedBox(height: 24),

            // Top Symptoms
            if (_report!['statistics']['topSymptoms'] != null &&
                (_report!['statistics']['topSymptoms'] as List).isNotEmpty) ...[
              pw.Text(
                'Most Common Symptoms',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple700,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_report!['statistics']['topSymptoms'] as List)
                    .map(
                      (symptom) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.purple100,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          symptom.toString(),
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.purple700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 24),
            ],

            // Recommendations
            pw.Text(
              'Healthcare Recommendations',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple700,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: (_report!['recommendations'] as List)
                    .asMap()
                    .entries
                    .map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${entry.key + 1}. ',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.purple700,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                entry.value.toString(),
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),

            pw.SizedBox(height: 32),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Important Notice',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'This report is generated based on self-reported data and should be used as a reference for healthcare discussions. '
                    'It does not replace professional medical diagnosis or treatment. Please consult your healthcare provider for personalized medical advice.',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated by Mensa Health Tracker',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      // Save PDF to device
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Menopause_Health_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        // Show success dialog with file location
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _greenAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.check_circle, color: _greenAccent),
                ),
                const SizedBox(width: 12),
                const Text('PDF Generated!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your health report has been saved successfully.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'File Location:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        file.path,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You can find this file in your device\'s Documents folder and share it with your doctor.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    subject: 'Menopause Health Report',
                    text: 'Please find my menopause health report attached.',
                  );
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentPurple,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await OpenFile.open(file.path);
                  if (result.type != ResultType.done) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  pw.Widget _buildPDFInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Health Report',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_report != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.black87),
              onPressed: _exportToPDF,
              tooltip: 'Export to PDF',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _generateReport,
            tooltip: 'Refresh Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _darkPurple),
                  SizedBox(height: 16),
                  Text(
                    'Generating your health report...',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to generate report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accentPurple, _lightPurple],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _accentPurple.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.assessment,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your Health Report',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Based on ${_report?['statistics']?['totalDays'] ?? 0} days of tracking',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistics
                  if (_report?['statistics'] != null) ...[
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Hot Flashes',
                            '${_report!['statistics']['avgHotFlashes']}/day',
                            Icons.local_fire_department,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Sleep Quality',
                            '${_report!['statistics']['avgSleepQuality']}/10',
                            Icons.bedtime,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Summary
                  if (_report?['summary'] != null) ...[
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _report!['summary'],
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Top Symptoms
                  if (_report?['statistics']?['topSymptoms'] != null &&
                      (_report!['statistics']['topSymptoms'] as List)
                          .isNotEmpty) ...[
                    const Text(
                      'Most Common Symptoms',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (_report!['statistics']['topSymptoms'] as List).map(
                              (symptom) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accentPurple.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    symptom.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _darkPurple,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Recommendations
                  if (_report?['recommendations'] != null) ...[
                    const Text(
                      'Recommendations',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _greenAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _greenAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: _greenAccent,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Tips for You',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...(_report!['recommendations'] as List).map((rec) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      rec.toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
