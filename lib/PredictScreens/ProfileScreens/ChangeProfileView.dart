// lib/PredictScreens/ProfileScreens/ChangeProfileView.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/AuthStorage/authStorage.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:provider/provider.dart';

void showChangeProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UserViewModel>(),
      child: const _ChangeProfileSheet(),
    ),
  );
}

class _ChangeProfileSheet extends StatefulWidget {
  const _ChangeProfileSheet();

  @override
  State<_ChangeProfileSheet> createState() => _ChangeProfileSheetState();
}

class _ChangeProfileSheetState extends State<_ChangeProfileSheet> {
  bool _isUploading = false;
  String? _errorMsg;

  Future<void> _pickAndUpload() async {
    // 1. Pick image from gallery
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _isUploading = true;
      _errorMsg    = null;
    });

    try {
      final file = File(picked.path);
      final api  = NetworkApiService();
      final String? token = await AuthStorage.instance.getToken();

      // 2. Upload to /upload with multipart
      final uploadResponse = await api.uploadImageMultipart(
        endpoint:  '/upload',
        imageFile: file,
        fieldName: 'file',
        additionalFields: {'path': 'profile/images'},
        token: token
      );

      if (!mounted) return;

      final imageUrl = uploadResponse['data']?['url'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('No URL in upload response');
      }

      // 3. PATCH /users/me to save the new profile_image URL
      await api.putResponse(
        '/users/me',
        body: {'profile_image': imageUrl},
      );

      if (!mounted) return;

      // 4. Update UserViewModel so all screens refresh instantly
      await context.read<UserViewModel>().fetchMe();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _errorMsg    = 'Upload failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg      = Theme.of(context).scaffoldBackgroundColor.withOpacity(0.99);
    final divider = Theme.of(context).dividerColor;
    final user    = context.watch<UserViewModel>().user;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize:     0.35,
      maxChildSize:     0.6,
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
                          color: Theme.of(context).iconTheme.color,
                          size: 22),
                    ),
                    const Spacer(),
                    AppText('Change profile picture',
                        fontSize: 18, fontWeight: FontWeight.w600),
                    const Spacer(),
                    const SizedBox(width: 22),
                  ],
                ),
              ),

              Divider(color: divider, height: 1),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  children: [

                    // ── Current avatar preview ──
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF977032), Color(0xFFF5A623)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.transparent,
                          backgroundImage: (user?.profileImage != null &&
                              user!.profileImage!.isNotEmpty)
                              ? NetworkImage(user.profileImage!)
                          as ImageProvider
                              : const AssetImage(
                              'assets/images/myprofile.png'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Error message ──
                    if (_errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppText(_errorMsg!,
                                    fontSize: 13, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20,),

                    // ── Upload button ──
                    GestureDetector(
                      onTap: _isUploading ? null : _pickAndUpload,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isUploading
                              ? Colors.grey.shade700
                              : Theme.of(context).primaryColorDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 4), // shadow position
                            ),
                          ],

                        ),
                        child: _isUploading
                            ? const Center(
                          child: SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Theme.of(context).textTheme.displayLarge!.color, size: 20),
                            const SizedBox(width: 10),
                            AppText('Upload from gallery',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.displayLarge!.color),
                          ],
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
    );
  }
}