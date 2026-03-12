// lib/PredictScreens/LoginScreens/LoginView.dart

import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/CustomSnackBar/StatusMessage.dart';
import 'package:predict365/ViewModel/authVM.dart';
import 'package:provider/provider.dart';
import 'package:predict365/PredictScreens/BottomNavScreen/BottomNavScreen.dart';
import 'package:predict365/PredictScreens/RegisterScreens/RegisterView.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _gold1       = Color(0xFF977032);
  static const _gold2       = Color(0xFFF5A623);
  static const _borderColor = Color(0xFFE5E5E5);
  static const _hintColor   = Color(0xFFBBBBBB);

  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  // separate loading state for Google (to not conflict with form loading)
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Email/Password Login ──────────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final success = await vm.login(
      email:    _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      _navigateToHome();
    } else {
      Utils.snackBarErrorMessage(vm.errorMessage, context);
    }
  }

  // ── Google Login ──────────────────────────────────────────────
  // Future<void> _googleLogin() async {
  //   final vm = context.read<AuthViewModel>();
  //   setState(() => _googleLoading = true);
  //
  //   final success = await vm.loginWithGoogle();
  //
  //   if (!mounted) return;
  //   setState(() => _googleLoading = false);
  //
  //   if (success) {
  //     _navigateToHome();
  //   } else {
  //     print("${vm.errorMessage}");
  //     Utils.snackBarErrorMessage(vm.errorMessage, context);
  //   }
  // }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          (route) => false,
    );
  }

  void _goToRegister() {
    context.read<AuthViewModel>().clearStatus();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── BANNER ───────────────────────────────────────────
          Image.asset(
            "assets/images/circketbanner.png",
            width: double.infinity,
            height: sh * 0.42,
            fit: BoxFit.cover,
          ),

          // ── FORM CARD ────────────────────────────────────────
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        Center(child: AppText("Log in", fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black)),
                        const SizedBox(height: 6),
                        Center(child: AppText("Welcome back to Predict365", fontSize: 14, color: Colors.grey.shade500)),

                        const SizedBox(height: 24),

                        // ── EMAIL ──
                        _fieldLabel("Email Address"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => context.read<AuthViewModel>().clearStatus(),
                          validator: (v) => context.read<AuthViewModel>().validateEmail(v),
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                          decoration: _inputDecoration(hint: "Enter your email address", icon: Icons.email_outlined),
                        ),

                        const SizedBox(height: 16),

                        // ── PASSWORD ──
                        _fieldLabel("Password"),
                        const SizedBox(height: 6),
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) => TextFormField(
                            controller: _passwordController,
                            obscureText: !vm.passwordVisible,
                            onChanged: (_) => vm.clearStatus(),
                            validator: (v) => vm.validatePassword(v),
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                            decoration: _inputDecoration(
                              hint: "Enter your password",
                              icon: Icons.lock_outline,
                              suffixIcon: GestureDetector(
                                onTap: vm.togglePasswordVisibility,
                                child: Icon(
                                  vm.passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: _hintColor, size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── FORGOT PASSWORD ──
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () { /* TODO: forgot password */ },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text("Forgot password?",
                                style: TextStyle(color: _gold2, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── SIGN IN BUTTON ──
                        Consumer<AuthViewModel>(
                          builder: (_, vm, __) => GestureDetector(
                            onTap: vm.isLoading ? null : _login,
                            child: Container(
                              height: 54,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [_gold1, _gold2],
                                    begin: Alignment.centerLeft, end: Alignment.centerRight),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: _gold2.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5))],
                              ),
                              alignment: Alignment.center,
                              child: vm.isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : const Text("Sign in", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── OR DIVIDER ──
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("OR", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ── GOOGLE LOGIN BUTTON ──
                        // GestureDetector(
                        //   onTap: _googleLoading ? null : _googleLogin,
                        //   child: Container(
                        //     height: 54,
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(14),
                        //       border: Border.all(color: _borderColor, width: 1.5),
                        //       boxShadow: [
                        //         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                        //       ],
                        //     ),
                        //     alignment: Alignment.center,
                        //     child: _googleLoading
                        //         ? SizedBox(
                        //         width: 22, height: 22,
                        //         child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.grey.shade400))
                        //         : Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         // Google "G" icon
                        //         Container(
                        //           width: 24, height: 24,
                        //           decoration: const BoxDecoration(shape: BoxShape.circle),
                        //           child: Image.asset(
                        //             'assets/images/google_icon.png',
                        //             width: 24, height: 24,
                        //             errorBuilder: (_, __, ___) => const _GoogleIcon(),
                        //           ),
                        //         ),
                        //         const SizedBox(width: 10),
                        //         Text("Continue with Google",
                        //             style: TextStyle(
                        //               color: Colors.grey.shade800,
                        //               fontSize: 15,
                        //               fontWeight: FontWeight.w600,
                        //             )),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(height: 20),

                        // ── REGISTER LINK ──
                        Center(
                          child: GestureDetector(
                            onTap: _goToRegister,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText("Don't have an account? ", color: Colors.black54, fontSize: 16),
                                GradientAppText(text: "Register", fontSize: 18, fontWeight: FontWeight.w700),
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

  Widget _fieldLabel(String label) => Text(label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54));

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hintColor, fontSize: 15, fontWeight: FontWeight.w500),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold2, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade300)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// ── Fallback Google G icon (if no asset) ──────────────────────────
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: const Text("G",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
    );
  }
}