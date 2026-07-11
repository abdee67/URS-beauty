import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceDateTimePicker extends StatefulWidget {
  const ServiceDateTimePicker({super.key});

  @override
  State<ServiceDateTimePicker> createState() => _ServiceDateTimePickerState();
}

class _ServiceDateTimePickerState extends State<ServiceDateTimePicker> {
  late final List<DateTime> _dates;
  late final List<TimeOfDay> _times;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = today;
    _dates = List<DateTime>.generate(
      14,
      (index) => today.add(Duration(days: index)),
    );
    _times = _buildTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final gridHeight = (MediaQuery.of(context).size.height * 0.42)
        .clamp(260.0, 420.0)
        .toDouble();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'When do you need it?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E2420),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final selected = _isSameDay(date, _selectedDate);
                  return _DateChip(
                    label: DateFormat('EEE d').format(date),
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                        if (_selectedTime != null &&
                            _isPastTime(date, _selectedTime!)) {
                          _selectedTime = null;
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Choose a time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF43261D),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: gridHeight,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: _times.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.35,
                ),
                itemBuilder: (context, index) {
                  final time = _times[index];
                  final disabled = _isPastTime(_selectedDate, time);
                  final selected = _selectedTime == time;
                  return _TimeChip(
                    label: MaterialLocalizations.of(
                      context,
                    ).formatTimeOfDay(time),
                    selected: selected,
                    disabled: disabled,
                    onTap: disabled
                        ? null
                        : () => setState(() => _selectedTime = time),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedTime == null ? null : _submit,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Find stylists'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B3F32),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD8C0B5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final time = _selectedTime;
    if (time == null) {
      return;
    }

    Navigator.of(context).pop(
      DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        time.hour,
        time.minute,
      ),
    );
  }

  List<TimeOfDay> _buildTimeSlots() {
    final slots = <TimeOfDay>[];
    const startHour = 8;
    const endHour = 20;

    for (var hour = startHour; hour <= endHour; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      if (hour != endHour) {
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    }

    return slots;
  }

  bool _isPastTime(DateTime date, TimeOfDay time) {
    final now = DateTime.now();
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return selected.isBefore(now);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: const Color(0xFF6B3F32),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF6B3F32),
        fontWeight: FontWeight.w800,
      ),
      side: const BorderSide(color: Color(0xFFD9B7A9)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = disabled
        ? const Color(0xFFF0E2D9)
        : selected
        ? const Color(0xFFC96A3D)
        : Colors.white;
    final textColor = disabled
        ? const Color(0xFFB08B7B)
        : selected
        ? Colors.white
        : const Color(0xFF43261D);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
