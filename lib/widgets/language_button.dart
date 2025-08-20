import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем Builder, чтобы PopupMenuButton получил *активный* контекст
    return Builder(
      builder: (menuContext) {
        return PopupMenuButton<String>(
          tooltip: 'Language',
          icon: const Icon(Icons.language, color: Colors.white),
          onSelected: (value) {
            // Берём сервис без подписки — безопасно
            final loc = Provider.of<LocalizationService>(context, listen: false);
            loc.setLocale(value);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'uz', child: Text("Oʻzbekcha")),
            PopupMenuItem(value: 'ru', child: Text("Русский")),
            PopupMenuItem(value: 'en', child: Text("English")),
          ],
        );
      },
    );
  }
}