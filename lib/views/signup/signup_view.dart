import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/core/utils/validators.dart';
import 'package:taskora/form_widget/form_widget.dart';

class TaskoraSignupView extends StatefulWidget {
  const TaskoraSignupView({super.key});

  @override
  State<TaskoraSignupView> createState() => _TaskoraSignupViewState();
}

class _TaskoraSignupViewState extends State<TaskoraSignupView> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> signup() async {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Validation successful. Firebase is not connected yet.'),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              const SizedBox(height: 45),

              const Text(
                'TASKORA',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 15),

              Image.asset(
                'assets/images/taskora_logo.png',
                width: 95,
                height: 95,
              ),

              const SizedBox(height: 35),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomFormField(
                      controller: nameController,
                      hintText: 'Name',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      validator: FormValidators.validateName,
                    ),

                    const SizedBox(height: 18),

                    CustomFormField(
                      controller: emailController,
                      hintText: 'Email Address',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.validateEmail,
                    ),

                    const SizedBox(height: 18),

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

                    const SizedBox(height: 18),

                    CustomFormField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
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
                      validator: (value) {
                        return FormValidators.validateConfirmPassword(
                          value,
                          passwordController.text,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              GradientFormButton(
                text: 'Sign Up',
                isLoading: isLoading,
                onPressed: signup,
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Log In'),
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
