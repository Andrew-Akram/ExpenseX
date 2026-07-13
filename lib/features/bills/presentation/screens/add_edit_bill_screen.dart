import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../wallets/presentation/providers/wallet_provider.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_provider.dart';
import '../../../../core/localization/app_lang.dart';

class AddEditBillScreen extends ConsumerStatefulWidget {
  final Bill? bill;
  const AddEditBillScreen({super.key, this.bill});

  @override
  ConsumerState<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends ConsumerState<AddEditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String? _categoryId;
  String? _walletId;
  bool _isSubscription = false;
  late RecurringInterval _cycle;
  double _reminderDays = 3;

  @override
  void initState() {
    super.initState();
    final b = widget.bill;
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _amountCtrl = TextEditingController(text: b?.amount.toString() ?? '');
    _noteCtrl = TextEditingController(text: b?.note ?? '');
    if (b != null) {
      _dueDate = b.dueDate;
      _categoryId = b.categoryId;
      _walletId = b.walletId;
      _isSubscription = b.isSubscription;
      _reminderDays = b.reminderDaysBefore.toDouble();
    }
    _cycle = b?.cycle ?? RecurringInterval.monthly;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.bill != null;
    final categories = ref.watch(categoryListProvider);
    final wallets = ref.watch(walletListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: Text(isEdit ? ref.tr('editBillSub') : ref.tr('addBillSub'), style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF14102B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration(isDark, ref.tr('billName'), Icons.receipt_long_rounded),
                  validator: (v) => v == null || v.isEmpty ? ref.tr('required') : null,
                ),
                const Gap(16),

                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration(isDark, ref.tr('amountDue'), Icons.attach_money_rounded),
                  validator: (v) => double.tryParse(v ?? '') == null ? ref.tr('invalidAmount') : null,
                ),
                const Gap(16),

                // Category selector
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: _inputDecoration(isDark, ref.tr('category'), Icons.category_rounded),
                  validator: (v) => v == null ? ref.tr('required') : null,
                  items: categories.value?.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList() ?? [],
                ),
                const Gap(16),

                // Wallet selector
                DropdownButtonFormField<String>(
                  value: _walletId,
                  onChanged: (v) => setState(() => _walletId = v),
                  decoration: _inputDecoration(isDark, ref.tr('walletSource'), Icons.account_balance_wallet_rounded),
                  validator: (v) => v == null ? ref.tr('required') : null,
                  items: wallets.value?.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList() ?? [],
                ),
                const Gap(16),

                // Due Date selector
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration(isDark, ref.tr('dueDate'), Icons.calendar_today_rounded),
                    child: Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF14102B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Gap(16),

                // Subscription Toggle
                SwitchListTile(
                  title: Text(ref.tr('isRecurringSubscription'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(ref.tr('subscriptionExample')),
                  value: _isSubscription,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isSubscription = val),
                ),
                const Gap(16),

                if (_isSubscription) ...[
                  DropdownButtonFormField<RecurringInterval>(
                    value: _cycle,
                    onChanged: (v) {
                      if (v != null) setState(() => _cycle = v);
                    },
                    decoration: _inputDecoration(isDark, ref.tr('billingCycle'), Icons.repeat_rounded),
                    items: RecurringInterval.values
                        .where((i) => i != RecurringInterval.none)
                        .map((i) => DropdownMenuItem(value: i, child: Text(ref.tr(i.name))))
                        .toList(),
                  ),
                  const Gap(16),
                ],

                // Reminder Days Slider
                Text(
                  '${ref.tr('reminderDaysBefore')}: ${_reminderDays.round()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _reminderDays,
                  min: 1,
                  max: 7,
                  divisions: 6,
                  activeColor: AppColors.primary,
                  label: _reminderDays.round().toString(),
                  onChanged: (v) => setState(() => _reminderDays = v),
                ),
                const Gap(16),

                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: _inputDecoration(isDark, ref.tr('notesDesc'), Icons.notes_rounded),
                ),
                const Gap(30),

                // ── Save Button ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isEdit ? ref.tr('saveChanges') : ref.tr('createBill'),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final bill = Bill(
      id: widget.bill?.id ?? const Uuid().v4(),
      name: _nameCtrl.text,
      amount: double.parse(_amountCtrl.text),
      dueDate: _dueDate,
      categoryId: _categoryId!,
      walletId: _walletId!,
      isPaid: widget.bill?.isPaid ?? false,
      isSubscription: _isSubscription,
      cycle: _isSubscription ? _cycle : RecurringInterval.none,
      reminderDaysBefore: _reminderDays.round(),
      note: _noteCtrl.text,
      paidDate: widget.bill?.paidDate,
      updatedAt: DateTime.now(),
    );

    if (widget.bill != null) {
      ref.read(billListProvider.notifier).updateBill(bill);
    } else {
      ref.read(billListProvider.notifier).addBill(bill);
    }

    context.pop();
  }
}
