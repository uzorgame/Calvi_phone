import 'package:flutter/material.dart';

import '../../data/workout.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'slot_card.dart';
import 'workout_form.dart';

/// Training.
///
/// Sessions on top, then a way to add one. Burned calories go back into the
/// day's norm, which is why the card's figure is negative: it is what the day
/// gave back, not another thing that was spent.
class WorkoutCard extends StatefulWidget {
  const WorkoutCard({
    super.key,
    required this.workouts,
    required this.onAdd,
    required this.open,
    required this.onToggle,
  });

  final List<Workout> workouts;
  final ValueChanged<Workout> onAdd;
  final bool open;
  final VoidCallback onToggle;

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool _picking = false;
  Activity? _picked;

  String _plural(int n) {
    if (n == 0) return 'нічого не записано';
    if (n == 1) return '1 сесія';
    return n < 5 ? '$n сесії' : '$n сесій';
  }

  void _save(Activity a, {required int minutes, required int kcal, String? note}) {
    widget.onAdd(
      Workout(
        id: 'w-${a.key}-${widget.workouts.length}',
        activity: a.key,
        // The note rides in the title rather than in a field of its own: a
        // workout is a line in a list, and a second line under it for «Ноги,
        // важко» would push every session down for the sake of a few.
        title: note == null ? a.label : '${a.label} · $note',
        minutes: minutes,
        kcal: kcal,
        time: '18:40',
      ),
    );
    setState(() {
      _picked = null;
      _picking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final burned = widget.workouts.fold<int>(0, (s, w) => s + w.kcal);

    return SlotCard(
      icon: 'gym',
      title: 'Тренування',
      sub: _plural(widget.workouts.length),
      badge: burned > 0 ? '−$burned ккал' : '0 ккал',
      open: widget.open,
      onToggle: widget.onToggle,
      child: Column(
        children: [
          for (final w in widget.workouts) _WorkoutRow(workout: w),
          if (_picked != null)
            WorkoutForm(
              activity: _picked!,
              onCancel: () => setState(() => _picked = null),
              onSave: ({required minutes, required kcal, note}) =>
                  _save(_picked!, minutes: minutes, kcal: kcal, note: note),
            )
          else ...[
            AddRow(
              label: _picking ? 'Згорнути' : 'Додати тренування',
              open: _picking,
              onTap: () => setState(() => _picking = !_picking),
            ),
            if (_picking) _Picker(onPick: (a) => setState(() => _picked = a)),
          ],
        ],
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
            child: CalviIcon(workout.activity, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title, style: context.t.bodyLarge?.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  workout.minutes > 0 ? '${workout.minutes} хв' : 'без тривалості',
                  style: context.t.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Green, and negative: this is the one number on the day that
              // moves the norm the right way.
              Text(
                '−${workout.kcal}',
                style: context.t.titleMedium?.copyWith(color: c.success),
              ),
              Text(workout.time, style: context.t.labelSmall?.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The grid of activities.
class _Picker extends StatelessWidget {
  const _Picker({required this.onPick});

  final ValueChanged<Activity> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    /* Three across in a bordered card of their own: each activity is an icon
       in the shared circle over an 11px label, exactly the day's own grammar. */
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 4),
      decoration: BoxDecoration(
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
      ),
      child: Column(
        children: [
          for (var row = 0; row * 3 < activities.length; row++)
            Row(
              children: [
                for (var i = row * 3; i < row * 3 + 3; i++)
                  i < activities.length
                      ? Expanded(
                          child: _Act(activity: activities[i], onPick: onPick),
                        )
                      : const Expanded(child: SizedBox()),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('Оберіть активність або скажіть Норі', style: context.t.labelSmall),
          ),
        ],
      ),
    );
  }
}

/// One activity in the grid: the shared icon circle over an 11px label.
class _Act extends StatelessWidget {
  const _Act({required this.activity, required this.onPick});

  final Activity activity;
  final ValueChanged<Activity> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: () => onPick(activity),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.iconCircle),
              child: CalviIcon(activity.key, size: 22),
            ),
            const SizedBox(height: 7),
            Text(
              activity.label,
              textAlign: TextAlign.center,
              style: context.t.labelSmall?.copyWith(fontSize: 11, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
