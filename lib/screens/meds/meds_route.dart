import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
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
      onToggle: (id, index) => scope.setMeds(
        (list) => [
          for (final m in list)
            if (m.id == id)
              m.copyWith(
                times: [
                  for (final (i, t) in m.times.indexed)
                    if (i == index) t.copyWith(taken: !t.taken) else t,
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
      onDelete: (id) => scope.setMeds((list) => list.where((m) => m.id != id).toList()),
    );
  }
}
