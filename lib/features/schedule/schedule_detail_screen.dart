import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/shared/widgets/section_card.dart';

class ScheduleDetailScreen extends StatelessWidget {
  const ScheduleDetailScreen({super.key, required this.grupo});
  final ScheduleClassGroup grupo;
  static Future<void> open(BuildContext context, ScheduleClassGroup grupo) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ScheduleDetailScreen(grupo: grupo),
          settings: RouteSettings(name: grupo.subject),
        ),
      );
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: NexoTheme.bg,
      appBar: AppBar(title: Text(l.scheduleDetailTitle)),
      body: SafeArea(child: ScheduleDetailBody(grupo: grupo)),
    );
  }
}

class ScheduleDetailBody extends StatelessWidget {
  const ScheduleDetailBody({super.key, required this.grupo});
  final ScheduleClassGroup grupo;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final h24 = AppStorage.instance.use24h;
    final first = grupo.sessions.first;
    final isToday = grupo.weekday == DateTime.now().weekday;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _Hero(grupo: grupo, isToday: isToday),
            const Gap(AppSpacing.lg),
            _TimeCard(grupo: grupo, h24: h24, label: l),
            const Gap(AppSpacing.lg),
            if (grupo.room.isNotEmpty ||
                first.building.isNotEmpty ||
                first.campus.isNotEmpty)
              _LocationCard(first: first, aula: grupo.room, label: l),
            if (grupo.room.isNotEmpty ||
                first.building.isNotEmpty ||
                first.campus.isNotEmpty)
              const Gap(AppSpacing.lg),
            if (grupo.teacher.isNotEmpty)
              _TeacherCard(teacher: grupo.teacher, label: l),
            if (grupo.teacher.isNotEmpty) const Gap(AppSpacing.lg),
            _SessionsCard(grupo: grupo, h24: h24, label: l),
            if (first.note.isNotEmpty) ...[
              const Gap(AppSpacing.lg),
              _NotesCard(text: first.note, label: l),
            ],
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final ScheduleClassGroup grupo;
  final bool isToday;
  const _Hero({required this.grupo, required this.isToday});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final first = grupo.sessions.first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NexoTheme.primary, NexoTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.rXxl,
        boxShadow: [
          BoxShadow(
            color: NexoTheme.primary.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DayBadge(idDia: grupo.weekday, isToday: isToday),
              const Gap.h(AppSpacing.sm),
              if (first.nrc.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: AppRadii.rPill,
                  ),
                  child: Text(
                    '${l.detailNrc} ${first.nrc}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppFont.small,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.lg),
          Text(
            grupo.subject,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppFont.h1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          if (first.section.isNotEmpty) ...[
            const Gap(AppSpacing.xs),
            Text(
              '${l.detailSection} ${first.section}'
              '${first.level.isNotEmpty ? ' · ${l.detailLevel} ${first.level}' : ''}'
              '${first.modality.isNotEmpty ? ' · ${first.modality}' : ''}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: AppFont.body,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  final int idDia;
  final bool isToday;
  const _DayBadge({required this.idDia, required this.isToday});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.18),
        borderRadius: AppRadii.rPill,
      ),
      child: Text(
        isToday
            ? '${l.detailToday} · ${Fmt.dayLabel(idDia)}'
            : Fmt.dayLabel(idDia),
        style: TextStyle(
          color: isToday ? NexoTheme.primary : Colors.white,
          fontSize: AppFont.small,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final ScheduleClassGroup grupo;
  final bool h24;
  final AppLocalizations label;
  const _TimeCard({
    required this.grupo,
    required this.h24,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final ini = Fmt.time(grupo.startTime, h24: h24);
    final fin = Fmt.time(grupo.endTime, h24: h24);
    final duracion = grupo.sessions.fold<int>(
      0,
      (a, s) => a + s.durationMinutes,
    );
    return SectionCard(
      title: label.detailSchedule,
      icon: Icons.schedule_rounded,
      iconColor: NexoTheme.primary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$ini – $fin',
                  style: TextStyle(
                    fontSize: AppFont.h2,
                    fontWeight: FontWeight.w800,
                    color: NexoTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Text(
                  label.detailDuration(duracion),
                  style: TextStyle(
                    fontSize: AppFont.small,
                    color: NexoTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final ScheduleClass first;
  final String aula;
  final AppLocalizations label;
  const _LocationCard({
    required this.first,
    required this.aula,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final parsed = Fmt.parseAula(aula);
    final pabellon = parsed['pabellon'];
    final aulaOnly = parsed['aula'];
    return SectionCard(
      title: label.detailLocation,
      icon: Icons.location_on_outlined,
      iconColor: NexoTheme.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pabellon != null) _kv(label.detailPavilion, pabellon),
          if (aulaOnly != null) _kv(label.detailRoom, aulaOnly),
          if (first.building.isNotEmpty)
            _kv(label.detailBuilding, first.building),
          if (first.campus.isNotEmpty) _kv(label.detailCampus, first.campus),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            k,
            style: TextStyle(
              fontSize: AppFont.small,
              fontWeight: FontWeight.w700,
              color: NexoTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: TextStyle(
              fontSize: AppFont.body,
              color: NexoTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _TeacherCard extends StatelessWidget {
  final String teacher;
  final AppLocalizations label;
  const _TeacherCard({required this.teacher, required this.label});
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: label.detailTeacher,
      icon: Icons.person_outline_rounded,
      iconColor: NexoTheme.info,
      child: Text(
        teacher,
        style: TextStyle(
          fontSize: AppFont.subtitle,
          fontWeight: FontWeight.w700,
          color: NexoTheme.textPrimary,
        ),
      ),
    );
  }
}

class _SessionsCard extends StatelessWidget {
  final ScheduleClassGroup grupo;
  final bool h24;
  final AppLocalizations label;
  const _SessionsCard({
    required this.grupo,
    required this.h24,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: label.detailSessions,
      icon: Icons.list_alt_rounded,
      iconColor: NexoTheme.success,
      child: Column(
        children: [
          for (var i = 0; i < grupo.sessions.length; i++) ...[
            _SessionRow(sesion: grupo.sessions[i], h24: h24),
            if (i < grupo.sessions.length - 1)
              Divider(height: 14, color: NexoTheme.border),
          ],
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final ScheduleClass sesion;
  final bool h24;
  const _SessionRow({required this.sesion, required this.h24});
  @override
  Widget build(BuildContext context) {
    final isTeoria = sesion.typeCode.toUpperCase() == 'T';
    final color = isTeoria ? NexoTheme.info : NexoTheme.success;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadii.rMd,
          ),
          child: Icon(
            isTeoria ? Icons.menu_book_outlined : Icons.science_outlined,
            color: color,
            size: AppIcon.lg,
          ),
        ),
        const Gap.h(AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sesion.typeName,
                style: TextStyle(
                  fontSize: AppFont.body,
                  fontWeight: FontWeight.w700,
                  color: NexoTheme.textPrimary,
                ),
              ),
              const Gap(AppSpacing.xxs),
              Text(
                '${Fmt.time(sesion.startTime, h24: h24)} – '
                '${Fmt.time(sesion.endTime, h24: h24)}'
                '${sesion.room.isNotEmpty ? ' · ${Fmt.formatAula(sesion.room)}' : ''}',
                style: TextStyle(
                  fontSize: AppFont.small,
                  color: NexoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String text;
  final AppLocalizations label;
  const _NotesCard({required this.text, required this.label});
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: label.detailNotes,
      icon: Icons.notes_outlined,
      iconColor: NexoTheme.warning,
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppFont.body,
          height: 1.5,
          color: NexoTheme.textSecondary,
        ),
      ),
    );
  }
}
