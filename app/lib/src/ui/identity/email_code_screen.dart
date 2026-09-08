import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n_ext.dart';

sealed class EmailCodeResult {
  const EmailCodeResult();
}

class CodeAccepted extends EmailCodeResult {
  const CodeAccepted(this.userId);
  final String userId;
}

class CodeRejected extends EmailCodeResult {
  const CodeRejected(this.reason);
  final String reason;
}

/// Email identity in two steps, entirely in-app.
///
/// No browser hand-off, no redirect URL, no deep link. A magic link would need
/// universal links, App Links, and a hosted domain the product does not have —
/// and it breaks in exactly the case that matters most, where the user reads
/// mail on a different device from the one being linked (ADR-0016).
class EmailCodeScreen extends StatefulWidget {
  const EmailCodeScreen({
    required this.onSendCode,
    required this.onVerify,
    required this.onAuthenticated,
    required this.onCancel,
    super.key,
  });

  final Future<void> Function(String email) onSendCode;
  final Future<EmailCodeResult> Function(String email, String code) onVerify;
  final void Function(String userId) onAuthenticated;
  final VoidCallback onCancel;

  static const emailFieldKey = Key('email-field'); // niche:allow widget key
  static const codeFieldKey = Key('code-field'); // niche:allow widget key
  static const sendKey = Key('email-send'); // niche:allow widget key
  static const verifyKey = Key('email-verify'); // niche:allow widget key
  static const resendKey = Key('email-resend'); // niche:allow widget key
  static const changeEmailKey = Key('email-change'); // niche:allow widget key

  static const codeLength = 6;
  static const resendCooldown = Duration(seconds: 30);

  @override
  State<EmailCodeScreen> createState() => _EmailCodeScreenState();
}

class _EmailCodeScreenState extends State<EmailCodeScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();

  bool _onCodeStep = false;
  bool _busy = false;
  bool _canResend = false;
  String? _error;
  Timer? _cooldown;

  /// Deliberately permissive. Address validation stricter than the mail system
  /// rejects real addresses, and the code round trip is the real check.
  bool get _addressLooksPlausible {
    final value = _email.text.trim();
    final at = value.indexOf('@'); // niche:allow address parsing, not copy
    return at > 0 &&
        value.indexOf('.', at) > at + 1 && // niche:allow address parsing
        !value.endsWith('.'); // niche:allow address parsing
  }

  @override
  void dispose() {
    _cooldown?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _canResend = false);
    _cooldown?.cancel();
    _cooldown = Timer(EmailCodeScreen.resendCooldown, () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  Future<void> _send() async {
    if (!_addressLooksPlausible || _busy) return;
    final failureMessage = context.l10n.codeSendFailed;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSendCode(_email.text.trim());
      if (!mounted) return;
      setState(() => _onCodeStep = true);
      _startCooldown();
    } catch (_) {
      if (mounted) setState(() => _error = failureMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_code.text.length != EmailCodeScreen.codeLength || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.onVerify(_email.text.trim(), _code.text);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case CodeAccepted(:final userId):
        widget.onAuthenticated(userId);
      case CodeRejected(:final reason):
        // Stay here. The address is still on screen and still correct; sending
        // them back to step one would lose it for no reason.
        setState(() => _error = reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onCancel),
        title: Text(_onCodeStep ? l10n.codeStepTitle : l10n.emailStepTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_onCodeStep) ...[
              TextField(
                key: EmailCodeScreen.emailFieldKey,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.emailAddressField),
                onSubmitted: (_) => _send(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: EmailCodeScreen.sendKey,
                onPressed: _busy ? null : _send,
                child: Text(l10n.sendCodeButton),
              ),
            ] else ...[
              Text(
                l10n.codeSentTo(_email.text.trim()),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                key: EmailCodeScreen.codeFieldKey,
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: EmailCodeScreen.codeLength,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.codeField),
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: EmailCodeScreen.verifyKey,
                onPressed: _busy ? null : _verify,
                child: Text(l10n.continueButton),
              ),
              TextButton(
                key: EmailCodeScreen.resendKey,
                onPressed: _canResend ? _send : null,
                child: Text(l10n.resendCodeButton),
              ),
              TextButton(
                key: EmailCodeScreen.changeEmailKey,
                onPressed: () => setState(() => _onCodeStep = false),
                child: Text(l10n.changeEmailButton),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
