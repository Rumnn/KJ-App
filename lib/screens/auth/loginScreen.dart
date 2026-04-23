import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../providers/authProvider.dart';
import '../../services/authService.dart';
import '../../widgets/errorBanner.dart';
import '../../appTheme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = AuthService.handleError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'KJ',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.onBackground)),
                const SizedBox(height: 4),
                const Text('Sign In To Continue Your Kanji Journey', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v == null || !v.contains('@') ? 'Enter A Valid Email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 Characters' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  ErrorBanner(message: _error!),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _loading 
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't Have An Account? ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.push('/auth/signup'),
                      child: const Text('Sign Up', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}