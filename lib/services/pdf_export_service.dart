import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:study_app/models/note.dart';
import 'package:study_app/models/block.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static Future<void> exportNoteToPdf(Note note) async {
    final pdf = pw.Document();

    final blocks = List<Block>.from(note.blocks)..sort((a, b) => a.order.compareTo(b.order));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final List<pw.Widget> widgets = [];

          // Note Title
          widgets.add(
            pw.Text(
              note.title.isEmpty ? 'Untitled Note' : note.title,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          );
          
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, bottom: 24),
              child: pw.Text(
                'Generated on ${DateFormat('MMM d, yyyy h:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
          );

          // Iterate and format blocks
          for (var block in blocks) {
            widgets.add(_buildPdfBlock(block));
            widgets.add(pw.SizedBox(height: 2)); // Reduced spacing
          }

          return widgets;
        },
      ),
    );

    // Save and expose the file
    final tempDir = await getTemporaryDirectory();
    final safeTitle = note.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final fileName = '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${tempDir.path}/$fileName');
    
    await file.writeAsBytes(await pdf.save());

    // Trigger share dialog which gives options to "Save to Files", print, or export
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: '${note.title} PDF Export',
    );
  }

  static pw.Widget _buildPdfBlock(Block block) {
    switch (block.type) {
      case BlockType.heading:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
          child: pw.Text(
            block.content,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        );
      case BlockType.text:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
          child: pw.Text(
            block.content,
            style: const pw.TextStyle(fontSize: 12),
          ),
        );
      case BlockType.bullet:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 8),
                child: pw.Text(">", style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.Expanded(
                child: pw.Text(block.content, style: const pw.TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      case BlockType.subBullet:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 32, bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 8),
                child: pw.Text(">>", style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.Expanded(
                child: pw.Text(block.content, style: const pw.TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      case BlockType.checkbox:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 8),
                child: pw.Text(block.isChecked ? "[✓]" : "[ ]", style: pw.TextStyle(fontSize: 12, fontWeight: block.isChecked ? pw.FontWeight.bold : pw.FontWeight.normal)),
              ),
              pw.Expanded(
                child: pw.Text(
                  block.content,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: block.isChecked ? PdfColors.grey : PdfColors.black,
                    decoration: block.isChecked ? pw.TextDecoration.lineThrough : pw.TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        );
      case BlockType.link:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
          child: pw.UrlLink(
            destination: block.content,
            child: pw.Text(
              block.content,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.blue,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
        );
      default:
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 6),
          child: pw.Text(block.content),
        );
    }
  }
}
