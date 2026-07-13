import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../wallets/presentation/providers/wallet_provider.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../../../../core/localization/app_lang.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  DateTime _selectedDate = DateTime.now();
  List<String> _tags = [];
  String? _receiptPath;
  bool _isRecurring = false;
  RecurringInterval _recurringInterval = RecurringInterval.none;
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.expense!;
      _titleCtrl.text = e.title;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _noteCtrl.text = e.note ?? '';
      _merchantCtrl.text = e.merchant ?? '';
      _selectedCategoryId = e.categoryId;
      _selectedWalletId = e.walletId;
      _selectedDate = e.date;
      _type = e.type;
      _tags = List.from(e.tags);
      _receiptPath = e.receiptPath;
      _isRecurring = e.isRecurring;
      _recurringInterval = e.recurringInterval;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _merchantCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _receiptPath = img.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF14102B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(ref.tr('selectCategory')),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final expense = Expense(
      id: _isEditing ? widget.expense!.id : const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.replaceAll(',', '')),
      categoryId: _selectedCategoryId!,
      walletId: _selectedWalletId ?? 'default_wallet',
      date: _selectedDate,
      type: _type,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      merchant: _merchantCtrl.text.trim().isEmpty ? null : _merchantCtrl.text.trim(),
      tags: _tags,
      receiptPath: _receiptPath,
      isRecurring: _isRecurring,
      recurringInterval: _isRecurring ? _recurringInterval : RecurringInterval.none,
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      await ref.read(expenseListProvider.notifier).updateExpense(expense);
    } else {
      await ref.read(expenseListProvider.notifier).addExpense(expense);
    }

    ref.invalidate(walletBalancesProvider);

    if (mounted) context.pop();
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dt = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF141414) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (dt != null) setState(() => _selectedDate = dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cats = ref.watch(categoryListProvider);
    final walletsAsync = ref.watch(walletListProvider);
    final headerColor = isDark ? Colors.white : const Color(0xFF14102B);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      isDark: isDark,
                      onTap: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        _isEditing ? AppStrings.editExpense : AppStrings.addExpense,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: headerColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // ── Scrollable form body ────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Segmented Transaction Type Selector
                    Row(
                      children: TransactionType.values.map((t) {
                        if (t == TransactionType.transfer) return const SizedBox.shrink(); // Transfer handled separately
                        final isSel = _type == t;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = t),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ref.tr(t.name),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(20),

                    // Amount Card
                    _AmountCard(
                      controller: _amountCtrl,
                      isDark: isDark,
                      validator: (v) {
                        if (v == null || v.isEmpty) return ref.tr('required');
                        final n = double.tryParse(v.replaceAll(',', ''));
                        if (n == null || n <= 0) return ref.tr('invalidAmount');
                        return null;
                      },
                    ),
                    const Gap(28),

                    // Title
                    _FieldLabel(text: ref.tr('expenseTitle'), isDark: isDark),
                    const Gap(8),
                    TextFormField(
                      controller: _titleCtrl,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF14102B),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _pillDecoration(hint: 'e.g. Coffee', isDark: isDark),
                      validator: (v) => v == null || v.trim().isEmpty ? ref.tr('required') : null,
                    ),
                    const Gap(20),

                    // Wallet Dropdown
                    _FieldLabel(text: ref.tr('paymentWallet'), isDark: isDark),
                    const Gap(8),
                    walletsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err'),
                      data: (list) {
                        if (list.isEmpty) return Text(ref.tr('noWalletsFound'));
                        _selectedWalletId ??= list.first.id;
                        return DropdownButtonFormField<String>(
                          value: _selectedWalletId,
                          onChanged: (v) => setState(() => _selectedWalletId = v),
                          decoration: _pillDecoration(hint: ref.tr('paymentWallet'), isDark: isDark),
                          items: list
                              .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                              .toList(),
                        );
                      },
                    ),
                    const Gap(20),

                    // Category Picker
                    _FieldLabel(text: ref.tr('category'), isDark: isDark),
                    const Gap(12),
                    cats.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Text(ref.tr('errorLoadingCategories')),
                      data: (list) => _CategoryChipList(
                        categories: list,
                        selected: _selectedCategoryId,
                        isDark: isDark,
                        onSelect: (id) => setState(() => _selectedCategoryId = id),
                      ),
                    ),
                    const Gap(20),

                    // Merchant Field
                    _FieldLabel(text: ref.tr('merchant'), isDark: isDark),
                    const Gap(8),
                    TextFormField(
                      controller: _merchantCtrl,
                      decoration: _pillDecoration(hint: 'e.g. Walmart, Spotify', isDark: isDark),
                    ),
                    const Gap(20),

                    // Tags Selector
                    _FieldLabel(text: ref.tr('tags'), isDark: isDark),
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagInputCtrl,
                            decoration: _pillDecoration(hint: ref.tr('addTag'), isDark: isDark),
                          ),
                        ),
                        const Gap(8),
                        IconButton.filled(
                          onPressed: () {
                            final tag = _tagInputCtrl.text.trim();
                            if (tag.isNotEmpty && !_tags.contains(tag)) {
                              setState(() {
                                _tags.add(tag);
                                _tagInputCtrl.clear();
                              });
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                          style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const Gap(10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((t) {
                          return Chip(
                            label: Text(t, style: const TextStyle(fontSize: 12)),
                            onDeleted: () => setState(() => _tags.remove(t)),
                            backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          );
                        }).toList(),
                      ),
                    ],
                    const Gap(20),

                    // Date Picker
                    _FieldLabel(text: ref.tr('date'), isDark: isDark),
                    const Gap(8),
                    _DatePickerCard(
                      date: _selectedDate,
                      isDark: isDark,
                      onTap: _pickDate,
                    ),
                    const Gap(20),

                    // Recurring Toggle & Selection
                    SwitchListTile(
                      title: Text(ref.tr('recurringTransaction'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: _isRecurring,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isRecurring = val),
                    ),
                    if (_isRecurring) ...[
                      const Gap(8),
                      DropdownButtonFormField<RecurringInterval>(
                        value: _recurringInterval == RecurringInterval.none ? RecurringInterval.monthly : _recurringInterval,
                        onChanged: (v) {
                          if (v != null) setState(() => _recurringInterval = v);
                        },
                        decoration: _pillDecoration(hint: ref.tr('recurringTransaction'), isDark: isDark),
                        items: RecurringInterval.values
                            .where((i) => i != RecurringInterval.none)
                            .map((i) => DropdownMenuItem(value: i, child: Text(ref.tr(i.name))))
                            .toList(),
                      ),
                    ],
                    const Gap(20),

                    // Receipt Upload
                    _FieldLabel(text: ref.tr('receiptImage'), isDark: isDark),
                    const Gap(8),
                    if (_receiptPath != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_receiptPath!),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white),
                                onPressed: () => setState(() => _receiptPath = null),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                    ] else
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo_rounded),
                        label: Text(ref.tr('attachReceipt')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    const Gap(20),

                    // Note field
                    _FieldLabel(text: ref.tr('expenseNote'), isDark: isDark),
                    const Gap(8),
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF14102B)),
                      decoration: _pillDecoration(hint: ref.tr('addNotes'), isDark: isDark),
                    ),
                  ],
                ),
              ),

              // Sticky Save Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: _SaveButton(
                  label: _isEditing ? ref.tr('updateTransaction') : ref.tr('saveTransaction'),
                  isLoading: _isSaving,
                  onTap: _isSaving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets preserved from original implementation

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white60 : Colors.black54,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF14102B),
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final String? Function(String?) validator;

  const _AmountCard({
    required this.controller,
    required this.isDark,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            'Amount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const Gap(8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Gap(6),
              IntrinsicWidth(
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  validator: validator,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF14102B),
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChipList extends StatelessWidget {
  final List<Category> categories;
  final String? selected;
  final bool isDark;
  final void Function(String) onSelect;

  const _CategoryChipList({
    required this.categories,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Gap(14),
        itemBuilder: (ctx, i) {
          final c = categories[i];
          final isSelected = selected == c.id;
          final catColor = Color(c.colorValue);

          return GestureDetector(
            onTap: () => onSelect(c.id),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? catColor : catColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CategoryConstants.iconFromKey(c.iconName),
                    color: isSelected ? Colors.white : catColor,
                    size: 22,
                  ),
                ),
                const Gap(6),
                Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF14102B),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final DateTime date;
  final bool isDark;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.date,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
            const Gap(12),
            Text(
              AppDateUtils.formatFull(date),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF14102B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SaveButton({
    required this.label,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

InputDecoration _pillDecoration({required String hint, required bool isDark}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    filled: true,
    fillColor: isDark ? const Color(0xFF141414) : Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}