import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../configs/themes.dart';
import '../../models/malla_models.dart';
import '../../services/auth_service.dart';
import '../../services/malla_service.dart';
import '../login/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    _CarreraCard(),
                    SizedBox(height: 16),
                    _ConfigAcademicaSection(),
                    SizedBox(height: 28),
                    _LogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser;
    final initials =
        ((user?.firstName.isNotEmpty == true ? user!.firstName[0] : '') +
                (user?.lastName.isNotEmpty == true ? user!.lastName[0] : ''))
            .toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: MaterialTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.code ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

// ── Carrera (info, no editable) ───────────────────────────────────────────────

class _CarreraCard extends StatelessWidget {
  const _CarreraCard();

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.to;
    final carreraName = auth.getCareerName(auth.currentUser?.careerId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8DC),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.graduationCap,
              color: MaterialTheme.primaryDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Carrera',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  carreraName.isNotEmpty ? carreraName : '—',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 13, color: Color(0xFF777777)),
                SizedBox(width: 4),
                Text(
                  'Fija',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

// ── Sección "Configuración académica" ─────────────────────────────────────────

class _ConfigAcademicaSection extends StatelessWidget {
  const _ConfigAcademicaSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'Configuración académica',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const _EspecialidadCard(),
      ],
    );
  }
}

// ── Tarjeta de especialización ────────────────────────────────────────────────

