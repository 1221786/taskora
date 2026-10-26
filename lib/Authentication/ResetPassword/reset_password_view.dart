import 'package:flutter/material.dart';
import 'package:taskora/Authentication/ResetPassword/reset_password_viewmodel.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _email = TextEditingController();
  late final ResetPasswordViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ResetPasswordViewModel()..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    viewModel.removeListener(_refresh);
    viewModel.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final sent = await viewModel.sendResetLink(_email.text);

    if (!mounted) return;

    final message = sent ? viewModel.successMessage : viewModel.errorMessage;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF30B0C7);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4B5D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: viewModel.isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 56,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: _card(teal),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(Color teal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24344F5A),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [teal.withValues(alpha: .72), teal],
              ),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Reset Your Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF103B4A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter the email address associated with your account. '
            'We will send you a link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF63747B),
            ),
          ),
          const SizedBox(height: 26),
          _field(
            controller: _email,
            hint: 'johndoe@gmail.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 22),
          _button('Send Reset Link', teal, _sendResetLink),
          const SizedBox(height: 12),
          TextButton(
            onPressed: viewModel.isLoading
                ? null
                : () => Navigator.pop(context),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: Color(0xFF0C4B5D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFEAF0F2),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30B0C7), width: 1.5),
        ),
      ),
      onSubmitted: (_) {
        if (!viewModel.isLoading) {
          _sendResetLink();
        }
      },
    );
  }

  Widget _button(String label, Color teal, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [teal.withValues(alpha: .7), teal, const Color(0xFF45C4D3)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: teal.withValues(alpha: .28),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: viewModel.isLoading ? null : action,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: viewModel.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                  ),
                ),
        ),
      ),
    );
  }
}
