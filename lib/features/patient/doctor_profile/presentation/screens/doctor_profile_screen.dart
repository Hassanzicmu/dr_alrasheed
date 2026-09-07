import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dr_abdulaziz_al_rasheed/core/providers/locale_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/doctor_profile/providers/doctor_profile_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/doctor_profile/data/models/doctor_profile_model.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/providers/auth_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/appointments/providers/booking_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/appointments/data/models/appointment_model.dart';
import 'package:dr_abdulaziz_al_rasheed/core/utils/auth_utils.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/providers/services_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/data/models/service_model.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/data/models/user_model.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final bookingsAsync = ref.watch(myBookingsProvider);
    final doctorProfileAsync = ref.watch(doctorProfileProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(context, user),
            _buildAppointmentReminder(context, ref, bookingsAsync),
            const SizedBox(height: 16),
            doctorProfileAsync.when(
              data: (profile) {
                final name = isAr ? profile.nameAr : profile.nameEn;
                final title = isAr ? profile.titleAr : profile.titleEn;
                final info = isAr ? profile.infoAr : profile.infoEn;

                // Increased truncation length for the home screen
                String shortInfo = info;
                if (info.length > 350) {
                  shortInfo = info.substring(0, 350) + '...';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context, name, title, profile.photo, l10n),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Html(data: shortInfo),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextButton(
                        onPressed: () {
                          context.push('/doctor_details');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.readMore),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Error loading profile: $err')),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, l10n.services),
            servicesAsync.when(
              data: (services) => _buildServicesGrid(context, services, isAr),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              performActionWithAuthCheck(context, ref, () {
                context.push('/book_appointment');
              });
            },
            child: Text(l10n.bookAppointment),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<Service> services, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: services.length > 4 ? 4 : services.length, // Show top 4 on home
        itemBuilder: (context, index) {
          final service = services[index];
          final title = isAr ? service.titleAr : service.titleEn;
          final icon = _getServiceIcon(service.id);

          return GestureDetector(
            onTap: () => context.push('/service_details/${service.id}'),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getServiceIcon(int id) {
    // Dynamic icon assignment based on service ID or type
    switch (id) {
      case 1: return Icons.monitor_heart;
      case 2: return Icons.psychology;
      case 3: return Icons.health_and_safety;
      default: return Icons.medical_services;
    }
  }

  Widget _buildPatientHeader(BuildContext context, UserModel? user) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.hello,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              Text(
                user?.name ?? l10n.patient,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (user?.photo != null)
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(user!.photo!),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentReminder(BuildContext context, WidgetRef ref, AsyncValue<List<Booking>> bookingsAsync) {
    final l10n = AppLocalizations.of(context)!;
    return bookingsAsync.when(
      data: (bookings) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final upcoming = bookings.where((b) {
          try {
            final date = DateFormat('yyyy-MM-dd').parse(b.date);
            return !date.isBefore(today);
          } catch (e) {
            return false;
          }
        }).toList();

        if (upcoming.isEmpty) return const SizedBox.shrink();

        // Soonest first
        upcoming.sort((a, b) {
          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;
          return a.time.compareTo(b.time);
        });

        final nextBooking = upcoming.first;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: GestureDetector(
            onTap: () => context.push('/appointment_details', extra: nextBooking),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3C178B), Color(0xFF5B34AC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3C178B).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.nextAppointment,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDate(nextBooking.date)} at ${_formatTime(nextBooking.time)}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String title, String? photoUrl, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              image: photoUrl != null ? DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              ) : const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/300?img=47'),
                fit: BoxFit.cover,
              )
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    const Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text(l10n.reviewsCount, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
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
