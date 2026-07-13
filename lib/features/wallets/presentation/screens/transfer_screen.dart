import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../providers/wallet_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  String? _fromWalletId;
  String? _toWalletId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletsAsync = ref.watch(walletListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: Text(ref.tr('transferFunds'), style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF14102B),
      ),
      body: SafeArea(
        child: walletsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (wallets) {
            if (wallets.length < 2) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_rounded, size: 64, color: AppColors.warning),
                      const Gap(16),
                      Text(
                        ref.tr('multipleWalletsRequired'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Gap(8),
                      Text(
                        ref.tr('multipleWalletsDesc'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Gap(24),
                      FilledButton(
                        onPressed: () => context.pop(),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text(ref.tr('goBack')),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── From Wallet Dropdown ───────────────────────────────
                    DropdownButtonFormField<String>(
                      value: _fromWalletId,
                      onChanged: (v) {
                        setState(() {
                          _fromWalletId = v;
                          if (_toWalletId == v) _toWalletId = null;
                        });
                      },
                      decoration: _inputDecoration(isDark, ref.tr('fromWallet'), Icons.upload_rounded),
                      validator: (v) => v == null ? ref.tr('required') : null,
                      items: wallets
                          .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                          .toList(),
                    ),
                    const Gap(16),

                    // ── To Wallet Dropdown ─────────────────────────────────
                    DropdownButtonFormField<String>(
                      value: _toWalletId,
                      onChanged: (v) {
                        setState(() => _toWalletId = v);
                      },
                      decoration: _inputDecoration(isDark, ref.tr('toWallet'), Icons.download_rounded),
                      validator: (v) => v == null ? ref.tr('required') : null,
                      items: wallets
                          .where((w) => w.id != _fromWalletId)
                          .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                          .toList(),
                    ),
                    const Gap(16),

                    // ── Amount Input ───────────────────────────────────────
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(isDark, ref.tr('transferAmount'), Icons.attach_money_rounded),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val <= 0) return ref.tr('invalidAmount');
                        return null;
                      },
                    ),
                    const Gap(16),

                    // ── Date Picker Field ──────────────────────────────────
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(isDark, ref.tr('transferDate'), Icons.calendar_today_rounded),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF14102B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),

                    // ── Notes ──────────────────────────────────────────────
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: _inputDecoration(isDark, ref.tr('notesReason'), Icons.notes_rounded),
                    ),
                    const Gap(30),

                    // ── Transfer Button ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: _executeTransfer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            ref.tr('executeTransfer'),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: isDark ? const Color(0xFF141414) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  void _executeTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountCtrl.text);
    final note = _noteCtrl.text;

    final transferExpense = Expense(
      id: const Uuid().v4(),
      title: 'Wallet Transfer',
      amount: amount,
      categoryId: 'other', // categorise as other
      walletId: _fromWalletId!,
      toWalletId: _toWalletId,
      type: TransactionType.transfer,
      date: _selectedDate,
      note: note.isEmpty ? 'Transfer between wallets' : note,
      updatedAt: DateTime.now(),
    );

    // Save transaction
    await ref.read(expenseListProvider.notifier).addExpense(transferExpense);
    ref.invalidate(walletBalancesProvider);

    context.pop();
  }
}
