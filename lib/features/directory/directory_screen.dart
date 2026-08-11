import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/data/backend_client.dart';
import 'package:nexo/data/directory_service.dart';
import 'package:nexo/features/directory/access_admin_screen.dart';
import 'package:nexo/features/directory/student_record_screen.dart';
import 'package:nexo/features/directory/widgets/directory_widgets.dart';
import 'package:nexo/features/grades/grade_widgets.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/widgets/status_chip.dart';
import 'package:nexo/shared/widgets/student_avatar.dart';

/// Directorio de estudiantes.
///
/// Es un apartado aparte del modo estudiante y del modo docente: lo que
/// muestra no depende del tipo de cuenta sino del acceso que el backend haya
/// concedido. Los datos académicos son de SIGMA/Intranet; el backend solo
/// verifica quién puede verlos.
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key, required this.directory});
  final DirectoryService directory;

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  /// Múltiplo de 2 y de 3: la página cuadra tanto con una columna como con
  /// dos, sin dejar la última fila coja.
  static const _pageSize = 24;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  Timer? _debounce;
  String _query = '';
  String? _school;
  int? _cycle;

  bool _loading = true;
  bool _loadingMore = false;
  String? _errorCode;
  List<StudentSummary> _students = [];
  List<String> _schools = const [];
  int _total = 0;
  int _page = 1;
  int _pages = 1;

  BackendClient get _client => widget.directory.client;
  bool get _filtered => _query.isNotEmpty || _school != null || _cycle != null;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
    _loadSchools();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients || _loadingMore || _page >= _pages) return;
    final position = _scrollCtrl.position;
    if (position.pixels > position.maxScrollExtent - 600) _loadMore();
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _client.schools();
      if (mounted) setState(() => _schools = schools);
    } on BackendException {
      // El filtro es un extra: si no llega, la lista sigue funcionando.
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorCode = null;
    });
    try {
      final page = await _client.students(
        query: _query,
        school: _school,
        cycle: _cycle,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _students = page.students;
        _total = page.total;
        _page = page.page;
        _pages = page.pages;
        _loading = false;
      });
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorCode = e.code;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final page = await _client.students(
        query: _query,
        school: _school,
        cycle: _cycle,
        page: _page + 1,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _students = [..._students, ...page.students];
        _page = page.page;
        _pages = page.pages;
        _loadingMore = false;
      });
    } on BackendException {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onQueryChanged(String value) {
    // La búsqueda va contra el servidor: se espera a que deje de escribir.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
      _load();
    });
  }

  void _setSchool(String? school) {
    setState(() => _school = school);
    _load();
  }

  void _setCycle(int? cycle) {
    setState(() => _cycle = cycle);
    _load();
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _school = null;
      _cycle = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              title: l.directoryTitle,
              subtitle: _loading
                  ? l.directorySubtitle
                  : l.directoryCount(_total),
              actions: [
                if (widget.directory.isAdmin)
                  IconButton(
                    tooltip: l.directoryManageAccess,
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    onPressed: () => AccessAdminScreen.open(context, _client),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Reveal(
                    index: 0,
                    child: _Filters(
                      controller: _searchCtrl,
                      schools: _schools,
                      school: _school,
                      cycle: _cycle,
                      onQuery: _onQueryChanged,
                      onSchool: _setSchool,
                      onCycle: _setCycle,
                      onClear: _filtered ? _clearFilters : null,
                    ),
                  ),
                  const Gap(AppSpacing.xl),
                  _results(l),
                  const Gap(AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _results(AppLocalizations l) {
    if (_loading) {
      return directoryGrid(context, [
        for (var i = 0; i < (context.isDesktop ? 6 : 4); i++)
          const _StudentCardSkeleton(),
      ]);
    }

    if (_errorCode != null) {
      final denied = _errorCode == 'sin_acceso_directorio';
      return EmptyState(
        icon: denied ? Icons.lock_outline : Icons.cloud_off_outlined,
        title: denied ? l.directoryDeniedTitle : l.directoryUnavailableTitle,
        subtitle: denied ? l.directoryDeniedHint : l.directoryUnavailableHint,
        color: denied ? NexoTheme.warning : NexoTheme.danger,
        onRetry: _load,
        retryLabel: l.actionRetry,
      );
    }

    if (_students.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: l.directoryNoResults,
        subtitle: l.directoryNoResultsHint,
        onRetry: _filtered ? _clearFilters : null,
        retryLabel: l.directoryClearFilters,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        directoryGrid(context, [
          for (final s in _students)
            _StudentCard(
              student: s,
              onTap: () => StudentRecordScreen.open(context, _client, s),
            ),
        ]),
        const Gap(AppSpacing.xl),
        if (_loadingMore)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          )
        else if (_page >= _pages && _students.length > 8)
          Center(
            child: Text(
              l.directoryEndOfList(_total),
              style: TextStyle(
                fontSize: AppFont.caption,
                color: NexoTheme.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

/// Buscador y filtros. En escritorio caben en una fila y los ciclos se
/// reparten en varias líneas; en móvil el carrusel de ciclos se desplaza.
class _Filters extends StatelessWidget {
  const _Filters({
    required this.controller,
    required this.schools,
    required this.school,
    required this.cycle,
    required this.onQuery,
    required this.onSchool,
    required this.onCycle,
    required this.onClear,
  });
  final TextEditingController controller;
  final List<String> schools;
  final String? school;
  final int? cycle;
  final ValueChanged<String> onQuery;
  final ValueChanged<String?> onSchool;
  final ValueChanged<int?> onCycle;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final search = DirectorySearchField(
      controller: controller,
      hint: l.directorySearchHint,
      onChanged: onQuery,
    );

    final schoolPicker = _SchoolPicker(
      schools: schools,
      selected: school,
      onChanged: onSchool,
    );

    final cycles = [
      for (var c = 1; c <= 10; c++)
        ChoiceChip(
          label: Text(l.directoryCycle('$c')),
          selected: cycle == c,
          onSelected: (_) => onCycle(cycle == c ? null : c),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (context.isWide)
          Row(
            children: [
              Expanded(flex: 3, child: search),
              if (schools.isNotEmpty) ...[
                const Gap.h(AppSpacing.md),
                Expanded(flex: 2, child: schoolPicker),
              ],
              if (onClear != null) ...[
                const Gap.h(AppSpacing.md),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: Text(l.directoryClearFilters),
                ),
              ],
            ],
          )
        else ...[
          search,
          if (schools.isNotEmpty) ...[const Gap(AppSpacing.md), schoolPicker],
        ],
        const Gap(AppSpacing.md),
        // Escritorio: todos los ciclos visibles. Móvil: carrusel, que ocupa
        // una sola línea y no empuja la lista hacia abajo.
        if (context.isWide)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: cycles,
          )
        else
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cycles.length,
              separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
              itemBuilder: (_, i) => cycles[i],
            ),
          ),
        if (!context.isWide && onClear != null) ...[
          const Gap(AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: Text(l.directoryClearFilters),
            ),
          ),
        ],
      ],
    );
  }
}

class _SchoolPicker extends StatelessWidget {
  const _SchoolPicker({
    required this.schools,
    required this.selected,
    required this.onChanged,
  });
  final List<String> schools;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: Icon(
          Icons.school_outlined,
          size: AppIcon.lg,
          color: NexoTheme.textMuted,
        ),
      ),
      hint: Text(l.directoryFilterSchool),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(l.directoryAllSchools),
        ),
        for (final s in schools)
          DropdownMenuItem<String>(
            value: s,
            child: Text(s, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.onTap});
  final StudentSummary student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              StudentAvatar(
                code: student.code,
                name: student.fullName,
                size: 48,
                radius: 15,
              ),
              const Gap.h(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.subtitle,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Gap(AppSpacing.xxs),
                    Text(
                      student.school == null
                          ? student.code
                          : '${student.code} · ${student.school}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.caption,
                        color: NexoTheme.textMuted,
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (student.cycle != null)
                          StatusChip(
                            text: l.directoryCycle('${student.cycle}'),
                            color: NexoTheme.info,
                            icon: Icons.layers_outlined,
                          ),
                        if (student.status != null)
                          StatusChip(
                            text: student.status!,
                            color: student.status == 'regular'
                                ? NexoTheme.success
                                : NexoTheme.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap.h(AppSpacing.md),
              GradeBadge.fromRaw(
                student.average?.toStringAsFixed(2) ?? '—',
                size: 46,
                fs: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marca de posición mientras carga: mismo alto que la tarjeta real, para que
/// la lista no dé un salto al llegar los datos.
class _StudentCardSkeleton extends StatelessWidget {
  const _StudentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Skeleton(width: 48, height: 48, radius: 15),
            Gap.h(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 170, height: 14),
                  Gap(AppSpacing.sm),
                  Skeleton(width: 120, height: 11),
                  Gap(AppSpacing.sm),
                  Skeleton(width: 90, height: 18, radius: AppRadii.pill),
                ],
              ),
            ),
            Gap.h(AppSpacing.md),
            Skeleton(width: 46, height: 46, radius: 13),
          ],
        ),
      ),
    );
  }
}
