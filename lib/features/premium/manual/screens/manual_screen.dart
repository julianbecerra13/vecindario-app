import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';

/// Capítulo del manual con sus artículos
class ManualChapter {
  final String title;
  final String articles;
  final List<ManualArticle> items;
  final int linkedFines;

  const ManualChapter({
    required this.title,
    required this.articles,
    required this.items,
    this.linkedFines = 0,
  });
}

class ManualArticle {
  final int number;
  final String title;
  final String content;

  const ManualArticle({
    required this.number,
    required this.title,
    required this.content,
  });
}

/// Manual de Convivencia - Pantalla con búsqueda y capítulos
class ManualScreen extends ConsumerStatefulWidget {
  const ManualScreen({super.key});

  @override
  ConsumerState<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends ConsumerState<ManualScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedChapter;

  // Capítulos del manual (plantilla que se alimenta de Firestore en producción)
  static const _chapters = [
    ManualChapter(
      title: 'I. Disposiciones Generales',
      articles: 'Arts. 1 — 8',
      items: [
        ManualArticle(
          number: 1,
          title: 'Objeto del manual',
          content:
              'El presente manual tiene por objeto regular la convivencia entre los residentes del conjunto, estableciendo derechos, deberes y restricciones.',
        ),
        ManualArticle(
          number: 2,
          title: 'Ámbito de aplicación',
          content:
              'Las disposiciones de este manual aplican a todos los propietarios, arrendatarios, residentes, visitantes y personal de servicio del conjunto.',
        ),
        ManualArticle(
          number: 3,
          title: 'Autoridades del conjunto',
          content:
              'La Asamblea General de Propietarios es el máximo órgano de dirección. El Consejo de Administración ejerce la representación legal.',
        ),
      ],
    ),
    ManualChapter(
      title: 'II. Uso de Zonas Comunes',
      articles: 'Arts. 9 — 18',
      items: [
        ManualArticle(
          number: 9,
          title: 'Zonas comunes',
          content:
              'Son zonas comunes los pasillos, ascensores, parqueaderos, zonas verdes, salón social, piscina, gimnasio y demás áreas de uso colectivo.',
        ),
        ManualArticle(
          number: 10,
          title: 'Uso adecuado',
          content:
              'Las zonas comunes deben usarse de acuerdo con su destinación natural. Queda prohibido su uso para actividades comerciales sin autorización.',
        ),
      ],
      linkedFines: 1,
    ),
    ManualChapter(
      title: 'III. Parqueaderos',
      articles: 'Arts. 19 — 22',
      items: [
        ManualArticle(
          number: 19,
          title: 'Asignación de parqueaderos',
          content:
              'Cada unidad privada tiene asignado un puesto de parqueadero. No se permite el intercambio sin autorización de la administración.',
        ),
        ManualArticle(
          number: 20,
          title: 'Velocidad máxima',
          content:
              'La velocidad máxima dentro del parqueadero es de 10 km/h. Se prohíbe el uso de pito dentro de las instalaciones.',
        ),
      ],
    ),
    ManualChapter(
      title: 'IV. Horarios y Ruido',
      articles: 'Arts. 23 — 28',
      linkedFines: 3,
      items: [
        ManualArticle(
          number: 23,
          title: 'Horarios de silencio',
          content:
              'Queda prohibido generar ruidos que perturben la tranquilidad de los residentes entre las 10:00pm y las 7:00am de lunes a sábado, y entre las 10:00pm y las 8:00am los domingos y festivos.',
        ),
        ManualArticle(
          number: 24,
          title: 'Eventos y reuniones',
          content:
              'Los eventos sociales en áreas privadas deberán mantener niveles de ruido moderados y finalizar antes de las 10:00pm. Para eventos en zonas comunes se requiere reserva previa.',
        ),
        ManualArticle(
          number: 25,
          title: 'Obras y remodelaciones',
          content:
              'Las obras y remodelaciones solo podrán realizarse de lunes a viernes de 8:00am a 5:00pm, y sábados de 8:00am a 1:00pm. Prohibido en domingos y festivos.',
        ),
      ],
    ),
    ManualChapter(
      title: 'V. Mudanzas y Obras',
      articles: 'Arts. 29 — 35',
      items: [
        ManualArticle(
          number: 29,
          title: 'Horario de mudanzas',
          content:
              'Las mudanzas se realizarán únicamente de lunes a sábado entre las 8:00am y las 5:00pm, previa notificación a la administración con 48 horas de antelación.',
        ),
      ],
    ),
    ManualChapter(
      title: 'VI. Seguridad',
      articles: 'Arts. 36 — 42',
      items: [
        ManualArticle(
          number: 36,
          title: 'Control de acceso',
          content:
              'Todo visitante deberá registrarse en portería y ser autorizado por el residente que recibe. Los domiciliarios no podrán subir a los pisos.',
        ),
      ],
    ),
    ManualChapter(
      title: 'VII. Mascotas',
      articles: 'Arts. 43 — 48',
      linkedFines: 2,
      items: [
        ManualArticle(
          number: 43,
          title: 'Tenencia responsable',
          content:
              'Los propietarios de mascotas son responsables de recoger los desechos de sus animales en zonas comunes. Las mascotas deben transitar con correa en todas las áreas comunes.',
        ),
        ManualArticle(
          number: 44,
          title: 'Razas potencialmente peligrosas',
          content:
              'Los propietarios de razas catalogadas como potencialmente peligrosas deberán portar bozal y póliza de responsabilidad civil vigente.',
        ),
      ],
    ),
    ManualChapter(
      title: 'VIII. Sanciones',
      articles: 'Arts. 49 — 55',
      items: [
        ManualArticle(
          number: 49,
          title: 'Procedimiento sancionatorio',
          content:
              'Ante el incumplimiento de este manual, la administración notificará al infractor, quien tendrá 5 días hábiles para presentar descargos antes de la imposición de la multa.',
        ),
        ManualArticle(
          number: 50,
          title: 'Cuantía de las multas',
          content:
              'Las multas serán proporcionales a la gravedad de la falta y podrán ir desde 1 hasta 10 SMLMV, según lo aprobado por la Asamblea General.',
        ),
      ],
    ),
  ];

