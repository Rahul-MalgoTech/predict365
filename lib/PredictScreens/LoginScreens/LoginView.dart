import 'package:flutter/material.dart';
import 'package:predict365/PredictScreens/BottomNavScreen/BottomNavScreen.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/Gradient_App_Text/Gradient_AppText.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isMobileLogin = true;

  static const _gold1 = Color(0xFF977032);
  static const _gold2 = Color(0xFFF5A623);
  static const _borderColor = Color(0xFFE5E5E5);
  static const _hintColor = Color(0xFFBBBBBB);

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── BANNER IMAGE ──
          Stack(
            children: [
              Image.asset(
                "assets/images/circketbanner.png",
                width: double.infinity,
                height: sh * 0.42,
                fit: BoxFit.cover,
              ),
            ],
          ),

          // ── BOTTOM SHEET ──
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 18),

                      // ── TITLE ──
                      Center(
                        child: AppText(
                          "Log in",
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── LOGIN TABS ──
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _tabBtn("Mobile Login", isMobileLogin, () => setState(() => isMobileLogin = true)),
                            const SizedBox(width: 36),
                            _tabBtn("Email Login", !isMobileLogin, () => setState(() => isMobileLogin = false)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── PHONE FIELD ──
                      _fieldLabel("Phone Number"),
                      const SizedBox(height: 6),
                      _inputBox(
                        child: Row(
                          children: [
                            AppText("🇮🇳", fontSize: 18),
                            const SizedBox(width: 6),
                            AppText("+91", fontSize: 15, color: _hintColor),
                            const Icon(Icons.arrow_drop_down, color: _hintColor, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter phone number",
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: _hintColor,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── OTP FIELD ──
                      _fieldLabel("OTP"),
                      const SizedBox(height: 6),
                      _inputBox(
                        child: Row(
                          children: [
                            const Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter OTP",
                                  hintStyle: TextStyle(
                                      color: _hintColor, fontSize: 15),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_gold1, _gold2],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "GET OTP",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── INVITATION CODE ──
                      _fieldLabel("Invitation Code (optional)"),
                      const SizedBox(height: 6),
                      _inputBox(
                        child: const TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter invitation code",
                            hintStyle: TextStyle(color: _hintColor, fontSize: 15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── HELP TEXT ──
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText("Need help? Contact us at ",
                                color: Colors.black54, fontSize: 13),
                            AppText("Telegram",
                                color: _gold2,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ── SIGN IN BUTTON ──
                      GestureDetector(
                        onTap: () {
                          predictNavigator.newPage(context, page: MainNavigationPage());
                        },
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
                                color: _gold2.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
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
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          active
              ? GradientAppText(
            text: label,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          )
              : AppText(label, color: Colors.grey.shade500, fontSize: 15),
          const SizedBox(height: 5),
          if (active)
            Container(
              height: 2,
              width: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_gold1, _gold2]),
                borderRadius: BorderRadius.circular(1),
              ),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
    );
  }

  Widget _inputBox({required Widget child}) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: child,
    );
  }
}