import 'package:flutter/material.dart';

import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/core/utils/validators.dart';
import 'package:taskora/form_widget/form_widget.dart';
import 'package:taskora/viewmodels/login_viewmodel.dart';
import 'package:taskora/views/signup/signup_view.dart';
import '../dashboard/dashboard_view.dart';

class TaskoraLoginView extends StatefulWidget {
  const TaskoraLoginView({super.key});

  @override
  State<TaskoraLoginView> createState() => _TaskoraLoginViewState();
}

class _TaskoraLoginViewState extends State<TaskoraLoginView> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final LoginViewModel viewModel;

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewModel();
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> login() async {
    // 1. Validate the form
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (viewModel.isLoading) return;

    // 2. Call the ViewModel
    final errorMessage = await viewModel.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    // 3. Show an error if login failed
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    // 4. Navigate only after successful login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TaskoraDashboardView()),
    );
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    // 1. Check email input
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address first.')),
      );
      return;
    }

    // 2. Validate email format
    final emailError = FormValidators.validateEmail(email);

    if (emailError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    if (viewModel.isLoading) return;

    // 3. Call the ViewModel
    final errorMessage = await viewModel.resetPassword(email);

    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists for this email, a password reset email will be sent.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    viewModel.dispose();

    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 55),

              const Text(
                'TASKORA',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 18),

              Image.asset(
                'assets/images/taskora_logo.png',
                width: 105,
                height: 105,
              ),

              const SizedBox(height: 50),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomFormField(
                      controller: emailController,
                      hintText: 'Email Address',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.validateEmail,
                    ),

                    const SizedBox(height: 20),

                    CustomFormField(
                      controller: passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: obscurePassword,
                      suffixIcon: obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      validator: FormValidators.validatePassword,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: viewModel.isLoading ? null : resetPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF53657D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GradientFormButton(
                text: 'Login',
                isLoading: viewModel.isLoading,
                onPressed: login,
              ),

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskoraSignupView(),
                              ),
                            );
                          },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
