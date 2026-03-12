// lib/PredictScreens/AuthScreens/View/register_screen.dart

import 'package:flutter/material.dart';
import 'package:predict365/PredictScreens/RegisterScreens/OtpVerifyScreen.dart';
import 'package:predict365/ViewModel/authVM.dart';
import 'package:provider/provider.dart';

import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _gold1       = Color(0xFF977032);
  static const _gold2       = Color(0xFFF5A623);
  static const _borderColor = Color(0xFFE5E5E5);
  static const _hintColor   = Color(0xFFBBBBBB);

  final _formKey              = GlobalKey<FormState>();
  final _emailController      = TextEditingController();
  final _usernameController   = TextEditingController();
  final _passwordController   = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AuthViewModel>();
    final success = await vm.register(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(email: _emailController.text.trim()),
        ),
      );
    }
    // Error is shown via Consumer in the UI
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── BANNER ──
          Stack(
            children: [
              Image.asset(
                "assets/images/circketbanner.png",
                width: double.infinity,
                height: sh * 0.32,
                fit: BoxFit.cover,
              ),
              // Back button
              Positioned(
                top: 44,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),

          // ── FORM CARD ──
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4)),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        // Title
                        Center(
                          child: AppText("Create Account",
                              fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: AppText("Join Predict365 and start winning",
                              fontSize: 14, color: Colors.grey.shade500),
                        ),

                        const SizedBox(height: 24),

                        // ── USERNAME ──
                        _fieldLabel("Username"),
                        const SizedBox(height: 6),
                        _buildField(
                          controller: _usernameController,
                          hint: "Enter your name",
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.text,
                          validator: (v) => context.read<AuthViewModel>().validateUsername(v),
                        ),

                        const SizedBox(height: 14),

                        // ── EMAIL ──
                        _fieldLabel("Email Address"),
                        const SizedBox(height: 6),
                        _buildField(
                          controller: _emailController,
                          hint: "Enter your gmail",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => context.read<AuthViewModel>().validateEmail(v),
                        ),

                        const SizedBox(height: 14),

                        // ── PASSWORD ──
                        _fieldLabel("Password"),
                        const SizedBox(height: 6),
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) => _buildField(
                            controller: _passwordController,
                            hint: "Min 8 chars, 1 upper, 1 number",
                            icon: Icons.lock_outline,
                            obscure: !vm.passwordVisible,
                            suffixIcon: GestureDetector(
                              onTap: vm.togglePasswordVisibility,
                              child: Icon(
                                vm.passwordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _hintColor, size: 20,
                              ),
                            ),
                            validator: (v) => context.read<AuthViewModel>().validatePassword(v),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── CONFIRM PASSWORD ──
                        _fieldLabel("Confirm Password"),
                        const SizedBox(height: 6),
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) => _buildField(
                            controller: _confirmPassController,
                            hint: "Re-enter your password",
                            icon: Icons.lock_outline,
                            obscure: !vm.confirmPasswordVisible,
                            suffixIcon: GestureDetector(
                              onTap: vm.toggleConfirmPasswordVisibility,
                              child: Icon(
                                vm.confirmPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _hintColor, size: 20,
                              ),
                            ),
                            validator: (v) => context.read<AuthViewModel>()
                                .validateConfirmPassword(v, _passwordController.text),
                          ),
                        ),

                        // ── ERROR BOX ──
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) {
                            if (vm.status != AuthStatus.error) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(vm.errorMessage,
                                          style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 22),

                        // ── REGISTER BUTTON ──
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) => GestureDetector(
                            onTap: vm.isLoading ? null : _onRegister,
                            child: Container(
                              height: 54,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_gold1, _gold2],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold2.withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: vm.isLoading
                                  ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                                  : const Text("Create Account",
                                  style: TextStyle(
                                    color: Colors.white, fontSize: 17,
                                    fontWeight: FontWeight.w700, letterSpacing: 0.3,
                                  )),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── LOGIN LINK ──
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText("Already have an account? ",
                                    color: Colors.black54, fontSize: 16),
                                GradientAppText(
                                  text: "Log in",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field Builder ─────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _hintColor, fontSize: 14),
        // prefixIcon: Icon(icon, color: _hintColor, size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 14,horizontal: 6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
  );
}