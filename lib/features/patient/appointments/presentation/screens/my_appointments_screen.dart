import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/appointments/providers/booking_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/appointments/data/models/appointment_model.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/providers/auth_provider.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isGuest = authState.isGuest;
    final l10n = AppLocalizations.of(context)!;

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appointments)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 24),
                Text(
                  l10n.loginToBook, // Using an existing key or I should add a specific one
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                    context.go('/login');
                  },
                  child: Text(l10n.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bookingsAsync = ref.watch(myBookingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF3C178B),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF3C178B),
              tabs: [
                Tab(text: l10n.upcoming),
                Tab(text: l10n.older),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myBookingsProvider);
            return ref.read(myBookingsProvider.future);
          },
          child: bookingsAsync.when(
            data: (bookings) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              
              final upcoming = bookings.where((b) {
                try {
                  final date = DateFormat('yyyy-MM-dd').parse(b.date);
                  return !date.isBefore(today);
                } catch (e) {
                  return true; // Default to upcoming if parse fails
                }
              }).toList();

              final older = bookings.where((b) {
                try {
                  final date = DateFormat('yyyy-MM-dd').parse(b.date);
                  return date.isBefore(today);
                } catch (e) {
                  return false;
                }
              }).toList();

              // Sort upcoming: soonest first
              upcoming.sort((a, b) {
                final dateCompare = a.date.compareTo(b.date);
                if (dateCompare != 0) return dateCompare;
                return a.time.compareTo(b.time);
              });

              // Sort older: most recent first
              older.sort((a, b) {
                final dateCompare = b.date.compareTo(a.date);
                if (dateCompare != 0) return dateCompare;
                return b.time.compareTo(a.time);
              });

              return TabBarView(
                children: [
                  _buildAppointmentList(context, upcoming, isUpcoming: true),
                  _buildAppointmentList(context, older, isUpcoming: false),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Text('${l10n.error} $err'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context, List<Booking> bookings, {required bool isUpcoming}) {
    final l10n = AppLocalizations.of(context)!;
    if (bookings.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                isUpcoming ? l10n.noUpcoming : l10n.noOlder,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GestureDetector(
          onTap: () => context.push('/appointment_details', extra: booking),
          child: _buildAppointmentCard(context, booking, isFeatured: isUpcoming && index == 0),
        );
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Booking booking, {bool isFeatured = false}) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    switch (booking.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isFeatured ? 24 : 16),
      decoration: BoxDecoration(
        color: isFeatured ? const Color(0xFF3C178B).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isFeatured ? Border.all(color: const Color(0xFF3C178B).withOpacity(0.2), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3C178B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.nextAppointment,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.appointment} #${booking.id}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isFeatured ? const Color(0xFF3C178B) : Colors.grey,
                  fontWeight: isFeatured ? FontWeight.bold : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Color(0xFF3C178B)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _formatDate(booking.date),
                        style: TextStyle(
                          fontWeight: FontWeight.w600, 
                          fontSize: isFeatured ? 18 : 15,
                          color: isFeatured ? const Color(0xFF3C178B) : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: isFeatured ? 22 : 18, color: const Color(0xFF3C178B)),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(booking.time),
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: isFeatured ? 18 : 15,
                      color: isFeatured ? const Color(0xFF3C178B) : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}
