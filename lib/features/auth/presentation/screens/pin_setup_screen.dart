import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_lang.dart';
import '../providers/auth_provider.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<int> _pin = [];
  final List<int> _confirmPin = [];
  bool _confirming = false;
  String? _error;

  void _onKey(int digit) {
    setState(() {
      _error = null;
      if (!_confirming) {
        if (_pin.length < 4) {
          _pin.add(digit);
          if (_pin.length == 4) {
            Future.delayed(200.ms, () => setState(() => _confirming = true));
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin.add(digit);
          if (_confirmPin.length == 4) _submit();
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      _error = null;
      if (_confirming) {
        if (_confirmPin.isNotEmpty) _confirmPin.removeLast();
      } else {
        if (_pin.isNotEmpty) _pin.removeLast();
      }
    });
  }

  Future<void> _submit() async {
    if (_pin.join() != _confirmPin.join()) {
      setState(() {
        _error = ref.tr('pinMismatch');
        _confirmPin.clear();
      });
      return;
    }
    await ref.read(authStateProvider.notifier).setupPin(_pin.join());
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final currentPin = _confirming ? _confirmPin : _pin;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Gap(AppSizes.xl),
              // Title
              Text(
                _confirming
                    ? ref.tr('confirmPin')
                    : ref.tr('setupPin'),
                style: text.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(),
              const Gap(AppSizes.sm),
              Text(
                _confirming
                    ? ref.tr('confirmPinDesc')
                    : ref.tr('createPinDesc'),
                style: text.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const Gap(AppSizes.xxxl),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => AnimatedContainer(
                    duration: 200.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < currentPin.length
                          ? Colors.white
                          : Colors.white30,
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const Gap(AppSizes.md),
                Text(
                  _error!,
                  style: text.bodySmall?.copyWith(color: Colors.redAccent),
                ).animate().shake(),
              ],
              const Spacer(),

              // Keypad
              _PinKeypad(onKey: _onKey, onDelete: _onDelete),
              const Gap(AppSizes.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PIN Entry Screen ──────────────────────────────────────────────────────────

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  final List<int> _pin = [];
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final authState = ref.read(authStateProvider);
    if (authState.isBiometricEnabled && authState.isBiometricAvailable) {
      final ok =
          await ref.read(authStateProvider.notifier).authenticateBiometric();
      if (ok && mounted) context.go('/dashboard');
    }
  }

  void _onKey(int digit) {
    if (_loading) return;
    setState(() {
      _error = null;
      if (_pin.length < 4) {
        _pin.add(digit);
        if (_pin.length == 4) _verify();
      }
    });
  }

  void _onDelete() {
    setState(() {
      _error = null;
      if (_pin.isNotEmpty) _pin.removeLast();
    });
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    final ok =
        await ref.read(authStateProvider.notifier).verifyPin(_pin.join());
    if (!mounted) return;
    if (ok) {
      context.go('/dashboard');
    } else {
      setState(() {
        _error = ref.tr('pinIncorrect');
        _pin.clear();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Gap(AppSizes.xl),
              const Icon(Icons.lock_rounded, size: 60, color: Colors.white),
              const Gap(AppSizes.md),
              Text(
                ref.tr('enterPin'),
                style: text.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSizes.xxxl),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => AnimatedContainer(
                    duration: 200.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          i < _pin.length ? Colors.white : Colors.white30,
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const Gap(AppSizes.md),
                Text(_error!,
                        style: text.bodySmall
                            ?.copyWith(color: Colors.redAccent))
                    .animate()
                    .shake(),
              ],
              const Spacer(),

              // Biometric button
              if (authState.isBiometricEnabled &&
                  authState.isBiometricAvailable)
                IconButton(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint_rounded,
                      size: 48, color: Colors.white70),
                  tooltip: ref.tr('biometric'),
                ),
              const Gap(AppSizes.lg),

              _PinKeypad(onKey: _onKey, onDelete: _onDelete),
              const Gap(AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared keypad widget ───────────────────────────────────────────────────────

class _PinKeypad extends StatelessWidget {
  final void Function(int) onKey;
  final VoidCallback onDelete;

  const _PinKeypad({required this.onKey, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (_, i) {
          if (i == 9) return const SizedBox();
          if (i == 10) return _KeyButton(label: '0', onTap: () => onKey(0));
          if (i == 11) {
            return _KeyButton(
              icon: Icons.backspace_rounded,
              onTap: onDelete,
            );
          }
          final digit = i + 1;
          return _KeyButton(label: '$digit', onTap: () => onKey(digit));
        },
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeyButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
