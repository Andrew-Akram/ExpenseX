import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../categories/domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs   = Theme.of(context).colorScheme;
    final cats = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('categories'))),
      body: cats.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${ref.tr('errorPrefix')}: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.category_outlined,
              title: ref.tr('noCategories'),
              actionLabel: ref.tr('addCategory'),
              onAction: () => context.push('/dashboard/categories/add'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final c = list[i];
              final catColor = Color(c.colorValue);
              return ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    CategoryConstants.iconFromKey(c.iconName),
                    color: catColor,
                    size: 20,
                  ),
                ),
                title: Text(c.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(c.isCustom ? ref.tr('custom') : ref.tr('defaultLabel'),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                trailing: c.isCustom
                    ? PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') {
                            context.push(
                                '/dashboard/categories/${c.id}/edit',
                                extra: c);
                          }
                          if (v == 'delete') {
                            _confirmDelete(context, ref, c);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'edit', child: Text(ref.tr('edit'))),
                          PopupMenuItem(
                              value: 'delete', child: Text(ref.tr('delete'))),
                        ],
                      )
                    : null,
              ).animate(delay: (i * 40).ms).fadeIn();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/categories/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ref.tr('deleteCategory')),
        content: Text(
            '${ref.tr('delete')} "${c.name}"? ${ref.tr('deleteCategoryConfirm')}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ref.tr('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ref.tr('delete'))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(categoryListProvider.notifier).deleteCategory(c.id);
    }
  }
}

// ── Add / Edit Category ───────────────────────────────────────────────────────

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const AddEditCategoryScreen({super.key, this.categoryId});

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState
    extends ConsumerState<AddEditCategoryScreen> {
  final _nameCtrl = TextEditingController();
  String _iconName = 'category';
  int _colorValue = AppColors.catOther.toARGB32();
  bool _isEditing = false;
  Category? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _isEditing = true;
      // Load from provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cats = ref.read(categoryListProvider).value;
        final found =
            cats?.where((c) => c.id == widget.categoryId).firstOrNull;
        if (found != null) {
          setState(() {
            _existing  = found;
            _nameCtrl.text = found.name;
            _iconName  = found.iconName;
            _colorValue= found.colorValue;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final cat = Category(
      id: _existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      iconName: _iconName,
      colorValue: _colorValue,
      isCustom: true,
    );
    if (_isEditing) {
      await ref.read(categoryListProvider.notifier).updateCategory(cat);
    } else {
      await ref.read(categoryListProvider.notifier).addCategory(cat);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? ref.tr('editCategory')
            : ref.tr('addCategory')),
        actions: [
          TextButton(
              onPressed: _save, child: Text(ref.tr('save'))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          // Name
          TextFormField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: ref.tr('categoryName')),
          ),
          const Gap(AppSizes.lg),

          // Icon picker
          Text(ref.tr('pickIcon'),
              style:
                  text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const Gap(AppSizes.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: CategoryConstants.availableIconKeys.length,
            itemBuilder: (_, i) {
              final key  = CategoryConstants.availableIconKeys[i];
              final selected = _iconName == key;
              return InkWell(
                onTap: () => setState(() => _iconName = key),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primaryContainer
                        : cs.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                    border: selected
                        ? Border.all(color: cs.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    CategoryConstants.iconFromKey(key),
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
          const Gap(AppSizes.lg),

          // Colour picker
          Text(ref.tr('pickColor'),
              style:
                  text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const Gap(AppSizes.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: CategoryConstants.availableColors.map((c) {
              final selected = _colorValue == c;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = c),
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: cs.onSurface, width: 3)
                        : null,
                    boxShadow: selected
                        ? [BoxShadow(color: Color(c).withOpacity(0.5), blurRadius: 8)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const Gap(AppSizes.xl),

          // Preview
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Color(_colorValue).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    CategoryConstants.iconFromKey(_iconName),
                    color: Color(_colorValue),
                  ),
                ),
                const Gap(AppSizes.md),
                Text(
                  _nameCtrl.text.isEmpty
                      ? 'Preview'
                      : _nameCtrl.text,
                  style: text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Gap(AppSizes.lg),
          ElevatedButton(
            onPressed: _save,
            child: Text(_isEditing ? ref.tr('update') : ref.tr('addCategory')),
          ),
        ],
      ),
    );
  }
}
