import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/providers/auth_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/appointments/providers/booking_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/data/models/user_model.dart';

class MedicalHistoryScreen extends ConsumerWidget {
  const MedicalHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final isGuest = authState.isGuest;
    final l10n = AppLocalizations.of(context)!;
    final bookingsAsync = ref.watch(myBookingsProvider);

    if (isGuest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 24),
              Text(
                l10n.loginToBook,
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
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSummary(context, user, l10n),
            const SizedBox(height: 32),
            _buildStatsCard(context, l10n, bookingsAsync),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/edit_profile'),
                icon: const Icon(Icons.edit),
                label: Text(l10n.editProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary(BuildContext context, UserModel? user, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            image: DecorationImage(
              image: (user?.photo != null) 
                  ? NetworkImage(user!.photo!) 
                  : const NetworkImage('https://i.pravatar.cc/300?img=11') as ImageProvider,
              fit: BoxFit.cover,
            )
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.name ?? l10n.patient, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${l10n.email}: ${user?.email ?? "N/A"}', 
                style: Theme.of(context).textTheme.bodyMedium
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.phone}: ${user?.phone ?? "N/A"}', 
                style: Theme.of(context).textTheme.bodyMedium
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, AppLocalizations l10n, AsyncValue bookingsAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.numAppointments,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              bookingsAsync.when(
                data: (bookings) => Text(
                  '${bookings.length}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Text('0'),
              ),
            ],
          ),
          Icon(Icons.calendar_month, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
        ],
      ),
    );
  }
}
