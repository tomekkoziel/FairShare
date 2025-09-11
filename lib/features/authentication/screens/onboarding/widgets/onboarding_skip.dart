import 'package:flutter/material.dart';
import 'package:fair_share/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:fair_share/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: TDeviceUtils.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnBoardingController.instance.skipPage(), 
        child: const Text('Skip'),
      ),
    );
  }
}