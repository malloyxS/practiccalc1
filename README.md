# Калькулятор и конвертер (Flutter Web)

Практическая работа 1: маршрутизация, формы и URL как состояние.

## Запуск

```bash
flutter pub get
flutter run -d chrome --web-port=5555
```

Если `flutter build web` падает на записи шейдеров, в пути к папке есть кириллица. Сборка проходит через диск без кириллицы:

```bat
subst Z: "%USERPROFILE%\Desktop\учебка"
cd /d Z:\calc_web
flutter build web
```

Приложение открывается без решётки в адресе: `/calculator`, а не `/#/calculator`.

## Проверки

```bash
flutter analyze
flutter test
flutter build web
```

## Маршруты

| Адрес | Экран |
|---|---|
| `/` | Главная |
| `/calculator` | Форма калькулятора |
| `/calculator/result?a=&op=&b=` | Результат вычисления |
| `/converter` | Форма конвертера |
| `/converter/result?from=&to=&amount=` | Результат конвертации |
| любой неизвестный | Страница 404 |

Экран результата читает только query-параметры адреса: прямое открытие ссылки в новой вкладке работает так же, как переход из формы.
