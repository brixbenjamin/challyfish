import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/identity.dart';
import '../../notifications/reminder_scheduler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.scheduler,
    required this.linkedIdentity,
    required this.onLink,
    required this.onDeleteAccount,
    required this.onRestorePurchases,
    this.pickTime,
    super.key,
  });

  final ReminderScheduler scheduler;

  /// Null is an unlinked account. It subsumes the old isLinked flag rather than
  /// sitting beside it, because two fields describing one fact can disagree.
  final LinkedIdentity? linkedIdentity;
  final VoidCallback onLink;
  final VoidCallback onDeleteAccount;
  final VoidCallback onRestorePurchases;

  static const linkRowKey = Key('settings-link'); // niche:allow widget key
  static const identityRowKey = Key('settings-identity'); // niche:allow key
  static const deleteRowKey = Key('settings-delete'); // niche:allow widget key

  /// New here: plan 2 built the reminder row without a key, and the ordering
  /// test needs to find it.
  static const reminderRowKey = Key('settings-reminder'); // niche:allow key

  /// Injected so the picker can be driven in a widget test. Defaults to
  /// Material's showTimePicker.
  final Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initial)?
  pickTime;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enabled = false;
  bool _permissionDenied = false;
  bool _loading = true;
  TimeOfDay _at = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await widget.scheduler.isEnabled();
    final saved = await widget.scheduler.savedTime();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _at = saved;
      _loading = false;
    });
  }

  Future<TimeOfDay?> _askForTime() {
    final pick =
        widget.pickTime ??
        (BuildContext context, TimeOfDay initial) =>
            showTimePicker(context: context, initialTime: initial);
    return pick(context, _at);
  }

  Future<void> _toggle(bool value) async {
    if (!value) {
      await widget.scheduler.disable();
      if (mounted) setState(() => _enabled = false);
      return;
    }

    // A denied prompt is permanent on iOS, so never ask twice.
    if (_permissionDenied) return;

    // The user picks the time (ADR-0011). Asking first also means a user who
    // backs out here is never shown a permission prompt at all.
    final at = await _askForTime();
    if (at == null || !mounted) return;

    final granted = await widget.scheduler.enable(at);
    if (!mounted) return;
    setState(() {
      _at = at;
      _enabled = granted;
      _permissionDenied = !granted;
    });
  }

  Future<void> _changeTime() async {
    final at = await _askForTime();
    if (at == null || !mounted) return;
    await widget.scheduler.enable(at);
    if (mounted) setState(() => _at = at);
  }

  String get _formattedTime =>
      '${_at.hour.toString().padLeft(2, '0')}:${_at.minute.toString().padLeft(2, '0')}'; // niche:allow — a clock format, not copy

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            key: SettingsScreen.reminderRowKey,
            title: Text(l10n.reminderToggle),
            subtitle: Text(
              _enabled
                  ? l10n.reminderOnAt(_formattedTime)
                  : l10n.reminderOffSubtitle,
            ),
            value: _enabled,
            onChanged: _toggle,
          ),
          if (_enabled)
            ListTile(
              title: Text(l10n.reminderChangeTime),
              trailing: Text(_formattedTime),
              onTap: _changeTime,
            ),
          if (_permissionDenied)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.notificationsBlockedNotice),
            ),
          const Divider(),
          _SectionHeading(l10n.settingsAccountSection),
          if (widget.linkedIdentity == null)
            ListTile(
              key: SettingsScreen.linkRowKey,
              title: Text(l10n.linkIdentityButton),
              // Plain, not a warning. ADR-0013 rejected a standing warning
              // here: parked in settings it becomes furniture nobody reads.
              // The real consequence is stated in the link screen, at the
              // moment of choice.
              subtitle: Text(l10n.linkIdentitySettingsSubtitle),
              onTap: widget.onLink,
            )
          else
            ListTile(
              key: SettingsScreen.identityRowKey,
              title: Text(l10n.signedInRow),
              subtitle: Text(widget.linkedIdentity!.label),
            ),
          ListTile(
            title: Text(l10n.restorePurchases),
            onTap: widget.onRestorePurchases,
          ),
          _SectionHeading(l10n.settingsPrivacySection),
          ListTile(
            key: SettingsScreen.deleteRowKey,
            title: Text(l10n.deleteAccountTitle),
            subtitle: Text(l10n.deleteAccountSettingsSubtitle),
            onTap: widget.onDeleteAccount,
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}
