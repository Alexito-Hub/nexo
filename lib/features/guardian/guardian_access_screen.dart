import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/data/backend_client.dart';
import 'package:nexo/features/directory/student_record_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/app_logo.dart';
import 'package:nexo/shared/widgets/student_avatar.dart';

/// Acceso de padres y apoderados: DNI + PIN, sin cuenta de la UPLA.
///
/// Es una puerta aparte y deliberadamente corta: se entra, se ve la ficha del
/// hijo y se sale. Ni directorio, ni ajustes, ni el resto de la app.
///
/// El PIN existe porque un DNI no autentica a nadie —lo conoce cualquiera que
/// tenga el documento delante— y al otro lado hay notas y deudas de un
/// estudiante.
class GuardianAccessScreen extends StatefulWidget {
  const GuardianAccessScreen({super.key, this.client});

  /// Solo para pruebas: en la app real cada entrada abre su propia sesión.
  final BackendClient? client;

  static Future<void> open(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GuardianAccessScreen(),
        settings: RouteSettings(name: l.guardianTitle),
      ),
    );
  }

  @override
  State<GuardianAccessScreen> createState() => _GuardianAccessScreenState();
}

class _GuardianAccessScreenState extends State<GuardianAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  late final BackendClient _client = widget.client ?? BackendClient();

  bool _loading = false;
  String? _errorCode;
  List<StudentSummary>? _students;

  @override
  void dispose() {
    _dniCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _errorCode = null;
    });

    try {
      final students = await _client.guardianLogin(
        dni: _dniCtrl.text.trim(),
        pin: _pinCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _students = students;
        _loading = false;
      });
      // Con un solo hijo no tiene sentido preguntar a quién quiere ver.
      if (students.length == 1) _openRecord(students.first);
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorCode = e.code;
      });
    }
  }

  void _openRecord(StudentSummary student) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentRecordScreen(
          fetch: _client.guardianStudent,
          code: student.code,
          preview: student,
        ),
        settings: RouteSettings(name: student.fullName),
      ),
    );
  }

  void _signOut() {
    _client.disconnect();
    setState(() {
      _students = null;
      _pinCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final students = _students;
    return Scaffold(
      backgroundColor: NexoTheme.bg,
      appBar: AppBar(
        title: Text(l.guardianTitle),
        actions: [
          if (students != null)
            TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded, size: AppIcon.md),
              label: Text(l.guardianSignOut),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.contentPadding,
                vertical: AppSpacing.xxl,
              ),
              child: students == null ? _form(l) : _picker(l, students),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(AppLocalizations l) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AppLogo(size: 56)),
          const Gap(AppSpacing.xl),
          Text(
            l.guardianHeadline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.h2,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: NexoTheme.textPrimary,
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            l.guardianIntro,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.body,
              height: 1.45,
              color: NexoTheme.textSecondary,
            ),
          ),
          const Gap(AppSpacing.xxxl),
          TextFormField(
            controller: _dniCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: l.guardianDniLabel,
              prefixIcon: Icon(
                Icons.badge_outlined,
                color: NexoTheme.textSecondary,
              ),
            ),
            validator: (v) => (v == null || v.trim().length < 8)
                ? l.guardianDniInvalid
                : null,
          ),
          const Gap(AppSpacing.md),
          TextFormField(
            controller: _pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l.guardianPinLabel,
              helperText: l.guardianPinHelp,
              prefixIcon: Icon(
                Icons.password_outlined,
                color: NexoTheme.textSecondary,
              ),
            ),
            validator: (v) => (v == null || v.trim().length < 6)
                ? l.guardianPinInvalid
                : null,
          ),
          if (_errorCode != null) ...[
            const Gap(AppSpacing.lg),
            _ErrorNotice(code: _errorCode!),
          ],
          const Gap(AppSpacing.xl),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l.guardianEnter,
                      style: const TextStyle(
                        fontSize: AppFont.title,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const Gap(AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: AppIcon.md,
                color: NexoTheme.textMuted,
              ),
              const Gap.h(AppSpacing.xs),
              Flexible(
                child: Text(
                  l.guardianAuditNotice,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.caption,
                    color: NexoTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _picker(AppLocalizations l, List<StudentSummary> students) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          students.isEmpty ? l.guardianNoStudents : l.guardianPickTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.h3,
            fontWeight: FontWeight.w800,
            color: NexoTheme.textPrimary,
          ),
        ),
        const Gap(AppSpacing.xl),
        for (final s in students) ...[
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              leading: StudentAvatar(
                code: s.code,
                name: s.fullName,
                size: 46,
                radius: 15,
              ),
              title: Text(
                s.fullName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                s.school == null ? s.code : '${s.code} · ${s.school}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFont.caption,
                  color: NexoTheme.textMuted,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
              onTap: () => _openRecord(s),
            ),
          ),
          const Gap(AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locked = code == 'acceso_bloqueado';
    final color = locked ? NexoTheme.warning : NexoTheme.danger;
    final text = switch (code) {
      'acceso_bloqueado' => l.guardianLocked,
      'credenciales_invalidas' => l.guardianBadCredentials,
      _ => l.guardianUnavailable,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadii.rSm,
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(
            locked ? Icons.timer_outlined : Icons.error_outline,
            size: AppIcon.lg,
            color: color,
          ),
          const Gap.h(AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: AppFont.small, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
