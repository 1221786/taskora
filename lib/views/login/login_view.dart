import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/core/utils/validators.dart';
import 'package:taskora/form_widget/form_widget.dart';
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

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> login() async {
    // Validate fields
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Start loading
    setState(() {
      isLoading = true;
    });

    // Temporary loading simulation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    // Open dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TaskoraDashboardView()),
    );
  }

  @override
  void dispose() {
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
                  onPressed: () {},
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
                isLoading: isLoading,
                onPressed: login,
              ),

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
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
