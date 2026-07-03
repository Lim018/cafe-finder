import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/config/app_radius.dart';
import '../../../../core/config/app_spacing.dart';
import '../../../../core/config/app_typography.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  int _passStrength = 0;
  String? _inlineError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String v) {
    int strength = 0;
    if (v.length >= 6) strength++;
    if (v.length >= 10) strength++;
    if (RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[0-9]').hasMatch(v)) strength++;
    setState(() => _passStrength = strength);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _inlineError = null);
    context.read<AuthBloc>().add(RegisterRequested(
          name: _nameCtrl.text.trim(),
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
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7A553C), Color(0xFF5A3E2B)],
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      bottom: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        const Spacer(),
                        const Text('Buat akun baru',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text('Gabung & simpan kafe favoritmu',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.78))),
                      ],
                    ),
                  ),

                  // ── Form ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_inlineError != null) _ErrorBanner(message: _inlineError!),

                        // Name
                        _FieldLabel('Nama'),
                        TextFormField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Nama lengkap',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Email
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

                        // Password
                        _FieldLabel('Password'),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          textInputAction: TextInputAction.done,
                          onChanged: _onPasswordChanged,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: 'Min. 6 karakter',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Password strength
                        _PasswordStrengthBar(strength: _passStrength),
                        const SizedBox(height: AppSpacing.xl),

                        // Register button
                        AppButton(
                          label: 'Daftar',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Login link
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Sudah punya akun? ',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text('Masuk',
                                style: AppTypography.textTheme.bodyMedium?.copyWith(
                                    color: cs.primary, fontWeight: FontWeight.w600)),
                          ),
                        ]),
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

class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0–3

  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFE7DDD2),
      Color(0xFFB00020),
      Color(0xFFC2871C),
      Color(0xFF2E8B57),
    ];
    final labels = ['', 'Lemah', 'Sedang', 'Kuat'];

    return Row(children: [
      ...List.generate(3, (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? AppSpacing.xs : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i < strength ? colors[strength] : colors[0],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
      const SizedBox(width: AppSpacing.sm),
      Text(
        strength > 0 ? labels[strength] : '',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: strength > 0 ? colors[strength] : colors[0],
        ),
      ),
    ]);
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
                style: AppTypography.textTheme.bodySmall?.copyWith(color: cs.error))),
      ]),
    );
  }
}
