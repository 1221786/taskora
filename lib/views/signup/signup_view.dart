import 'package:flutter/material.dart';
import 'package:taskora/core/theme/app_colors.dart';
class TaskoraSignupView extends StatefulWidget {
  const TaskoraSignupView({super.key});

  @override
  State<TaskoraSignupView> createState() => _TaskoraSignupViewState();
}

class _TaskoraSignupViewState extends State<TaskoraSignupView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();
   

  bool obscurePassword = true;

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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height -
                  MediaQuery.paddingOf(context).vertical,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 45),

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

                  const SizedBox(height: 15),

                  // Logo
                  Image.asset(
                    'assets/images/taskora_logo.png',
                    width: 95,
                    height: 95,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 42),

                  // Name
                  _NeumorphicSignupField(
                    controller: nameController,
                    hintText: 'Name',
                    prefixIcon: Icons.person_outline_rounded,
                    suffixIcon: Icons.check_rounded,
                  ),

                  const SizedBox(height: 18),

                  // Email
                  _NeumorphicSignupField(
                    controller: emailController,
                    hintText: 'Email Address',
                    prefixIcon: Icons.mail_outline_rounded,
                    suffixIcon: Icons.check_rounded,
                  ),

                  const SizedBox(height: 18),

                  // Password
                  _NeumorphicSignupField(
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

const SizedBox(height: 18),

// Confirm Password
_NeumorphicSignupField(
  controller: confirmPasswordController,
  hintText: 'Confirm Password',
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
                  const SizedBox(height: 30),

                  // Sign Up Button
                  _GradientSignupButton(
                    onPressed: () {},
                  ),

                  const SizedBox(height: 30),

                  // Log In
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF68758A),
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Log In',
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

                  const SizedBox(height: 24),

                  // Home Indicator
                  Container(
                    width: 110,
                    height: 4,
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


/// Neumorphic Sign Up Text Field
class _NeumorphicSignupField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final VoidCallback? onSuffixTap;

  const _NeumorphicSignupField({
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
        borderRadius: BorderRadius.circular(22),

        // Thin turquoise outline
        border: Border.all(
          color: const Color(0xFF8ADBD7),
          width: 1.2,
        ),

        // Neumorphic effect
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFFFFFF),
            offset: Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
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
            color: Color(0xFF718096),
          ),
          suffixIcon: suffixIcon == null
              ? null
              : GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(
                    suffixIcon,
                    size: 21,
                    color: Color(0xFF43C7C1),
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


/// Gradient Sign Up Button
class _GradientSignupButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GradientSignupButton({
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
                'Sign Up',
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