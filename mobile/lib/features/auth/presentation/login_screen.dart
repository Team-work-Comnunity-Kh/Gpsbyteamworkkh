import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const Expanded(
                flex: 2,
                child: _Header(),
              ),
              // Form card
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ចូលគណនី',
                            style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text('SmartGPS — ប្រព័ន្ធ GPS ស្មាតសម្រាប់ប្រជាជន',
                            style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 28),

                          // Identifier
                          TextFormField(
                            controller: _identifierCtrl,
                            decoration: const InputDecoration(
                              labelText: 'អ៊ីម៉ែល ឬ លេខទូរសព្ទ',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'សូមបញ្ចូលអ៊ីម៉ែល ឬ លេខទូរសព្ទ' : null,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'ពាក្យសម្ងាត់',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.length < 6 ? 'ពាក្យសម្ងាត់ត្រូវ >= 6 អក្សរ' : null,
                          ),

                          // Login button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('ចូល'),
                          ),

                          const SizedBox(height: 16),

                          // Register link
                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/auth/register'),
                              child: RichText(
                                text: TextSpan(
                                  text: 'មិនទាន់មានគណនី? ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: 'ចុះឈ្មោះឥឡូវ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).login(
            _identifierCtrl.text.trim(),
            _passwordCtrl.text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _configureServer() async {
    final service = ref.read(authServiceProvider);
    final controller = TextEditingController(text: service.dio.options.baseUrl.replaceFirst(RegExp(r'/api$'), ''));
    final value = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('API server'),
      content: TextField(controller: controller, keyboardType: TextInputType.url,
        decoration: const InputDecoration(labelText: 'Server URL', hintText: 'https://api.example.com',
          helperText: 'Release builds require HTTPS; local HTTP works in debug builds.')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
      ],
    ));
    controller.dispose();
    if (value == null) return;
    try {
      await service.setApiUrl(value);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server saved')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.gps_fixed, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 12),
        const Text(
          'SmartGPS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ប្រព័ន្ធ GPS ស្មាត',
          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
        ),
      ],
    );
  }
}
