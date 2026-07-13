import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/category_constants.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_provider.dart';

class AddEditGoalScreen extends ConsumerStatefulWidget {
  final SavingsGoal? goal;
  const AddEditGoalScreen({super.key, this.goal});

  @override
  ConsumerState<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends ConsumerState<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _currentCtrl;
  late TextEditingController _noteCtrl;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  late int _selectedColor;
  late String _selectedIcon;

  final List<String> _icons = [
    'savings',
    'star',
    'home',
    'flight',
    'school',
    'gift',
    'car',
    'coffee',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _targetCtrl = TextEditingController(text: g?.targetAmount.toString() ?? '');
    _currentCtrl = TextEditingController(text: g?.currentAmount.toString() ?? '0');
    _noteCtrl = TextEditingController(text: g?.note ?? '');
    if (g != null) {
      _deadline = g.deadline;
    }
    _selectedColor = g?.colorValue ?? CategoryConstants.availableColors.first;
    _selectedIcon = g?.iconName ?? 'savings';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.goal != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Savings Goal' : 'New Savings Goal', style: const TextStyle(fontWeight: FontWeight.w800)),
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
                  decoration: _inputDecoration(isDark, 'Goal Name', Icons.flag_rounded),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const Gap(16),

                TextFormField(
                  controller: _targetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration(isDark, 'Target Amount', Icons.track_changes_rounded),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d <= 0) return 'Invalid target amount';
                    return null;
                  },
                ),
                const Gap(16),

                TextFormField(
                  controller: _currentCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration(isDark, 'Initial Saved Amount', Icons.savings_rounded),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid amount' : null,
                ),
                const Gap(16),

                // Deadline date picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _deadline = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration(isDark, 'Target Deadline', Icons.calendar_today_rounded),
                    child: Text(
                      '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF14102B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Gap(16),

                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: _inputDecoration(isDark, 'Notes / Description', Icons.notes_rounded),
                ),
                const Gap(24),

                // ── Color Picker ─────────────────────────────────────────
                const Text('Goal Theme Color', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Gap(10),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: CategoryConstants.availableColors.length,
                    itemBuilder: (context, index) {
                      final c = CategoryConstants.availableColors[index];
                      final isSel = c == _selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                          ),
                          child: isSel ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                        ),
                      );
                    },
                  ),
                ),
                const Gap(24),

                // ── Icon Picker ──────────────────────────────────────────
                const Text('Goal Icon', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Gap(10),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final iconKey = _icons[index];
                      final isSel = iconKey == _selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = iconKey),
                        child: Container(
                          width: 48,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(iconKey),
                            color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
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
                        isEdit ? 'Save Changes' : 'Create Goal',
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

  IconData _getIconData(String name) {
    switch (name) {
      case 'savings':        return Icons.savings_rounded;
      case 'star':           return Icons.star_rounded;
      case 'home':           return Icons.home_rounded;
      case 'flight':         return Icons.flight_rounded;
      case 'school':         return Icons.school_rounded;
      case 'gift':           return Icons.card_giftcard_rounded;
      case 'car':            return Icons.directions_car_rounded;
      case 'coffee':         return Icons.local_cafe_rounded;
      default:               return Icons.savings_rounded;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final goal = SavingsGoal(
      id: widget.goal?.id ?? const Uuid().v4(),
      name: _nameCtrl.text,
      targetAmount: double.parse(_targetCtrl.text),
      currentAmount: double.parse(_currentCtrl.text),
      deadline: _deadline,
      colorValue: _selectedColor,
      iconName: _selectedIcon,
      note: _noteCtrl.text,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.goal != null) {
      ref.read(savingsGoalListProvider.notifier).updateGoal(goal);
    } else {
      ref.read(savingsGoalListProvider.notifier).addGoal(goal);
    }

    context.pop();
  }
}
