import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const _prefKey = 'app_locale';
  String _locale = 'ru'; // default - русский

  String get locale => _locale;

  final Map<String, Map<String, String>> _translations = {
    'ru': {
      'app_title': 'Hayda',
      'activate_account': 'Активация аккаунта',
      'code_sent_to': 'Код был отправлен на: {email}',
      'activation_code': 'Код активации',
      'confirm': 'Подтвердить',
      'account_activated': 'Аккаунт успешно активирован',
      'invalid_code': 'Неверный код активации',
      'connection_error': 'Ошибка соединения с сервером',
      'cars_map': 'Карта машин',
      'profile': 'Профиль',
      'settings': 'Настройки',
      'payment': 'Оплата',
      'payment_history': 'История оплат',
      'rent_time': 'Время аренды: {min} мин {sec} сек',
      'end_rental': 'Завершить аренду',
      'locate_me': 'Моё местоположение',
      'select_payment_method': 'Выберите способ оплаты',
      'amount': 'Сумма',
      'continue': 'Продолжить',
      'choose_amount': 'Выберите сумму для пополнения:',
      'or_enter_amount': 'Или введите свою сумму:',
      'empty_history': 'История пуста',
      'login_or_register': 'Вход или регистрация',
      'email': 'Email',
      'password': 'Пароль',
      'enter_email_password': 'Введите email и пароль',
      'invalid_credentials': 'Неверный email или пароль',
      'register': 'Зарегистрироваться',
      'no_account': 'Нет аккаунта? Зарегистрироваться',
      'logout': 'Выйти из аккаунта',
      'dark_theme': 'Тёмная тема',
      'select_language': 'Язык',
      'male': 'Мужчина',
      'female': 'Женщина',
      'first_name': 'Имя',
      'last_name': 'Фамилия',
      'phone': 'Телефон',
      'birth_date': 'Дата рождения',
      'registration_error': 'Ошибка регистрации',
      'signin_error': 'Не удалось подключиться к серверу',
      'start': 'Старт',
      'minute_price': '{price} / минута',
      'day_price': '{price} / сутки',
      'show_route': 'Показать маршрут',
      'rent': 'Арендовать',
      'payment_done': 'Оплата {amount} сум через {method} выполнена!',
      'fill_email': 'Введите email',
      'fill_phone': 'Введите телефон',
      'fill_name': 'Введите имя',
      'fill_lastname': 'Введите фамилию',
      'choose_birthdate': 'Выберите дату рождения',
      'fill_password': 'Введите пароль',
      'user_not_found': 'Пользователь не найден',
      'server_error': 'Ошибка сервера: {code}',
    },
    'uz': {
      'app_title': 'Hayda',
      'activate_account': 'Аккаунтни фаоллаштириш',
      'code_sent_to': 'Код юборилди: {email}',
      'activation_code': "Фаоллаштириш коди",
      'confirm': 'Тасдиқлаш',
      'account_activated': "Аккаунт муваффақиятли фаоллаштирилди",
      'invalid_code': "Нотўғри фаоллаштириш коди",
      'connection_error': 'Сервер билан уланишда хатолик',
      'cars_map': "Машиналар харитаси",
      'profile': 'Профил',
      'settings': 'Созламалар',
      'payment': 'Тўлов',
      'payment_history': 'Тўлов тарихи',
      'rent_time': 'Ижара вақти: {min} мин {sec} сек',
      'end_rental': 'Ижарани якунлаш',
      'locate_me': 'Ҳозирги жой',
      'select_payment_method': 'Тўлов усулини танланг',
      'amount': 'Сумма',
      'continue': 'Davom etish',
      'choose_amount': 'Тўлов суммасини танланг:',
      'or_enter_amount': 'Ёки ўз суммани киритинг:',
      'empty_history': 'Тарих бўш',
      'login_or_register': 'Кириш ёки рўйхатдан ўтиш',
      'email': 'Email',
      'password': 'Пароль',
      'enter_email_password': 'Email ва парольни киритинг',
      'invalid_credentials': "Нотўғри email ёки пароль",
      'register': "Рўйхатдан ўтиш",
      'no_account': "Аккаунт йўқми? Рўйхатдан ўтиш",
      'logout': 'Чиқиш',
      'dark_theme': 'Қоронғу тема',
      'select_language': 'Тил',
      'male': 'Эркак',
      'female': 'Аёл',
      'first_name': 'Исм',
      'last_name': 'Фамилия',
      'phone': 'Телефон',
      'birth_date': 'Туғилиш санаси',
      'registration_error': "Рўйхатдан ўтишда хатолик",
      'signin_error': 'Серверга уланиб бўлмади',
      'start': "Бошлаш",
      'minute_price': '{price} / дақиқа',
      'day_price': '{price} / кун',
      'show_route': 'Маршрутни кўрсатиш',
      'rent': 'Ижара олиш',
      'payment_done': '{amount} сум тўланди ({method})!',
      'fill_email': 'Email ни киритинг',
      'fill_phone': 'Телефонни киритинг',
      'fill_name': 'Исмни киритинг',
      'fill_lastname': 'Фамилияни киритинг',
      'choose_birthdate': 'Туғилиш санасини танланг',
      'fill_password': 'Парольни киритинг',
      'user_not_found': 'Фойдаланувчи топилмади',
      'server_error': 'Сервер хато: {code}',
    },
    'en': {
      'app_title': 'Hayda',
      'activate_account': 'Activate account',
      'code_sent_to': 'Code was sent to: {email}',
      'activation_code': 'Activation code',
      'confirm': 'Confirm',
      'account_activated': 'Account activated successfully',
      'invalid_code': 'Invalid activation code',
      'connection_error': 'Connection error',
      'cars_map': 'Cars map',
      'profile': 'Profile',
      'settings': 'Settings',
      'payment': 'Payment',
      'payment_history': 'Payment history',
      'rent_time': 'Rental time: {min} min {sec} sec',
      'end_rental': 'End rental',
      'locate_me': 'My location',
      'select_payment_method': 'Choose payment method',
      'amount': 'Amount',
      'continue': 'Continue',
      'choose_amount': 'Choose amount to top up:',
      'or_enter_amount': 'Or enter custom amount:',
      'empty_history': 'History is empty',
      'login_or_register': 'Login or Register',
      'email': 'Email',
      'password': 'Password',
      'enter_email_password': 'Enter email and password',
      'invalid_credentials': 'Invalid email or password',
      'register': 'Register',
      'no_account': "Don't have account? Register",
      'logout': 'Logout',
      'dark_theme': 'Dark theme',
      'select_language': 'Language',
      'male': 'Male',
      'female': 'Female',
      'first_name': 'First name',
      'last_name': 'Last name',
      'phone': 'Phone',
      'birth_date': 'Birth date',
      'registration_error': 'Registration error',
      'signin_error': 'Failed to connect to server',
      'start': 'Start',
      'minute_price': '{price} / min',
      'day_price': '{price} / day',
      'show_route': 'Show route',
      'rent': 'Rent',
      'payment_done': 'Paid {amount} via {method}!',
      'fill_email': 'Enter email',
      'fill_phone': 'Enter phone',
      'fill_name': 'Enter first name',
      'fill_lastname': 'Enter last name',
      'choose_birthdate': 'Choose birth date',
      'fill_password': 'Enter password',
      'user_not_found': 'User not found',
      'server_error': 'Server error: {code}',
    },
  };

  LocalizationService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString(_prefKey) ?? 'ru';
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale);
    notifyListeners();
  }

  String tr(String key, [Map<String, String>? params]) {
    final map = _translations[_locale] ?? _translations['ru']!;
    var text = map[key] ?? key;
    params?.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }
}
