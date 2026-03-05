import 'package:flutter/material.dart';
import 'package:predict365/PredictScreens/BottomNavScreen/BottomNavScreen.dart';
import 'package:predict365/PredictScreens/HomeScreens/HomeView.dart';
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          /// TOP IMAGE
          Stack(
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Image.asset(
                  "assets/images/circketbanner.png",
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.45,
                  fit: BoxFit.cover,
                ),
              ),

            ],
          ),

          /// BOTTOM SHEET
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      const SizedBox(height: 15),

                      /// TITLE
                       AppText(
                        "Log in",
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 20),

                      /// LOGIN TABS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isMobileLogin = true;
                              });
                            },
                            child: Column(
                              children: [

                                isMobileLogin
                                    ? const GradientAppText(
                                  text: "Mobile Login",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )
                                    : AppText(
                                  "Mobile Login",
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),




                              ],
                            ),
                          ),

                          const SizedBox(width: 40),

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isMobileLogin = false;
                              });
                            },
                            child: Column(
                              children: [

                                !isMobileLogin
                                    ? const GradientAppText(
                                  text: "Email Login",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )
                                    : AppText(
                                  "Email Login",
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// PHONE FIELD
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [

                             AppText("🇮🇳"),

                            const SizedBox(width: 8),

                             AppText(
                              "+91",
                              fontSize: 16,
                                 color: Color(0XFFc1c1c1)
                            ),

                            const Icon(Icons.arrow_drop_down, color: Color(0XFFc1c1c1),),

                            const SizedBox(width: 10),

                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter Phone Number",
                                  hintStyle: TextStyle(  fontSize: 16,
                                      color: Color(0XFFc1c1c1),fontWeight:
                                      FontWeight.w500
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// OTP FIELD
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [

                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter Otp",
                                    hintStyle: TextStyle(color: Color(0XFFc1c1c1),fontSize: 16,)

                                ),
                              ),
                            ),

                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xffd1963a).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child:  AppText(
                                "GET OTP",
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            )

                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// INVITATION CODE
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Invitation Code",
                              hintStyle: TextStyle(color: Color(0XFFc1c1c1),fontSize: 16,)

                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// HELP TEXT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:  [

                          AppText(
                            "Need help? Contact us at ",
                            color: Colors.black54,
                            fontSize: 14,
                          ),

                          AppText(
                            "Telegram",
                            color: Color(0xffd1963a),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// SIGN IN BUTTON
                      GestureDetector(
                        onTap: (){
                          predictNavigator.newPage(context, page: MainNavigationPage());
                        },
                        child: Container(
                          height: 55,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffd1963a).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child:  AppText(
                            "Sign in",
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                    ],
                  ),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}