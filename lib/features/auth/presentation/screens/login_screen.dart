import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_lang.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('settings');
    _rememberMe = box.get('remember_me', defaultValue: true) as bool;
    if (_rememberMe) {
      _emailController.text = box.get('remembered_email', defaultValue: '') as String;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final box = Hive.box('settings');
      await box.put('remember_me', _rememberMe);
      if (_rememberMe) {
        await box.put('remembered_email', _emailController.text.trim());
      } else {
        await box.delete('remembered_email');
      }

      await ref.read(authStateProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
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
      final box = Hive.box('settings');
      await box.put('remember_me', _rememberMe);
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
                        ref.tr('welcomeBack'),
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
                        ref.tr('accessSecureWallet'),
                        style: text.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 14.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(36),

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
                            return null;
                          },
                        ),
                      ),
                      const Gap(16),

                      // Remember Me Checkbox
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: isDark ? Colors.white30 : Colors.black26,
                            ),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                checkColor: Colors.white,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? false;
                                  });
                                },
                              ),
                            ),
                          ),
                          const Gap(10),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: Text(
                              ref.tr('rememberMe'),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(24),

                      // Login Button
                      AuthPrimaryButton(
                        label: ref.tr('login'),
                        isLoading: _isLoading,
                        onTap: _isLoading ? null : _onLogin,
                      ),
                      const Gap(16),

                      // Sign Up navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ref.tr('dontHaveAccount'),
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: Text(
                              ref.tr('signup'),
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
                      AuthTermsText(isDark: isDark, isSignUp: false),
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