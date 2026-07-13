import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:csv/csv.dart';

import '../../../../core/di/providers.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';

enum ExportFormat { pdf, csv }

final exportProvider =
    AsyncNotifierProvider<ExportNotifier, bool>(ExportNotifier.new);

class ExportNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => false;

  Future<void> exportAndShare(ExportFormat format) async {
    state = const AsyncLoading();
    try {
      final expenses = await ref.read(expenseRepositoryProvider).getExpenses();
      final categories = await ref.read(categoryRepositoryProvider).getCategories();

      final file = format == ExportFormat.pdf
          ? await _generatePdf(expenses, categories)
          : await _generateCsv(expenses, categories);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<File> _generatePdf(
      List<Expense> expenses, List<Category> categories) async {
    final catMap = {for (final c in categories) c.id: c};
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text('Smart Expense Tracker — Report',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated: ${AppDateUtils.formatShort(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Title', 'Category', 'Amount'],
            data: expenses.map((e) {
              final cat = catMap[e.categoryId];
              return [
                AppDateUtils.formatShort(e.date),
                e.title,
                cat?.name ?? e.categoryId,
                CurrencyFormatter.format(e.amount),
              ];
            }).toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.indigo100),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Total: ${CurrencyFormatter.format(expenses.fold(0.0, (s, e) => s + e.amount))}',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expense_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> _generateCsv(
      List<Expense> expenses, List<Category> categories) async {
    final catMap = {for (final c in categories) c.id: c};
    final rows = [
      ['Date', 'Title', 'Category', 'Amount', 'Note'],
      ...expenses.map((e) => [
            AppDateUtils.formatShort(e.date),
            e.title,
            catMap[e.categoryId]?.name ?? e.categoryId,
            e.amount.toString(),
            e.note ?? '',
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expense_report.csv');
    await file.writeAsString(csv);
    return file;
  }
}
