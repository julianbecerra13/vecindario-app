import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/amenity_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/services/payment_service.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

/// Zonas sociales - ambas capas:
/// Admin: configura zonas, ve reservas, devuelve depósitos
/// Residente: ve disponibilidad, reserva y paga
class AmenitiesScreen extends ConsumerWidget {
  const AmenitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amenitiesAsync = ref.watch(amenitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zonas Sociales')),
      body: amenitiesAsync.when(
        data: (amenities) {
          if (amenities.isEmpty) {
            return const EmptyState(
              icon: Icons.pool,
              title: 'Sin zonas configuradas',
              subtitle: 'Las zonas sociales de tu conjunto aparecerán aquí',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: amenities.length,
            itemBuilder: (_, i) => _AmenityCard(amenity: amenities[i]),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AmenityCard extends StatelessWidget {
  final AmenityModel amenity;

  const _AmenityCard({required this.amenity});

  IconData get _icon {
    final name = amenity.name.toLowerCase();
    if (name.contains('piscina') || name.contains('pool')) return Icons.pool;
    if (name.contains('bbq') || name.contains('asadero')) return Icons.outdoor_grill;
    if (name.contains('salón') || name.contains('salon')) return Icons.celebration;
    if (name.contains('cancha')) return Icons.sports_soccer;
    if (name.contains('gym') || name.contains('gimnasio')) return Icons.fitness_center;
    return Icons.meeting_room;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _AmenityBookingSheet(amenity: amenity),
          );
        },
        child: Padding(
          padding: AppSizes.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Icon(_icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amenity.name,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          amenity.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textHint),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.only(top: AppSizes.sm),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    _InfoChip(icon: Icons.people, text: '${amenity.capacity} personas'),
                    const SizedBox(width: AppSizes.md),
                    _InfoChip(icon: Icons.access_time, text: amenity.hours),
                    const Spacer(),
                    Text(
                      formatCOP(amenity.hourlyRate),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (amenity.deposit != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xs),
                  child: Text(
                    'Depósito reembolsable: ${formatCOP(amenity.deposit!)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla de reserva con calendario
class _AmenityBookingSheet extends ConsumerStatefulWidget {
  final AmenityModel amenity;

  const _AmenityBookingSheet({required this.amenity});

  @override
  ConsumerState<_AmenityBookingSheet> createState() => _AmenityBookingSheetState();
}

class _AmenityBookingSheetState extends ConsumerState<_AmenityBookingSheet> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  Set<int> _bookedDays = {};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) return;
    final bookings = await ref
        .read(premiumRepositoryProvider)
        .watchBookings(communityId, widget.amenity.id)
        .first;
    if (mounted) {
      setState(() {
        _bookedDays = bookings
            .where((b) =>
                b.status == BookingStatus.confirmed &&
                b.date.year == _currentMonth.year &&
                b.date.month == _currentMonth.month)
            .map((b) => b.date.day)
            .toSet();
      });
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1=Mon
    final monthName = _monthName(_currentMonth.month);
    final totalCost = widget.amenity.hourlyRate + (widget.amenity.deposit ?? 0);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Nombre zona
          Text(
            widget.amenity.name,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSizes.sm),
          // Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Capacidad: ${widget.amenity.capacity} personas',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        'Tarifa: ${formatCOP(widget.amenity.hourlyRate)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (widget.amenity.deposit != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Depósito: ${formatCOP(widget.amenity.deposit!)} (reembolsable)',
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Navegación mes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '$monthName ${_currentMonth.year}',
                style: AppTextStyles.heading3,
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // Header días
          Row(
            children: ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // Grid calendario
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemCount: firstWeekday - 1 + daysInMonth,
            itemBuilder: (_, index) {
              if (index < firstWeekday - 1) return const SizedBox.shrink();
              final day = index - (firstWeekday - 1) + 1;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final isBooked = _bookedDays.contains(day);
              final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
              final isSelected = _selectedDate != null &&
                  _selectedDate!.day == day &&
                  _selectedDate!.month == _currentMonth.month;

              Color bgColor;
              Color textColor;
              if (isSelected) {
                bgColor = AppColors.success;
                textColor = Colors.white;
              } else if (isBooked) {
                bgColor = AppColors.error.withValues(alpha: 0.15);
                textColor = AppColors.error;
              } else if (isPast) {
                bgColor = Colors.transparent;
                textColor = AppColors.textHint;
              } else {
                bgColor = AppColors.success.withValues(alpha: 0.1);
                textColor = AppColors.success;
              }

              return GestureDetector(
                onTap: (isBooked || isPast)
                    ? null
                    : () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.sm),

          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.success.withValues(alpha: 0.15), label: 'Disponible'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.error.withValues(alpha: 0.15), label: 'Reservado'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.success, label: 'Seleccionado'),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Detalle de reserva seleccionada
          if (_selectedDate != null) ...[
            Card(
              color: AppColors.success.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(_selectedDate!),
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('Horario: ${widget.amenity.hours}', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Alquiler + depósito', style: AppTextStyles.caption),
                        Text(
                          formatCOP(totalCost),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _selectedDate == null
                    ? null
                    : () async {
                        final communityId = ref.read(currentCommunityIdProvider);
                        final user = ref.read(currentUserProvider).value;
                        if (communityId == null || user == null) return;

                        final booking = BookingModel(
                          id: '',
                          amenityId: widget.amenity.id,
                          amenityName: widget.amenity.name,
                          residentUid: user.id,
                          residentName: user.displayName,
                          date: _selectedDate!,
                          startTime: widget.amenity.hours ?? '8:00',
                          endTime: '22:00',
                          totalPaid: widget.amenity.totalCost,
                          depositPaid: widget.amenity.deposit,
                          createdAt: DateTime.now(),
                        );
                        await ref
                            .read(premiumRepositoryProvider)
                            .createBooking(communityId, booking);

                        // Abrir pago
                        final paymentService = ref.read(paymentServiceProvider);
                        await paymentService.startPayment(
                          reference: PaymentService.generateReference(
                              PaymentType.booking, widget.amenity.id),
                          amountCOP: widget.amenity.totalCost,
                          customerEmail: user.email,
                          type: PaymentType.booking,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Reserva creada')),
                          );
                        }
                      },
                icon: const Icon(Icons.credit_card),
                label: const Text('Pagar y Reservar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return '${days[date.weekday - 1]} ${date.day} de ${_monthName(date.month).toLowerCase()}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ],
    );
  }
}
