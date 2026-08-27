import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/meds.dart';
import 'meds_screen.dart';

/// The medication screen wired to the app's own list.
///
/// A thin wrapper rather than passing the list down: the screen is opened from
/// the home card and from settings, and threading four callbacks through both
/// entry points is how the two drift apart.
///
/// It lives beside the screen it wires, not in `main.dart`: a settings screen
/// that has to import the app's entry point to open a sibling is a dependency
/// pointing the wrong way round.
class MedsRoute extends StatelessWidget {
  const MedsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return MedsScreen(
      meds: scope.meds,
      onToggle: (id, at) => scope.setMeds(
        (list) => [
          for (final m in list)
            if (m.id == id)
              m.copyWith(
                times: [
                  for (final t in m.times)
                    if (t.at == at) t.copyWith(taken: !t.taken) else t,
                ],
              )
            else
              m,
        ],
      ),
      onSave: (med) => scope.setMeds(
        (list) => list.any((m) => m.id == med.id)
            ? [
                for (final m in list)
                  if (m.id == med.id) med else m,
              ]
            : [...list, med],
      ),
      /* Закінчення курсу це дата, а не зникнення.
       *
       * Раніше препарат просто випадав зі списку, і разом з ним із застосунку
       * зникав увесь курс: розділ «Минулі» читає той самий список, тому туди
       * він теж не потрапляв.
       *
       * Останній день курсу це день, у який людина натиснула кнопку. У списку
       * препаратів курс закривається одразу, разом зі сповіщеннями, а в
       * щоденнику сьогоднішній день лишається днем курсу: дози, відмічені
       * зранку, не мають зникати ввечері. */
      onFinish: (id) => scope.setMeds((list) => finishCourse(list, id)),

      /* Помилково заведений курс можна повернути.
       *
       * Кнопка стоїть поруч із закінченням і потрібна рівно для промаху: без неї
       * одне випадкове натискання не відкотити нічим, крім заведення препарату
       * наново, а це вже інший курс і розірвана історія. */
      onRevive: (id) => scope.setMeds((list) => reviveCourse(list, id)),
    );
  }
}
