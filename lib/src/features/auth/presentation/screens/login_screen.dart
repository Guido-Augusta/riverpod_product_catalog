import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:product_catalog_app/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:product_catalog_app/src/features/auth/presentation/controllers/auth_state.dart';
import 'package:product_catalog_app/src/widgets/custom_text_field.dart';
import 'package:product_catalog_app/src/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    ref
        .read(authControllerProvider.notifier)
        .login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is Unauthenticated && next.message != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      next.message!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: colorScheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          SizedBox(height: 54),
                          Center(
                            child: Lottie.asset(
                              'assets/animations/Login.json',
                              width: 300,
                            ),
                          ),
                          SizedBox(height: 44),
                          // Title
                          Text(
                            'Login',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Please enter your credentials',
                            style: textTheme.bodySmall,
                          ),
                          SizedBox(height: 26),
                          // Form
                          CustomTextField(
                            controller: _usernameController,
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            textInputAction: TextInputAction.done,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 26),
                          // Login button
                          PrimaryButton(
                            text: 'Login',
                            isLoading: isLoading,
                            onPressed: () => _handleLogin(),
                          ),
                          const Spacer(),
                          // Footer (copyright)
                          Center(
                            child: Text(
                              '© 2026 PT. Cahaya Teknologi Indonesia',
                              style: textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
