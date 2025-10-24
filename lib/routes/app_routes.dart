import 'package:flutter/material.dart';

// ===== Screens =====
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_choice_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/detail/detail_property_screen.dart';
import '../screens/saved/saved_empty_screen.dart';
import '../screens/saved/saved_filled_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/show_profile_screen.dart';
import '../screens/profile/faq_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/search/filter_screen.dart';
import '../screens/navbar/bottom_navbar.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String loginChoice = '/login_choice';
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';
  static const String home = '/home';
  static const String detailProperty = '/detail_property';
  static const String savedEmpty = '/saved_empty';
  static const String savedFilled = '/saved_filled';
  static const String profile = '/profile';
  static const String showProfile = '/show_profile';
  static const String faq = '/faq';
  static const String search = '/search';
  static const String filter = '/filter';
  static const String navbar = '/navbar';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    loginChoice: (context) => const LoginChoiceScreen(),
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
    // home: (context) => const HomeScreen(),
    // detailProperty: (context) => const DetailPropertyScreen(),
    // savedEmpty: (context) => const SavedEmptyScreen(),
    // savedFilled: (context) => const SavedFilledScreen(),
    // profile: (context) => const ProfileScreen(),
    // showProfile: (context) => const ShowProfileScreen(),
    // faq: (context) => const FAQScreen(),
    // search: (context) => const SearchScreen(),
    // filter: (context) => const FilterScreen(),
    // navbar: (context) => const BottomNavbar(),
  };
}
