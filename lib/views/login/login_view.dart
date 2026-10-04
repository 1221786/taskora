import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
import 'package:taskora/views/signup/signup_view.dart';

import '../dashboard/dashboard_view.dart';
class TaskoraLoginView extends StatefulWidget {
  const TaskoraLoginView({super.key});

  @override
  State<TaskoraLoginView> createState() => _TaskoraLoginViewState();
}

class _TaskoraLoginViewState extends State<TaskoraLoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.paddingOf(context).vertical,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 55),

                  // TASKORA
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

                  // Logo
                  Image.asset(
                    'assets/images/taskora_logo.png',
                    width: 105,
                    height: 105,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 55),

                  // Email
                  _NeumorphicTextField(
                    controller: emailController,
                    hintText: 'Email Address',
                    prefixIcon: Icons.mail_outline_rounded,
                    suffixIcon: Icons.check_rounded,
                  ),

                  const SizedBox(height: 20),

                  // Password
                  _NeumorphicTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: obscurePassword,
                    suffixIcon: obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF53657D),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  _GradientLoginButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskoraDashboardView(),
      ),
    );
  },
),
                 
                 
                  SizedBox(height: size.height * 0.08),

                  // Sign Up
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF68758A),
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const TaskoraSignupView(),
    ),
  );
},
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF35BDB7),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Home Indicator
                  Container(
                    width: 110,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Neumorphic text field
class _NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixTap;

  const _NeumorphicTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.background,

        // Rounded shape
        borderRadius: BorderRadius.circular(22),

        // Thin turquoise outline
        border: Border.all(
          color: const Color(0xFF8ADBD7),
          width: 1.2,
        ),

        // Neumorphic lighting
        boxShadow: const [
          // Soft bright upper/left edge
          BoxShadow(
            color: Color(0xFFFFFFFF),
            offset: Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 1,
          ),

          // Soft darker lower/right edge
          BoxShadow(
            color: Color(0xFFD5DCE4),
            offset: Offset(4, 5),
            blurRadius: 9,
            spreadRadius: 1,
          ),
        ],
      ),

      child: TextField(
        controller: controller,
        obscureText: obscureText,

        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF253858),
        ),

        decoration: InputDecoration(
          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 19,
          ),

          prefixIcon: Icon(
            prefixIcon,
            size: 21,
            color: const Color(0xFF718096),
          ),

          suffixIcon: suffixIcon == null
              ? null
              : GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(
                    suffixIcon,
                    size: 21,
                    color: const Color(0xFF43C7C1),
                  ),
                ),

          hintText: hintText,

          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9AA4B2),
          ),
        ),
      ),
    );
  }
}
/// Gradient login button
class _GradientLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GradientLoginButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF7BE3B1),
              Color(0xFF35C4BD),
              Color(0xFF45BBD9),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4035BDB7),
              offset: Offset(0, 7),
              blurRadius: 14,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
            borderRadius: BorderRadius.circular(22),
            child: const Center(
              child: Text(
                'Log In',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123B48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}