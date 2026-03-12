import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  static const List<Map<String, dynamic>> _chats = [
    {
      'name': 'Customer Service',
      'lastMessage': '[language card]',
      'time': '20:03',
      'avatarText': 'Robot\nAvatar',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final txt    = isDark ? Colors.white : Colors.black87;
    final sub    = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final div    = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.99),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  ThemeToggleIcon(),
                  const SizedBox(width: 14),
                  GestureDetector(
                      onTap: (){
                        predictNavigator.backPage(context);
                      },

                      child: Icon(Icons.close, color: txt, size: 24)),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: div),

            // ── Chat list ──
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _chats.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, thickness: 1, indent: 80, color: div),
                itemBuilder: (context, i) {
                  final chat = _chats[i];
                  return _ChatTile(
                    name: chat['name'],
                    lastMessage: chat['lastMessage'],
                    time: chat['time'],
                    avatarText: chat['avatarText'],
                    isDark: isDark,
                    txt: txt,
                    sub: sub,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single chat row ──────────────────────────────────────────────
class _ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarText;
  final bool isDark;
  final Color txt;
  final Color sub;

  const _ChatTile({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarText,
    required this.isDark,
    required this.txt,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final avatarBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0);

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: avatarBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  avatarText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: sub,
                    height: 1.3,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: txt,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage,
                    style: TextStyle(fontSize: 13, color: sub),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time
            Text(
              time,
              style: TextStyle(fontSize: 12, color: sub),
            ),
          ],
        ),
      ),
    );
  }
}