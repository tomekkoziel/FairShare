import 'package:fair_share/features/application/screens/home/home.dart';
import 'package:fair_share/features/authentication/screens/login/login.dart';
import 'package:fair_share/utils/constants/colors.dart';
import 'package:fair_share/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: darkMode ? Colors.black : Colors.white,
          indicatorColor: darkMode ? TColors.white.withValues(alpha: 0.1) : TColors.black.withValues(alpha: 0.1),

          destinations: const [
            //Home Button
            NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),

            //Groups Button
            NavigationDestination(icon: Icon(Icons.group_outlined), label: "Groups"),

            //Profile Button
            NavigationDestination(icon: Icon(Icons.person_outline), label: "Profile"),
          ]
        ),
      ),
      body: Obx(
        () => controller.screens[controller.selectedIndex.value],
      )
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [const HomeScreen(), Container(color: Colors.purple,), Container(color: Colors.orange,)]; //const HomeScreen()
}