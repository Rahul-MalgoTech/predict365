import 'package:flutter/material.dart';
import 'package:predict365/PredictScreens/HomeScreens/HomeView.dart';
import 'package:predict365/PredictScreens/ProfileScreens/profileView.dart';
import 'package:predict365/PredictScreens/ProtfolioScreens/portfolioView.dart';
import 'package:predict365/PredictScreens/RankingScreens/RankingView.dart';
import 'package:predict365/PredictScreens/ReferralScreens/RefferalView.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';


class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {

  int selectedIndex = 0;

  final pages = [
    const HomeScreen(),
    const RankingScreen(),
    const ReferEarnScreen(),
    const PortfolioScreen(),
    const ProfileScreen(nav: false,),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[selectedIndex],

      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Container(
            height: 70,
            decoration:  BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                bottomItem(0,"assets/images/predicthome.png","Explore"),
                bottomItem(1,"assets/images/rank.png","Ranking"),
                bottomItem(2,"assets/images/refer.png","Referral"),
                bottomItem(3,"assets/images/port.png","Portfolio"),
                bottomItem(4,"assets/images/profile.png","Me"),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomItem(int index,String icon,String title){

    bool isSelected = selectedIndex == index;

    return GestureDetector(

      onTap: (){
        setState(() {
          selectedIndex = index;
        });
      },

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            icon,
            height: 24,
            width: 24,
            color: isSelected ? Theme.of(context).colorScheme.surfaceBright : Colors.grey.shade600,
          ),

          const SizedBox(height: 5),

          AppText(
            title,

              fontSize: 13,
              color: isSelected ? Theme.of(context).colorScheme.surfaceBright : Colors.grey.shade600,
              fontWeight: FontWeight.w500,

          )

        ],
      ),
    );
  }
}