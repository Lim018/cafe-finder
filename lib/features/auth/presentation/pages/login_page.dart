import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_logo.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  String? _inlineError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _inlineError = null);
    context.read<AuthBloc>().add(LoginRequested(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          setState(() => _inlineError = state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  _Header(),

                  // ── Form ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error banner
                        if (_inlineError != null)
                          _ErrorBanner(message: _inlineError!),

                        // Email field
                        _FieldLabel('Email'),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'nama@email.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email wajib diisi';
                            if (!v.contains('@')) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Password field
                        _FieldLabel('Password'),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36)),
                            child: Text('Lupa password?',
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(color: cs.primary)),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Login button
                        AppButton(
                          label: 'Masuk',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun? ',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: Text('Daftar',
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A553C), Color(0xFF5A3E2B)],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const AppLogo.mark(size: 38),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Selamat datang 👋',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text('Masuk untuk lanjut menjelajah',
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withOpacity(0.78))),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text,
            style: AppTypography.textTheme.labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.error.withOpacity(0.08),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: cs.error.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.error_outline_rounded, color: cs.error, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child: Text(message,
                style: AppTypography.textTheme.bodySmall
                    ?.copyWith(color: cs.error))),
      ]),
    );
  }
}
