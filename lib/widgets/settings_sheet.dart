// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../services/reminder.dart';
import '../settings.dart';
import '../theme.dart';

Future<void> showSettingsSheet(BuildContext context,
    {required AppSettings settings}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SettingsSheet(settings: settings),
  );
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _busy = false;

  AppSettings get s => widget.settings;

  String _formatTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<void> _setReminder(bool enabled) async {
    setState(() => _busy = true);
    final reminder = ReminderService.instance;
    try {
      if (enabled) {
        final ok = await reminder.enable(
            hour: s.reminderMinutes ~/ 60, minute: s.reminderMinutes % 60);
        s.reminderEnabled = ok;
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("ئۇقتۇرۇش ئىجازىتى بېرىلمىدى")));
        }
      } else {
        await reminder.disable();
        s.reminderEnabled = false;
      }
    } catch (e) {
      debugPrint('Hatırlatma hatası: $e');
      s.reminderEnabled = false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickTime() async {
    final current = s.reminderMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    s.reminderMinutes = picked.hour * 60 + picked.minute;
    if (s.reminderEnabled) await _setReminder(true);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(context);
    final reminderSupported = ReminderService.instance.isSupported;
    final titleStyle = TextStyle(
        color: pal.primary, fontWeight: FontWeight.bold, fontSize: 18);

    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("تەڭشەكلەر", style: titleStyle),
              const SizedBox(height: 16),
              Text("ئوقۇش ھالىتى",
                  style: TextStyle(color: pal.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              SegmentedButton<ReadingMode>(
                segments: const [
                  ButtonSegment(
                      value: ReadingMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text("نورمال")),
                  ButtonSegment(
                      value: ReadingMode.sepia,
                      icon: Icon(Icons.coffee_outlined),
                      label: Text("سېپىيە")),
                  ButtonSegment(
                      value: ReadingMode.night,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text("كېچە")),
                ],
                selected: {s.readingMode},
                onSelectionChanged: (v) => s.readingMode = v.first,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.screen_lock_portrait_outlined,
                    color: pal.primary),
                title: Text("ئېكراننى ئوچۇق تۇتۇش",
                    style: TextStyle(color: pal.textPrimary)),
                subtitle: Text("ئوقۇۋاتقاندا ئېكران قاراڭغۇلاشمايدۇ",
                    style: TextStyle(color: pal.textSecondary, fontSize: 12)),
                value: s.keepScreenOn,
                onChanged: (v) => s.keepScreenOn = v,
              ),
              if (reminderSupported) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(Icons.notifications_active_outlined,
                      color: pal.primary),
                  title: Text("كۈندىلىك ئەسكەرتىش",
                      style: TextStyle(color: pal.textPrimary)),
                  subtitle: Text("ھەر كۈنى قۇرئان ئوقۇشنى ئەسكەرتىدۇ",
                      style: TextStyle(color: pal.textSecondary, fontSize: 12)),
                  value: s.reminderEnabled,
                  onChanged: _busy ? null : _setReminder,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: s.reminderEnabled && !_busy,
                  leading: Icon(Icons.schedule, color: pal.primary),
                  title: Text("ئەسكەرتىش ۋاقتى",
                      style: TextStyle(color: pal.textPrimary)),
                  trailing: Text(
                    _formatTime(s.reminderMinutes),
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        color: pal.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  onTap: _pickTime,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
