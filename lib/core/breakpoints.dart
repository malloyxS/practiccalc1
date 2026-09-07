import 'package:flutter/material.dart';

/// 360 — телефон, 768 — планшет, 1280+ — стол, 1920 — широкий стол.
enum ScreenSize { phone, tablet, desktop }

ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return ScreenSize.phone;
  if (width < 1024) return ScreenSize.tablet;
  return ScreenSize.desktop;
}

bool isPhone(BuildContext context) => screenSizeOf(context) == ScreenSize.phone;

bool isTablet(BuildContext context) =>
    screenSizeOf(context) == ScreenSize.tablet;

bool isDesktop(BuildContext context) =>
    screenSizeOf(context) == ScreenSize.desktop;

/// Карточки на 360 и 768, таблицы с 1280.
bool useCardList(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 1024;

/// Старое имя: узкий список карточками.
bool isCompact(BuildContext context) => useCardList(context);

bool useBottomNav(BuildContext context) => isPhone(context);

bool useExtendedRail(BuildContext context) => isDesktop(context);

int homeColumns(BuildContext context) => isPhone(context) ? 1 : 2;

const double contentMaxWidth = 1280;
