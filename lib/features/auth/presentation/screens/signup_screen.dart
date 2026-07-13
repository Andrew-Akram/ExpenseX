import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_lang.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            fullName: _nameController.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(ref.tr('authError')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ref.tr('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            // ── Soft Top Purple Gradient Background ─────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 420,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E1646).withOpacity(0.55),
                            AppColors.surfaceDark,
                          ]
                        : [
                            const Color(0xFFC9C2FF),
                            const Color(0xFFEDEBFF),
                            AppColors.surface,
                          ],
                    stops: isDark ? null : const [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── Screen Contents ─────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Gap(36),

                      // Lock Icon in Circle
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.14),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.18),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.lock_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      const Gap(24),

                      // Title
                      Text(
                        ref.tr('getStartedWithCashio'),
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF14102B),
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(8),

                      // Subtitle
                      Text(
                        ref.tr('createSecureWallet'),
                        style: text.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 14.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(36),

                      // Full Name input
                      AuthLabeledField(
                        label: ref.tr('fullName'),
                        isDark: isDark,
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: authInputDecoration(
                            hint: ref.tr('enterFullName'),
                            isDark: isDark,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return ref.tr('fullNameRequired');
                            }
                            return null;
                          },
                        ),
                      ),
                      const Gap(20),

                      // Email input
                      AuthLabeledField(
                        label: ref.tr('email'),
                        isDark: isDark,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: authInputDecoration(
                            hint: ref.tr('enterEmail'),
                            isDark: isDark,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return ref.tr('emailRequired');
                            }
                            return null;
                          },
                        ),
                      ),
                      const Gap(20),

                      // Password input
                      AuthLabeledField(
                        label: ref.tr('password'),
                        isDark: isDark,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: authInputDecoration(
                            hint: ref.tr('enterPassword'),
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return ref.tr('passwordRequired');
                            }
                            if (val.length < 6) {
                              return ref.tr('passwordLength');
                            }
                            return null;
                          },
                        ),
                      ),
                      const Gap(20),

                      // Confirm Password input
                      AuthLabeledField(
                        label: ref.tr('confirmPassword'),
                        isDark: isDark,
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: authInputDecoration(
                            hint: ref.tr('confirmPasswordHint'),
                            isDark: isDark,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return ref.tr('confirmPasswordRequired');
                            }
                            if (val != _passwordController.text) {
                              return ref.tr('passwordsDoNotMatch');
                            }
                            return null;
                          },
                        ),
                      ),
                      const Gap(28),

                      // Signup Button
                      AuthPrimaryButton(
                        label: ref.tr('signup'),
                        isLoading: _isLoading,
                        onTap: _isLoading ? null : _onSignup,
                      ),
                      const Gap(16),

                      // Log In navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ref.tr('alreadyHaveAccount'),
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              ref.tr('login'),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(24),

                      AuthOrDivider(isDark: isDark),
                      const Gap(24),

                      // Social Apple/Google Row
                      Row(
                        children: [
                          Expanded(
                            child: AuthSocialButton(
                              isDark: isDark,
                              onTap: () {
                                // apple auth placeholder
                              },
                              label: ref.tr('apple'),
                              icon: Icon(
                                Icons.apple_rounded,
                                color: isDark ? Colors.white : Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: AuthSocialButton(
                              isDark: isDark,
                              onTap: _isLoading ? null : _onGoogleSignIn,
                              label: ref.tr('google'),
                              icon: const AuthGoogleLogo(size: 20),
                            ),
                          ),
                        ],
                      ),
                      const Gap(32),

                      // Terms & Conditions Policy
                      AuthTermsText(isDark: isDark, isSignUp: true),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}