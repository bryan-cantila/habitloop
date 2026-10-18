import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme.dart';

/// habits store an index into [habitIcons] (see theme.dart).

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

/// Habits: add / edit / delete (with confirm) / archive.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final active = provider.activeHabits;
    final archived = provider.archivedHabits;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          const Text(
            'Habits',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.inkTealDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${active.length} active',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.inkTeal.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          for (final habit in active)
            _HabitRow(habit: habit, archived: false),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Archived (${archived.length})',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.inkTeal.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            for (final habit in archived)
              _HabitRow(habit: habit, archived: true),
          ],
          const SizedBox(height: 24),
          Center(
            child: Text(
              'HabitLoop · Created by devuvo',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.inkTeal.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final Habit habit;
  final bool archived;

  const _HabitRow({required this.habit, required this.archived});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HabitProvider>();
    final accent = Color(habit.colorValue);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Icon(
            habitIcons[habit.iconIndex],
            color: accent,
          ),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.inkTealDeep,
          ),
        ),
        subtitle: Text(
          habit.weeklyTarget >= 7
              ? 'Daily${habit.reminderLabel != null ? ' · ${habit.reminderLabel}' : ''}'
              : '${habit.weeklyTarget}x per week${habit.reminderLabel != null ? ' · ${habit.reminderLabel}' : ''}',
          style: TextStyle(
            color: AppTheme.inkTeal.withValues(alpha: 0.65),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.inkTeal),
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                _showHabitSheet(context, existing: habit);
                break;
              case 'archive':
                await provider.setArchived(habit.id, !archived);
                break;
              case 'delete':
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete habit?'),
                    content: Text(
                      '"${habit.name}" and its history will be removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Keep'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteHabit(habit.id);
                }
                break;
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'archive',
              child: Text(archived ? 'Unarchive' : 'Archive'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

/// Add / edit sheet used by both the FAB and the Habits screen.
Future<void> showAddHabitSheet(BuildContext context) =>
    _showHabitSheet(context);

Future<void> _showHabitSheet(BuildContext context, {Habit? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
      ),
      child: _HabitForm(existing: existing),
    ),
  );
}

class _HabitForm extends StatefulWidget {
  final Habit? existing;

  const _HabitForm({this.existing});

  @override
  State<_HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<_HabitForm> {
  late final TextEditingController _name;
  late int _iconIndex;
  late int _colorIndex;
  late int _weeklyTarget;
  TimeOfDay? _reminder;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _iconIndex = e?.iconIndex ?? 0;
    if (_iconIndex < 0 || _iconIndex >= habitIcons.length) _iconIndex = 0;
    _colorIndex = e == null
        ? 0
        : AppTheme.habitColors
            .indexWhere((c) => c.toARGB32() == e.colorValue);
    if (_colorIndex < 0) _colorIndex = 0;
    _weeklyTarget = e?.weeklyTarget ?? 7;
    final rm = e?.reminderMinutes;
    _reminder = rm == null
        ? null
        : TimeOfDay(hour: rm ~/ 60, minute: rm % 60);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HabitProvider>();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null ? 'New habit' : 'Edit habit',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.inkTealDeep,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'Read 20 pages',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          const Text('Icon',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < habitIcons.length; i++)
                ChoiceChip(
                  label: Icon(habitIcons[i], size: 20),
                  selected: _iconIndex == i,
                  onSelected: (_) => setState(() => _iconIndex = i),
                  selectedColor: AppTheme.leafLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Color',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              for (var i = 0; i < AppTheme.habitColors.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _colorIndex = i),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.habitColors[i],
                      shape: BoxShape.circle,
                      border: _colorIndex == i
                          ? Border.all(
                              color: AppTheme.inkTealDeep, width: 3)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Days per week',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                _weeklyTarget >= 7 ? 'Daily' : '$_weeklyTarget×',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.inkTeal,
                ),
              ),
            ],
          ),
          Slider(
            value: _weeklyTarget.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            activeColor: AppTheme.inkTeal,
            onChanged: (v) =>
                setState(() => _weeklyTarget = v.round()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined,
                color: AppTheme.inkTeal),
            title: const Text('Daily reminder'),
            subtitle: Text(_reminder == null
                ? 'Off'
                : _reminder!.format(context)),
            trailing: _reminder == null
                ? TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        setState(() => _reminder = picked);
                      }
                    },
                    child: const Text('Set'),
                  )
                : TextButton(
                    onPressed: () =>
                        setState(() => _reminder = null),
                    child: const Text('Clear'),
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.inkTeal,
                foregroundColor: AppTheme.cream,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                final name = _name.text.trim();
                if (name.isEmpty) return;
                final reminderMinutes = _reminder == null
                    ? null
                    : _reminder!.hour * 60 + _reminder!.minute;
                if (widget.existing == null) {
                  await provider.addHabit(Habit(
                    id: _newId(),
                    name: name,
                    iconIndex: _iconIndex,
                    colorValue:
                        AppTheme.habitColors[_colorIndex].toARGB32(),
                    weeklyTarget: _weeklyTarget,
                    reminderMinutes: reminderMinutes,
                    createdAt: DateTime.now(),
                  ));
                } else {
                  await provider.updateHabit(
                    widget.existing!.copyWith(
                      name: name,
                      iconIndex: _iconIndex,
                      colorValue:
                          AppTheme.habitColors[_colorIndex].toARGB32(),
                      weeklyTarget: _weeklyTarget,
                      reminderMinutes: reminderMinutes,
                      clearReminder: _reminder == null,
                    ),
                  );
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                  widget.existing == null ? 'Add habit' : 'Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}
