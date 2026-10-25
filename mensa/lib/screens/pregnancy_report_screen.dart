import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PregnancyReportScreen extends StatefulWidget {
  final String userId;

  const PregnancyReportScreen({super.key, required this.userId});

  @override
  State<PregnancyReportScreen> createState() => _PregnancyReportScreenState();
}

class _PregnancyReportScreenState extends State<PregnancyReportScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<dynamic> _logs = [];
  String? _error;

  static const Color _lightPink = Color(0xFFF5E6E6);
  static const Color _accentPink = Color(0xFFD4A5A5);
  static const Color _darkPink = Color(0xFFA67C7C);
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _greenAccent = Color(0xFFB8D4C8);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      final profile = await apiService.getPregnancyProfile(widget.userId);
      final logs = await apiService.getDailyLogs(widget.userId);

      if (mounted) {
        setState(() {
          _profile = profile?.toJson();
          _logs = logs;
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
    if (_profile == null) return;

    try {
      final apiService = ApiService();
      final userProfile = await apiService.getUserProfile(widget.userId);

      final pdf = pw.Document();

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
                  bottom: pw.BorderSide(width: 2, color: PdfColors.pink300),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Pregnancy Health Report',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.pink700,
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
                color: PdfColors.pink50,
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
                      color: PdfColors.pink700,
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
                  _buildPDFInfoRow(
                    'Current Week',
                    _profile!['currentWeek']?.toString() ?? 'Not provided',
                  ),
                  _buildPDFInfoRow(
                    'Trimester',
                    _profile!['trimester']?.toString() ?? 'Not provided',
                  ),
                  _buildPDFInfoRow(
                    'Due Date',
                    _profile!['dueDate'] != null
                        ? DateFormat(
                            'MMMM dd, yyyy',
                          ).format(DateTime.parse(_profile!['dueDate']))
                        : 'Not provided',
                  ),
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
              'Tracking Statistics',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.pink700,
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
                  _buildPDFStatRow('Total Days Logged', '${_logs.length}'),
                  pw.Divider(),
                  _buildPDFStatRow(
                    'Weeks Tracked',
                    '${(_logs.length / 7).ceil()}',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Recent Logs
            if (_logs.isNotEmpty) ...[
              pw.Text(
                'Recent Health Logs',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.pink700,
                ),
              ),
              pw.SizedBox(height: 12),
              ...(_logs.take(10).map((log) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        log['date'] != null
                            ? DateFormat(
                                'MMMM dd, yyyy',
                              ).format(DateTime.parse(log['date']))
                            : 'Date not available',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (log['mood'] != null &&
                          log['mood'].toString().isNotEmpty)
                        pw.Text(
                          'Mood: ${log['mood']}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      if (log['symptoms'] != null &&
                          (log['symptoms'] as List).isNotEmpty)
                        pw.Text(
                          'Symptoms: ${(log['symptoms'] as List).join(', ')}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      if (log['notes'] != null &&
                          log['notes'].toString().isNotEmpty)
                        pw.Text(
                          'Notes: ${log['notes']}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                );
              }).toList()),
            ],

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

      // Save PDF
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Pregnancy_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
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
                  'Your pregnancy report has been saved successfully.',
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
                  await Share.shareXFiles([
                    XFile(file.path),
                  ], subject: 'Pregnancy Health Report');
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentPink,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await OpenFile.open(file.path);
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkPink,
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
              color: PdfColors.pink700,
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
          'Pregnancy Report',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.black87),
              onPressed: _exportToPDF,
              tooltip: 'Export to PDF',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _darkPink))
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load data',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkPink,
                      foregroundColor: Colors.white,
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accentPink, _lightPink],
                      ),
                      borderRadius: BorderRadius.circular(24),
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
                          'Your Pregnancy Report',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Week ${_profile!['currentWeek']?.toString() ?? 'N/A'} • Trimester ${_profile!['trimester']?.toString() ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Statistics',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('Days Logged', '${_logs.length}'),
                        const Divider(),
                        _buildStatRow(
                          'Weeks Tracked',
                          '${(_logs.length / 7).ceil()}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _exportToPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export to PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _darkPink,
            ),
          ),
        ],
      ),
    );
  }
}
