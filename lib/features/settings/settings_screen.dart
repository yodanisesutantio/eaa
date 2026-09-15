import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Choose how the app should present your data.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            _SettingSection(
              label: 'Appearance',
              child: DropdownButtonFormField<String>(
                initialValue: settings.appearance,
                decoration: const InputDecoration(),
                items: AppSettings.supportedAppearances.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) settings.setAppearance(value);
                },
              ),
            ),
            const SizedBox(height: 16),
            _SettingSection(
              label: 'Language',
              child: DropdownButtonFormField<String>(
                initialValue: settings.languageCode,
                decoration: const InputDecoration(),
                items: AppSettings.supportedLanguages.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) settings.setLanguage(value);
                },
              ),
            ),
            const SizedBox(height: 16),
            _SettingSection(
              label: 'Default currency',
              child: DropdownButtonFormField<String>(
                initialValue: settings.currencyCode,
                decoration: const InputDecoration(),
                items: AppSettings.supportedCurrencies.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text('${entry.key} · ${entry.value}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) settings.setCurrency(value);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'The default currency is preselected when adding a transaction. You can still choose a different currency for each transaction.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
