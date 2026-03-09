import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int mainTab = 0;
  int filterIndex = 0;
  DateTime selectedDate = DateTime(2026, 3, 1);

  final List<Map<String, dynamic>> transactions = [
    {
      'status': 'Pending',
      'title': 'Deposit from UPI wallet',
      'amount': '+₹500.00',
      'date': 'March 6, 2026 at 04:07 PM',
      'txnId': 'DT YN2026030616070012',
      'isCredit': true,
    },
  ];

  String get selectedLabel =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}';

  List<String> get filterChips {
    if (mainTab == 0) return ['ALL', 'Credit', 'Debit'];
    return ['ALL', 'Sucess', 'Pending', 'Failed'];
  }

  List<String> get mainTabs => ['Account', 'Recharge', 'Withdraw'];

  void _openDatePicker(BuildContext context, bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          )
              : ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color, size: 22),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Transfers',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700,color: isDark ? Colors.white : Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),

            // ── MAIN TABS + DATE PICKER BUTTON ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: mainTabs.asMap().entries.map((e) {
                        final isActive = mainTab == e.key;
                        return GestureDetector(
                          onTap: () => setState(() {
                            mainTab = e.key;
                            filterIndex = 0;
                          }),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 14, top: 4, bottom: 8),
                                child: Text(
                                  e.value,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: isActive
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                height: 2,
                                width: 60,
                                color: isDark ? Colors.white : Colors.black),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── DATE PICKER BUTTON ──
                  GestureDetector(
                    onTap: () => _openDatePicker(context, isDark),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14,
                              color: isDark ? Colors.white70 : Colors.black54),
                          const SizedBox(width: 5),
                          Text(
                            selectedLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.keyboard_arrow_down,
                              size: 15,
                              color: isDark ? Colors.white70 : Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),

            // ── FILTER CHIPS ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: filterChips.asMap().entries.map((e) {
                  final isSelected = filterIndex == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => filterIndex = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : (isDark ? Colors.grey[700]! : Colors.grey[350]!),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.green
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ── CONTENT ──
            Expanded(
              child: mainTab == 0
                  ? _buildEmpty(isDark)
                  : _buildTransactionList(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ──────────────────────────────────────────────────
  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── TRANSACTION LIST ─────────────────────────────────────────────
  Widget _buildTransactionList(BuildContext context, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (context, index) {
        final t = transactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t['status'],
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(t['title'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        )),
                  ),
                  Text(t['amount'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      )),
                ],
              ),
              const SizedBox(height: 4),
              Text(t['date'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(t['txnId'],
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.copy_outlined,
                      size: 14, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}