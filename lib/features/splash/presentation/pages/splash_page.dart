import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 1.06, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.9, curve: Curves.easeOut)));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.read<AuthBloc>().add(CheckAuthStatus());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is Unauthenticated) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF4A3122),
        body: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/SpecialCoffeeSplash.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
