import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/shared/widgets/aub_card.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key, required this.preferences});

  final ProfilePreferences preferences;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected;

  static const _options = [
    ('it', AppStrings.languageItalian),
    ('en', AppStrings.languageEnglish),
    ('ru', AppStrings.languageRussian),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.preferences.language;
  }

  Future<void> _select(String code) async {
    await widget.preferences.setLanguage(code);
    setState(() => _selected = code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AubColors.surfaceIvory,
      appBar: AppBar(title: const Text(AppStrings.language)),
      body: ListView(
        padding: const EdgeInsets.all(AubSpacing.margin),
        children: [
          AubCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _options.length; i++) ...[
                  ListTile(
                    title: Text(_options[i].$2, style: AubText.bodyMd),
                    trailing: _selected == _options[i].$1
                        ? const Icon(Icons.check, color: AubColors.burgundy)
                        : null,
                    onTap: () => _select(_options[i].$1),
                  ),
                  if (i < _options.length - 1)
                    const Divider(height: 1, color: AubColors.borderHairline),
                ],
              ],
            ),
          ),
          const SizedBox(height: AubSpacing.md),
          const Text(
            AppStrings.languageLimited,
            style: AubText.bodySm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
