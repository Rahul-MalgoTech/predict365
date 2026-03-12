// lib/PredictScreens/ProfileScreens/ProfileSettingsSheet.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:predict365/AuthStorage/authStorage.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:provider/provider.dart';

void showProfileSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UserViewModel>(),
      child: const _ProfileSettingsSheet(),
    ),
  );
}

class _ProfileSettingsSheet extends StatefulWidget {
  const _ProfileSettingsSheet();

  @override
  State<_ProfileSettingsSheet> createState() => _ProfileSettingsSheetState();
}

class _ProfileSettingsSheetState extends State<_ProfileSettingsSheet> {
  final _nameCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl      = TextEditingController();

  bool    _isSaving = false;
  String? _errorMsg;
  String? _successMsg;

  @override
  void initState() {
    super.initState();
    // Pre-fill from UserViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserViewModel>().user;
      if (user != null) {
        _nameCtrl.text     = user.name;
        _usernameCtrl.text = user.username;
        _bioCtrl.text      = user.bio ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() {
      _isSaving   = true;
      _errorMsg   = null;
      _successMsg = null;
    });

    try {
      final token = await AuthStorage.instance.getToken();
      const baseUrl = 'https://staging-api.predict365.com/api';

      final response = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type':  'application/json',
          'Accept':        'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name':     _nameCtrl.text.trim(),
          'username': _usernameCtrl.text.trim(),
          'bio':      _bioCtrl.text.trim(),
        }),
      );

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (!mounted) return;

      if (decoded['success'] == true) {
        // Refresh UserViewModel so all screens update
        await context.read<UserViewModel>().fetchMe();
        if (!mounted) return;
        setState(() {
          _isSaving   = false;
          _successMsg = 'Profile updated successfully!';
        });
        // Auto-close after short delay
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _isSaving = false;
          _errorMsg = decoded['message'] as String? ?? 'Update failed.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMsg = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final bg      = theme.scaffoldBackgroundColor.withOpacity(0.99);
    final divider = theme.dividerColor;
    final cardBg  = theme.primaryColorDark;

    return Padding(
      // Lift sheet above keyboard
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.45,
        maxChildSize: 0.75,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [

                // ── Drag handle ──
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: theme.iconTheme.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      AppText('Profile Details',
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ],
                  ),
                ),

                Divider(color: divider, height: 1),

                // ── Scrollable body ──
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [

                      // subtitle
                      AppText(
                        'Keep your public profile fresh and accurate.',
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(height: 20),

                      // ── NAME + USERNAME row ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NAME
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('NAME'),
                                const SizedBox(height: 6),
                                _inputField(
                                  controller: _nameCtrl,
                                  hint: 'Your name',
                                  prefixIcon: Icons.person_outline,
                                  cardBg: cardBg,
                                  divider: divider,
                                  context: context,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // USERNAME
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('USERNAME'),
                                const SizedBox(height: 6),
                                _inputField(
                                  controller: _usernameCtrl,
                                  hint: 'Username',
                                  prefixIcon: Icons.alternate_email,
                                  cardBg: cardBg,
                                  divider: divider,
                                  context: context,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── BIO ──
                      _label('BIO'),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: divider),
                        ),
                        child: TextField(
                          controller: _bioCtrl,
                          maxLines:   5,
                          minLines:   4,
                          maxLength:  200,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.iconTheme.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tell something about yourself...',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 12),
                              child: Icon(Icons.description_outlined,
                                  color: Colors.grey.shade500, size: 18),
                            ),
                            prefixIconConstraints:
                            const BoxConstraints(minWidth: 0),
                            border:      InputBorder.none,
                            counterStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 11),
                            contentPadding: const EdgeInsets.fromLTRB(
                                12, 14, 12, 8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Feedback banners ──
                      if (_errorMsg != null)
                        _banner(
                          _errorMsg!,
                          color: Colors.red,
                          icon: Icons.error_outline,
                        ),

                      if (_successMsg != null)
                        _banner(
                          _successMsg!,
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),

                      const SizedBox(height: 8),

                      // ── Save button ──
                      GestureDetector(
                        onTap: _isSaving ? null : _saveChanges,
                        child: GradientContainer(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              child: _isSaving
                                  ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : AppText(
                                'Save Changes',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _label(String text) => AppText(
    text,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).textTheme.labelLarge!.color,
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required Color cardBg,
    required Color divider,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divider),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
            fontSize: 15, color: Theme.of(context).iconTheme.color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          TextStyle(color: Colors.grey.shade500, fontSize: 14),

          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _banner(String msg,
      {required Color color, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border:
          Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
                child:
                AppText(msg, fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}