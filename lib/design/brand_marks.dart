import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Знаки провайдерів входу: Google і Apple.
///
/// Контури ті самі, що в демці (`GoogleMark.tsx` і `AppleMark.tsx`), обидва в
/// системі координат 24 на 24. Це чужі знаки, і перемальовувати їх під свою
/// палітру не можна: кольори Google задані числами і не міняються в темряві,
/// бо саме такими їх упізнають і саме такими їх вимагають правила Google.
///
/// Яблуко навпаки одноколірне і бере колір тексту поруч: у самої Apple воно
/// монохромне і має контрастувати з тлом, на якому лежить.
///
/// Малюються з рядка SVG, а не з файлів у `assets`: два знаки по кілька рядків
/// кожен не варті ні запису в маніфест, ні окремого читання з диска.

const _google =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="#4285F4" d="M21.6 12.2c0-.7-.1-1.4-.2-2H12v3.8h5.4a4.6 4.6 0 0 1-2 3v2.5h3.2c1.9-1.7 3-4.3 3-7.3z"/>'
    '<path fill="#34A853" d="M12 22c2.7 0 5-.9 6.6-2.5l-3.2-2.5c-.9.6-2 1-3.4 1-2.6 0-4.8-1.7-5.6-4.1H3.1v2.6A10 10 0 0 0 12 22z"/>'
    '<path fill="#FBBC05" d="M6.4 13.9a6 6 0 0 1 0-3.8V7.5H3.1a10 10 0 0 0 0 9l3.3-2.6z"/>'
    '<path fill="#EA4335" d="M12 5.9c1.5 0 2.8.5 3.8 1.5l2.8-2.8A10 10 0 0 0 3.1 7.5l3.3 2.6C7.2 7.6 9.4 5.9 12 5.9z"/>'
    '</svg>';

const _apple =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="currentColor" d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.53 4.08zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>'
    '</svg>';

/// Знак Google: чотири кольори, задані самим Google.
class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.string(_google, width: size, height: size);
}

/// Знак Apple: одноколірний, бере колір тексту поруч із собою.
class AppleMark extends StatelessWidget {
  const AppleMark({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    _apple,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(
      color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000),
      BlendMode.srcIn,
    ),
  );
}
