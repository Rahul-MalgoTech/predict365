import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:provider/provider.dart';


// ── DATA MODEL ───────────────────────────────────────────────────
class BettingQuestion {
  final String question;
  final String volume;
  final int probability;
  final String yesLabel;
  final String yesOdds;
  final String noLabel;
  final String noOdds;
  final String tab;

  const BettingQuestion({
    required this.question,
    required this.volume,
    required this.probability,
    required this.yesLabel,
    required this.yesOdds,
    required this.noLabel,
    required this.noOdds,
    required this.tab,
  });
}

// ── SCREEN ───────────────────────────────────────────────────────
class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  String activeTab = 'All';
  int selectedActivityTab = 0;
  bool rulesExpanded = true;

  final List<String> tabs = ['All', 'Winner', 'Toss', 'Total', 'Session', 'Player'];

  final List<BettingQuestion> allQuestions = const [
    BettingQuestion(question: 'Which team will win the match?', volume: '₹55.75 L Vol', probability: 60, yesLabel: 'IND', yesOdds: '₹6.0', noLabel: 'ENG', noOdds: '₹4.0', tab: 'Winner'),
    BettingQuestion(question: 'Toss Winner will Bat or Bowl?', volume: '₹2,51,240.50 Vol', probability: 20, yesLabel: 'BAT', yesOdds: '₹2.0', noLabel: 'BOWL', noOdds: '₹8.0', tab: 'Toss'),
    BettingQuestion(question: 'Which team will win the toss?', volume: '₹17.36L Vol', probability: 55, yesLabel: 'IND', yesOdds: '₹5.5', noLabel: 'ENG', noOdds: '₹4.5', tab: 'Toss'),
    BettingQuestion(question: "Which team will score more 'Fours'?", volume: '₹33,539.00 Vol', probability: 55, yesLabel: 'IND', yesOdds: '₹5.5', noLabel: 'ENG', noOdds: '₹4.5', tab: 'Total'),
    BettingQuestion(question: "Which team will score more 'Sixes'?", volume: '₹12,840.00 Vol', probability: 48, yesLabel: 'IND', yesOdds: '₹4.8', noLabel: 'ENG', noOdds: '₹5.2', tab: 'Total'),
    BettingQuestion(question: 'Total runs in first 6 overs (Powerplay)?', volume: '₹8,200.00 Vol', probability: 52, yesLabel: 'Over', yesOdds: '₹4.9', noLabel: 'Under', noOdds: '₹5.1', tab: 'Session'),
  ];

  List<BettingQuestion> get filteredQuestions {
    if (activeTab == 'All') return allQuestions;
    return allQuestions.where((q) => q.tab == activeTab).toList();
  }

  bool get showWinnerDetail => activeTab == 'Winner';
  int selectedCategory = 0;

  final List<String> categories = ['Trending', 'Cricket', 'Crypto', 'Politics', 'Sports', 'Entertainment'];
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
      body: SafeArea(
        child: Center(
          // On web, cap max width so content doesn't stretch too wide
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SizedBox(height: 12),
                            ...filteredQuestions.map((q) => _buildQuestionCard(context, isDark, q)),
                          ],
                        ),
                      ),
                      if (showWinnerDetail) ...[
                        SizedBox(height: 4),
                        _buildRulesSection(context, isDark),
                        _buildActivitySection(context),
                        SizedBox(height: 24),
                      ],
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

  // ── HEADER ───────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      color: Theme.of(context).primaryColorDark,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color, size: 22),
                ),
                const Spacer(),
                AppText('IND vS ENG', fontWeight: FontWeight.w700, fontSize: 17),
                const Spacer(),
                ThemeToggleIcon(),
              ],
            ),
          ),

          // ── MATCH CARD ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset('assets/images/marketbg.png', fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: isDark
                          ? Color(0XFf1b1d24).withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Column(
                      children: [
                        AppText(
                          '7:00 PM',

                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,

                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // India
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/india.png',
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6),
                                AppText('India',fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white : Colors.black),
                              ],
                            ),
                            // Center
                            Column(
                              children: [
                                AppText('60%-40%', fontWeight: FontWeight.w700, fontSize: 24, ),
                                SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 28, height: 5, decoration: const BoxDecoration(color: Colors.green)),
                                    SizedBox(width: 3),
                                    Container(width: 18, height: 5, decoration: const BoxDecoration(color: Colors.red)),
                                  ],
                                ),
                                SizedBox(height: 6),
                                AppText('₹85.73L Vol',fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
                              ],
                            ),
                            // England
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/england.png',
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6),
                                AppText('England', fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Colors.white : Colors.black),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 14),

          // ── TABS ──
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = activeTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => activeTab = tab),
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? Theme.of(context).textTheme.labelLarge!.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: isActive ? Colors.transparent : Theme.of(context).dividerColor),
                    ),
                    child: AppText(
                      tab,

                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? (isDark ? Colors.black : Colors.white) : Colors.grey,

                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── QUESTION CARD ────────────────────────────────────────────────
  Widget _buildQuestionCard(BuildContext context, bool isDark, BettingQuestion q) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: AppText(q.question, fontWeight: FontWeight.w500, fontSize: 17)),
              SizedBox(width: 8),
              AppText('${q.probability}%', fontWeight: FontWeight.w700, fontSize: 18),
            ],
          ),
          SizedBox(height: 4),
          AppText(q.volume, fontSize: 14, color: Colors.grey),
          SizedBox(height: 12),
          // On tablet/web — buttons get more padding
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: AppText(
                      '${q.yesLabel} ${q.yesOdds}',
                      color: Colors.green, fontWeight: FontWeight.w600, fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: AppText(
                      '${q.noLabel} ${q.noOdds}',
                      color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── RULES SECTION ────────────────────────────────────────────────
  Widget _buildRulesSection(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => rulesExpanded = !rulesExpanded),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText('Rules', fontSize: 15, fontWeight: FontWeight.bold),
                  Icon(rulesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (rulesExpanded)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'The event will be settled after the tournament ends.\nThe event will settle on the winning team from the above mentioned teams',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── ACTIVITY SECTION ─────────────────────────────────────────────
  Widget _buildActivitySection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['Activity', 'Holders', 'Comments'].asMap().entries.map((e) {
              final isSelected = selectedActivityTab == e.key;
              return GestureDetector(
                onTap: () => setState(() => selectedActivityTab = e.key),
                child: Container(
                  margin: EdgeInsets.only(right: 20),
                  padding: EdgeInsets.only(bottom: 8),
                  decoration: isSelected
                      ? BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).textTheme.labelLarge!.color!, width: 2)))
                      : null,
                  child: AppText(
                    e.value,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? null : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
          SizedBox(height: 8),

          if (selectedActivityTab == 0) _buildActivityTab(context),
          if (selectedActivityTab == 1) _buildHoldersTab(context),
          if (selectedActivityTab == 2) _buildCommentsTab(context),
        ],
      ),
    );
  }

  // ── ACTIVITY TAB ─────────────────────────────────────────────────
  Widget _buildActivityTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: _filterChip(context, 'ALL')),
            SizedBox(width: 10),
            Expanded(child: _filterChip(context, 'Min Amount')),
          ],
        ),
        SizedBox(height: 12),
        _activityItem(context, 'England', '2 shares (₹5.00)', '3m'),
        Divider(color: Theme.of(context).dividerColor),
        _activityItem(context, 'England', '2 shares (₹5.00)', '3m'),
      ],
    );
  }

  // ── HOLDERS TAB ──────────────────────────────────────────────────
  Widget _buildHoldersTab(BuildContext context) {
    final yesHolders = [
      {'name': 'User755622', 'shares': '13,900 shares'},
      {'name': 'Thorfinn', 'shares': '2,000 shares'},
      {'name': 'KK Bhai', 'shares': '685 shares'},
      {'name': 'User589265', 'shares': '586 shares'},
      {'name': 'Amit Kumar 23', 'shares': '555 shares'},
      {'name': 'Shyam', 'shares': '460 shares'},
      {'name': 'User000110', 'shares': '383 shares'},
      {'name': 'User853136', 'shares': '379 shares'},
    ];
    final noHolders = [
      {'name': 'No fear', 'shares': '16,075 shares'},
      {'name': 'User145921', 'shares': '2,872 shares'},
      {'name': 'User387361', 'shares': '2,450 shares'},
      {'name': 'User716300', 'shares': '2,100 shares'},
      {'name': 'Jaybhole29', 'shares': '805 shares'},
      {'name': 'User931129', 'shares': '786 shares'},
      {'name': 'User247896', 'shares': '625 shares'},
      {'name': 'User048981', 'shares': '536 shares'},
    ];

    return Column(
      children: [
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              AppText('India', fontSize: 16),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade500),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(children: [
          SizedBox(width: 44),
          Expanded(child: AppText('Yes holders', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
          Expanded(child: AppText('No holders', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
        ]),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: yesHolders.asMap().entries
                    .map((e) => _buildHolderItem(context, rank: e.key + 1, name: e.value['name']!, shares: e.value['shares']!, isYes: true))
                    .toList(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                children: noHolders.asMap().entries
                    .map((e) => _buildHolderItem(context, rank: e.key + 1, name: e.value['name']!, shares: e.value['shares']!, isYes: false))
                    .toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHolderItem(BuildContext context, {required int rank, required String name, required String shares, required bool isYes}) {
    final color = isYes ? Colors.green : Colors.red;
    final radius = 22.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: radius,
                backgroundColor: Theme.of(context).primaryColorDark,
                child: Icon(Icons.person, size: radius * 1.1, color: Colors.grey.shade500),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 14, fontWeight: FontWeight.w600),
                SizedBox(height: 2),
                AppText(shares, fontSize: 13, color: color, fontWeight: FontWeight.w500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── COMMENTS TAB ─────────────────────────────────────────────────
  Widget _buildCommentsTab(BuildContext context) {
    final comments = [
      {'user': 'No fear', 'position': 'No', 'team': 'India', 'isYes': false, 'text': 'Buy yes india win', 'time': '1d', 'bgColor': 0xFF1a1a2e},
      {'user': 'User925016', 'position': 'No Position', 'team': 'Nezland', 'isYes': null, 'text': 'Nezland', 'time': '2d', 'bgColor': 0xFFe67e22},
      {'user': 'User606151', 'position': 'Yes', 'team': 'India', 'isYes': true, 'text': 'Yes india', 'time': '2d', 'bgColor': 0xFF3498db},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              TextField(
                maxLines: 4,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppText('800 left', fontSize: 12, color: Colors.grey),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Post', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        ...comments.map((c) => _buildCommentItem(context, c)),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCommentItem(BuildContext context, Map<String, dynamic> comment) {
    final isYes = comment['isYes'];
    final position = comment['position'] as String;
    final team = comment['team'] as String;
    final bgColor = Color(comment['bgColor'] as int);
    final avatarSize = 38.0;

    Color chipColor;
    Color chipTextColor;
    if (isYes == true) { chipColor = Colors.green.withValues(alpha: 0.15); chipTextColor = Colors.green; }
    else if (isYes == false) { chipColor = Colors.red.withValues(alpha: 0.15); chipTextColor = Colors.red; }
    else { chipColor = Colors.grey.withValues(alpha: 0.15); chipTextColor = Colors.grey; }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(
                (comment['user'] as String).substring(0, 2).toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  AppText(comment['user'] as String, fontSize: 13, fontWeight: FontWeight.w600),
                  Spacer(),
                  AppText(comment['time'] as String, fontSize: 11, color: Colors.grey),
                ]),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(4)),
                  child: AppText('$position · $team', fontSize: 11, color: chipTextColor, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 6),
                AppText(comment['text'] as String, fontSize: 13),
                SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey.shade500),
                  SizedBox(width: 16),
                  Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade500),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(label, fontSize: 14),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _activityItem(BuildContext context, String team, String shares, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Sold Yes · ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
                AppText(team, fontSize: 13, fontWeight: FontWeight.w600),
              ]),
              SizedBox(height: 2),
              AppText(shares, fontSize: 12, color: Colors.grey),
            ],
          ),
          AppText(time, fontSize: 12, color: Colors.grey),
        ],
      ),
    );
  }
}