class _EspecialidadCard extends StatelessWidget {
  const _EspecialidadCard();

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EspecialidadSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.to;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8DC),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.bookmark,
                  color: MaterialTheme.primaryDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Especialización',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _openSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: MaterialTheme.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.pencil,
                        size: 12,
                        color: MaterialTheme.primaryDark,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Editar',
                        style: TextStyle(
                          color: MaterialTheme.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final user = auth.currentUser;
            final principal = user?.especialidadPrincipal;
            final interes = user?.especialidadesInteres ?? [];

            if (principal == null && interes.isEmpty) {
              return const Text(
                'Sin especialización seleccionada',
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (principal != null) ...[
                  const Text(
                    'Principal',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _PrincipalChip(espId: principal),
                  if (interes.isNotEmpty) const SizedBox(height: 12),
                ],
                if (interes.isNotEmpty) ...[
                  const Text(
                    'También me interesa',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: interes
                        .map((id) => _InteresChip(espId: id))
                        .toList(),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PrincipalChip extends StatelessWidget {
  const _PrincipalChip({required this.espId});
  final int espId;

  int _pendingCount(int id) {
    final auth = AuthService.to;
    final malla = MallaService.to;
    final user = auth.currentUser;
    if (user == null) return 0;
    final espName = auth.getEspecialidadName(id);
    if (espName.isEmpty) return 0;
    final normalized = malla.normalizeSpecialty(espName);
    final statuses = malla.computeStatuses(user);
    return malla.courses.where((c) {
      if (!c.isElective) return false;
      if (!c.specialties.contains(normalized)) return false;
      final s = statuses[c.id];
      return s == CourseStatus.locked || s == CourseStatus.unlocked;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.to.getEspecialidadName(espId);
    final pending = _pendingCount(espId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MaterialTheme.primaryColor.withValues(alpha: 0.6),
          width: 1.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.star,
            size: 13,
            color: MaterialTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              color: MaterialTheme.primaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (pending > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: MaterialTheme.primaryColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$pending pendientes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InteresChip extends StatelessWidget {
  const _InteresChip({required this.espId});
  final int espId;

  @override
  Widget build(BuildContext context) {
    final name = AuthService.to.getEspecialidadName(espId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.heart, size: 11, color: Color(0xFF0EA5E9)),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF0369A1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet de edición ───────────────────────────────────────────────────

class _EspecialidadSheet extends StatefulWidget {
  const _EspecialidadSheet();

  @override
  State<_EspecialidadSheet> createState() => _EspecialidadSheetState();
}

class _EspecialidadSheetState extends State<_EspecialidadSheet> {
  late int? _principal;
  late Set<int> _interes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.to.currentUser;
    _principal = user?.especialidadPrincipal;
    _interes = Set.of(user?.especialidadesInteres ?? []);
  }

  List<Map<String, dynamic>> get _opciones {
    final auth = AuthService.to;
    final cId = auth.currentUser?.careerId;
    if (cId == null) return const [];
    final list = auth.especialidades
        .where((e) => e['carrera_id'] == cId && e['is_active'] == true)
        .toList();
    list.sort((a, b) {
      final oA = (a['display_order'] as num?)?.toInt() ?? 999;
      final oB = (b['display_order'] as num?)?.toInt() ?? 999;
      return oA.compareTo(oB);
    });
    return list;
  }

  void _setPrincipal(int id) {
    setState(() {
      if (_principal == id) {
        _principal = null;
      } else {
        _principal = id;
        _interes.remove(id);
      }
    });
  }

  void _toggleInteres(int id) {
    if (_principal == id) return;
    setState(() {
      if (_interes.contains(id)) {
        _interes.remove(id);
      } else {
        _interes.add(id);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final auth = AuthService.to;
    await auth.completeSetup(
      careerId: auth.currentUser!.careerId!,
      especialidadPrincipal: _principal,
      especialidadesInteres: _interes.toList(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final opciones = _opciones;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8DC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        LucideIcons.bookmark,
                        color: MaterialTheme.primaryDark,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Especialización',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Elige principal, intereses o ninguna.',
                            style: TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
              ],
            ),
          ),
          if (opciones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hay especializaciones disponibles para tu carrera.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: opciones.map((esp) {
                    final id = esp['id'] as int;
                    final name = esp['name'] as String;
                    final desc = esp['description'] as String? ?? '';
                    final isPrincipal = _principal == id;
                    final isInteres = _interes.contains(id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SheetEspecialidadRow(
                        name: name,
                        desc: desc,
                        isPrincipal: isPrincipal,
                        isInteres: isInteres,
                        onTapPrincipal: () => _setPrincipal(id),
                        onTapInteres: () => _toggleInteres(id),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Icon(LucideIcons.check, size: 18),
                label: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MaterialTheme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: MaterialTheme.primaryColor
                      .withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetEspecialidadRow extends StatelessWidget {
  const _SheetEspecialidadRow({
    required this.name,
    required this.desc,
    required this.isPrincipal,
    required this.isInteres,
    required this.onTapPrincipal,
    required this.onTapInteres,
  });

  final String name;
  final String desc;
  final bool isPrincipal;
  final bool isInteres;
  final VoidCallback onTapPrincipal;
  final VoidCallback onTapInteres;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: isPrincipal
            ? const Color(0xFFFFF1EA)
            : isInteres
            ? const Color(0xFFF0F7FF)
            : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrincipal
              ? MaterialTheme.primaryColor
              : isInteres
              ? const Color(0xFF0EA5E9)
              : const Color(0xFFE5E5E5),
          width: (isPrincipal || isInteres) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isPrincipal
                            ? MaterialTheme.primaryDark
                            : const Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isPrincipal)
                      const Text(
                        'Principal',
                        style: TextStyle(
                          color: MaterialTheme.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (isInteres)
                      const Text(
                        'Me interesa',
                        style: TextStyle(
                          color: Color(0xFF0EA5E9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (desc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            )
          else
            const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SheetChip(
                  label: isPrincipal ? 'Quitar principal' : 'Principal',
                  icon: isPrincipal ? LucideIcons.x : LucideIcons.star,
                  active: isPrincipal,
                  color: MaterialTheme.primaryColor,
                  onTap: onTapPrincipal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SheetChip(
                  label: isInteres ? 'Quitar interés' : 'Me interesa',
                  icon: isInteres ? LucideIcons.x : LucideIcons.heart,
                  active: isInteres,
                  color: const Color(0xFF0EA5E9),
                  onTap: isPrincipal ? null : onTapInteres,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  const _SheetChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFF5F5F5)
              : active
              ? color.withValues(alpha: 0.12)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: disabled
                ? const Color(0xFFE0E0E0)
                : active
                ? color.withValues(alpha: 0.5)
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: disabled
                  ? const Color(0xFFCCCCCC)
                  : active
                  ? color
                  : const Color(0xFF888888),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: disabled
                      ? const Color(0xFFCCCCCC)
                      : active
                      ? color
                      : const Color(0xFF555555),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logout ────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          await AuthService.to.logout();
          Get.offAll(() => const LoginPage());
        },
        icon: const Icon(LucideIcons.logOut, size: 18),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
