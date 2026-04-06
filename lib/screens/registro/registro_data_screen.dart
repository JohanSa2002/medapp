import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/registro_dato.dart';
import 'registro_quick_screen.dart';
import 'registro_historial_screen.dart';

class RegistroDataScreen extends StatelessWidget {
  const RegistroDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Registros'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DataCard(
              icon: Icons.bloodtype_rounded,
              titulo: 'Glucosa',
              subtitulo: 'Registra tus niveles de glucosa en sangre',
              accentColor: AppColors.primary,
              bgColor: AppColors.primaryLight,
              onRegistrar: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroQuickScreen(tipoDato: TipoDato.glucosa),
              )),
              onHistorial: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroHistorialScreen(tipoDato: TipoDato.glucosa),
              )),
            ),
            const SizedBox(height: 16),
            _DataCard(
              icon: Icons.scale_rounded,
              titulo: 'Peso',
              subtitulo: 'Lleva un control de tu peso corporal',
              accentColor: AppColors.secondary,
              bgColor: AppColors.secondaryLight,
              onRegistrar: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroQuickScreen(tipoDato: TipoDato.peso),
              )),
              onHistorial: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const RegistroHistorialScreen(tipoDato: TipoDato.peso),
              )),
            ),
            const SizedBox(height: 24),
            const _ReferenceCard(),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de tipo de dato ──────────────────────────────────────────────────

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onRegistrar;
  final VoidCallback onHistorial;

  const _DataCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.accentColor,
    required this.bgColor,
    required this.onRegistrar,
    required this.onHistorial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de acento izquierda
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: accentColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitulo,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: onRegistrar,
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text('Registrar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: onHistorial,
                              icon: const Icon(Icons.history_rounded, size: 20),
                              label: const Text('Historial'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accentColor,
                                side: BorderSide(
                                  color: accentColor.withAlpha(128),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de valores de referencia ────────────────────────────────────────

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Color(0xFF9B7EDE),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Valores de referencia',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          const _RefRow(
            label: 'Glucosa normal (ayunas)',
            value: '70 – 100 mg/dL',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 10),
          const _RefRow(
            label: 'Prediabetes',
            value: '101 – 125 mg/dL',
            color: AppColors.warning,
          ),
          const SizedBox(height: 10),
          const _RefRow(
            label: 'Diabetes',
            value: '≥ 126 mg/dL',
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _RefRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RefRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
