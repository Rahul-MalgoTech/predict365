// lib/PredictScreens/AuthScreens/View/otp_verify_screen.dart

import 'package:flutter/material.dart';
import 'package:predict365/ViewModel/authVM.dart';
import 'package:provider/provider.dart';
import 'package:predict365/PredictScreens/BottomNavScreen/BottomNavScreen.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  static const _gold1 = Color(0xFF977032);
  static const _gold2 = Color(0xFFF5A623);

  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── Verify ────────────────────────────────────────────────────
  Future<void> _verify() async {
    if (_otpCode.length < 6) {
      // show inline via ViewModel error
      context.read<AuthViewModel>().clearStatus();
      // trigger a manual error display
      setState(() {});
      _showError('Please enter all 6 digits.');
      return;
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.verifyAccount(
      email: widget.email,
      otp: _otpCode,
    );

    if (!mounted) return;

    if (success) {
      // ✅ Clear entire stack and go to main app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationPage()),
            (route) => false,
      );
    }
    // Error displayed via Consumer below
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── OTP field change handler ──────────────────────────────────
  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  // ── Resend OTP ────────────────────────────────────────────────
  Future<void> _resend() async {
    // TODO: call your resend OTP API when backend provides it
    // e.g. POST /auth/resend-otp { email }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('OTP resent to ${widget.email}'),
      backgroundColor: const Color(0xFF977032),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 22),
              ),

              const SizedBox(height: 36),

              // Icon
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_gold1, _gold2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _gold2.withOpacity(0.3),
                        blurRadius: 16, offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mark_email_read_outlined,
                      color: Colors.white, size: 36),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: AppText("Verify Your Email",
                    fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Center(
                child: AppText(
                  "We sent a 6-digit OTP to\n${widget.email}",
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 36),

              // ── 6 OTP BOXES ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, _buildOtpBox),
              ),

              const SizedBox(height: 16),

              // ── ERROR from ViewModel ──
              Consumer<AuthViewModel>(
                builder: (_, vm, __) {
                  if (vm.status != AuthStatus.error) return const SizedBox.shrink();
                  return Container(
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
                  );
                },
              ),

              const SizedBox(height: 28),

              // ── VERIFY BUTTON ──
              Consumer<AuthViewModel>(
                builder: (_, vm, __) => GestureDetector(
                  onTap: vm.isLoading ? null : _verify,
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
                          blurRadius: 12, offset: const Offset(0, 5),
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
                        : const Text("Verify & Continue",
                        style: TextStyle(
                          color: Colors.white, fontSize: 17,
                          fontWeight: FontWeight.w700, letterSpacing: 0.3,
                        )),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── RESEND ──
              Center(
                child: GestureDetector(
                  onTap: _resend,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText("Didn't receive the code? ",
                          color: Colors.black54, fontSize: 14),
                      Text("Resend",
                          style: TextStyle(
                            color: _gold2, fontSize: 14,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 46, height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87,
        ),
        onChanged: (v) => _onChanged(v, index),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isFilled ? _gold2 : const Color(0xFFE5E5E5),
              width: isFilled ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _gold2, width: 2),
          ),
          filled: true,
          fillColor: isFilled ? _gold2.withOpacity(0.06) : Colors.white,
        ),
      ),
    );
  }
}