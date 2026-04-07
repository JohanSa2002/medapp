import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../providers/cita_provider.dart';
import '../../providers/medicamento_provider.dart';
import '../../models/medicamento.dart';
import '../medicamentos/medicamentos_list_screen.dart';
import '../citas/citas_list_screen.dart';
import '../registro/registro_data_screen.dart';
import '../reportes/reportes_screen.dart';
import '../perfil/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<AuthService>().getCurrentUser()!.uid;
      context.read<CitaProvider>().loadCitas(userId);
      context.read<MedicamentoProvider>().loadMedicamentos(userId);
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().getCurrentUser();
    final displayName = user?.displayName ?? user?.email ?? '';
    final firstName = displayName.split(' ').first;
    final today = DateFormat('EEEE, d \'de\' MMMM', 'es').format(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 20, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A7AE0), Color(0xFF5B8DEF), Color(0xFF6FA0F5)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, $firstName',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            today,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withAlpha(204),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PerfilScreen()),
                        ),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(64),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              _initials(displayName),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ─── Medicamentos de hoy ─────────────────────────────────
                Consumer<MedicamentoProvider>(
                  builder: (context, provider, _) {
                    if (provider.medicamentos.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Medicamentos de hoy'),
                        const SizedBox(height: 12),
                        ...provider.medicamentos
                            .map((m) => _MedReminderRow(med: m)),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                // ─── Próxima cita ─────────────────────────────────────────
                Consumer<CitaProvider>(
                  builder: (context, provider, _) {
                    final proxima = provider.proximaCita;
                    if (proxima == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Próxima cita'),
                        const SizedBox(height: 12),
                        _CitaCard(proxima: proxima),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                // ─── Menú principal ───────────────────────────────────────
                const _SectionTitle('¿Qué deseas hacer?'),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final ratio = constraints.maxWidth < 340 ? 0.85 : 0.92;
                    return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: ratio,
                  children: [
                    _MenuTile(
                      icon: Icons.medication_rounded,
                      label: 'Medicamentos',
                      subtitle: 'Horarios y dosis',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryLight,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MedicamentosListScreen(),
                      )),
                    ),
                    _MenuTile(
                      icon: Icons.calendar_month_rounded,
                      label: 'Citas médicas',
                      subtitle: 'Agenda y recordatorios',
                      color: AppColors.warning,
                      bgColor: AppColors.warningLight,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const CitasListScreen(),
                      )),
                    ),
                    _MenuTile(
                      icon: Icons.show_chart_rounded,
                      label: 'Mis registros',
                      subtitle: 'Glucosa, peso y más',
                      color: AppColors.secondary,
                      bgColor: AppColors.secondaryLight,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const RegistroDataScreen(),
                      )),
                    ),
                    _MenuTile(
                      icon: Icons.assessment_rounded,
                      label: 'Reportes',
                      subtitle: 'PDF, CSV y estadísticas',
                      color: const Color(0xFF9B7EDE),
                      bgColor: const Color(0xFFF0EBFF),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ReportesScreen(),
                      )),
                    ),
                  ],
                );
                  },
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}



class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _CitaCard extends StatelessWidget {
  final dynamic proxima;
  const _CitaCard({required this.proxima});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4E0), Color(0xFFFFF8EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withAlpha(64)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proxima.doctor,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  proxima.especialidad,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${proxima.fechaFormato} · ${proxima.horaFormato}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.warning,
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Fila de recordatorio de medicamento (home) ───────────────────────────────

class _MedReminderRow extends StatelessWidget {
  final Medicamento med;
  const _MedReminderRow({required this.med});

  String _toAmPm(String hhmm) {
    final parts = hhmm.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  med.dosis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: med.horarios
                .take(3)
                .map(
                  (h) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _toAmPm(h),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
