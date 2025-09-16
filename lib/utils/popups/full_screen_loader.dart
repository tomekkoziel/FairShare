import 'package:fair_share/utils/constants/colors.dart';
import 'package:fair_share/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenLoader {
  static void openLoadingDialog(String message) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: THelperFunctions.isDarkMode(Get.context!) ? TColors.dark : TColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message, style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none, // ensures no underline
                ),
              ),
            ],
          ),
        )
      )
    );
  }

  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}