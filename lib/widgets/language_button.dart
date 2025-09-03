import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';  // Для addPostFrameCallback, на всякий случай

import '../services/localization_service.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      // Контроллер для открытия/закрытия меню
      builder: (context, controller, child) {
        return IconButton(
          icon: const Icon(Icons.language),
          tooltip: 'Language',
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      // Дети меню — кнопки для языков
      menuChildren: [
        MenuItemButton(
          child: const Text("Oʻzbekcha"),
          onPressed: () {
            // Откладываем на следующий кадр для безопасности
            SchedulerBinding.instance.addPostFrameCallback((_) {
              final loc = Provider.of<LocalizationService>(context, listen: false);
              loc.setLocale('uz');
            });
          },
        ),
        MenuItemButton(
          child: const Text("Русский"),
          onPressed: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              final loc = Provider.of<LocalizationService>(context, listen: false);
              loc.setLocale('ru');
            });
          },
        ),
        MenuItemButton(
          child: const Text("English"),
          onPressed: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              final loc = Provider.of<LocalizationService>(context, listen: false);
              loc.setLocale('en');
            });
          },
        ),
      ],
    );
  }
}