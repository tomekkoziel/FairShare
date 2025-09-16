import 'package:fair_share/common/widgets/texts/section_heading.dart';
import 'package:fair_share/features/authentication/screens/logout/logout_screen.dart';
import 'package:fair_share/features/authentication/screens/remove/remove_account_confirm_screen.dart';
import 'package:fair_share/features/personalization/screens/widgets/profile_widgets.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:fair_share/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';

enum Currency { pln, eur, usd, jpy, gbp }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Currency _selectedCurrency = Currency.pln;

  String _currencySymbol(Currency c) {
    switch (c) {
      case Currency.pln:
        return 'zł';
      case Currency.eur:
        return '€';
      case Currency.usd:
        return '\$';
      case Currency.jpy:
        return '¥';
      case Currency.gbp:
        return '£';
    }
  }

  String _currencyLabel(Currency c) {
    switch (c) {
      case Currency.pln:
        return 'Zloty (PLN)';
      case Currency.eur:
        return 'Euro (EUR)';
      case Currency.usd:
        return 'Dollar (USD)';
      case Currency.jpy:
        return 'Yen (JPY)';
      case Currency.gbp:
        return 'Pound (GBP)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TSectionHeading(title: 'Profile Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              const ProfileMenuWidgetWithoutButton(title: 'UserID', value: 'XWmraD4HtUoolJgeJbKk'),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'Username', value: 'JKowalski01', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'First Name', value: 'Jan', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'Last Name', value: 'Kowalski', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'Email', value: 'jan.kowalski@gmail.com', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'Phone', value: '012345678', onPress: () {}),

              const SizedBox(height: TSizes.spaceBtwSections),
              TSectionHeading(title: 'Expense Summary', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              // ---- Total Expenses row with currency picker ----
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total Expenses',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '0',
                          style: Theme.of(context).textTheme.bodyMedium,
                          softWrap: false,
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100, // narrow: just the currency symbol
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Currency>(
                              value: _selectedCurrency,
                              isExpanded: true, // fill the 44px box
                              isDense: true,
                              iconSize: 18,
                              onChanged: (c) => setState(() => _selectedCurrency = c!),
                              items: Currency.values.map((c) {
                                return DropdownMenuItem<Currency>(
                                  value: c,
                                  child: Text(_currencyLabel(c)), // full label in the menu
                                );
                              }).toList(),
                              // only the symbol is shown when closed -> keeps the button tiny
                              selectedItemBuilder: (_) => Currency.values.map((c) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _currencySymbol(c),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => LogoutScreen()),
                child: const Text(TTexts.logOut),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TextButton(
              onPressed: () => Get.to(() => RemoveAccountConfirmScreen()),
              child: const Text(
                'Remove Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