  List<ManualChapter> get _filteredChapters {
    if (_searchQuery.isEmpty) return _chapters;
    final query = _searchQuery.toLowerCase();
    return _chapters.where((chapter) {
      if (chapter.title.toLowerCase().contains(query)) return true;
      return chapter.items.any(
        (a) =>
            a.title.toLowerCase().contains(query) ||
            a.content.toLowerCase().contains(query),
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _filteredChapters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de Convivencia'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text('v3.2', style: AppTextStyles.caption),
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar en el manual...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Lista de capítulos
          Expanded(
            child: chapters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'No se encontraron resultados',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (_, i) => _ChapterTile(
                      chapter: chapters[i],
                      isExpanded: _expandedChapter == i,
                      searchQuery: _searchQuery,
                      onTap: () {
                        setState(() {
                          _expandedChapter = _expandedChapter == i ? null : i;
                        });
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final ManualChapter chapter;
  final bool isExpanded;
  final String searchQuery;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.isExpanded,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLinkedFines = chapter.linkedFines > 0;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hasLinkedFines && isExpanded
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.05)
                  : null,
              border: const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasLinkedFines
                              ? const Color(0xFF8B5CF6)
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(chapter.articles, style: AppTextStyles.caption),
                          if (hasLinkedFines) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${chapter.linkedFines} multas vinculadas',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...chapter.items.map((article) {
            final matchesSearch =
                searchQuery.isNotEmpty &&
                (article.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    article.content.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ));

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: matchesSearch
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: const Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Art. ${article.number} — ${article.title}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.content,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
