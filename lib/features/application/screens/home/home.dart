import 'package:fair_share/features/application/screens/home/widgets/feature_item.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:fair_share/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header image
            Image.asset(
              "assets/logos/fair_share_splash.png",
              height: 220,
              fit: BoxFit.contain,
            ),
            // const SizedBox(height: TSizes.spaceBtwSections),

            // Title
            Text(TTexts.homeTitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Description
            Text(TTexts.appDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Features header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(TTexts.keyFeatures,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Features list
            const FeatureItem(text: TTexts.featureOne),
            const FeatureItem(text: TTexts.featureTwo),
            const FeatureItem(text: TTexts.featureThree),
            const FeatureItem(text: TTexts.featureFour),
            const FeatureItem(text: TTexts.featureFive),
            // const FeatureItem(text: TTexts.featureSix), // OCR feature not implemented yet

            const SizedBox(height: TSizes.spaceBtwSections),

            // Small hint text
            Text(TTexts.hintText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Centered arrow pointing down
            const Icon(
              Icons.keyboard_arrow_down,
              size: TSizes.imageThumbSize,
              color: Colors.lightBlueAccent,
            ),
          ],
        ),
      ),
    );
  }
}