import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/features/auth/providers/auth_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/core/providers/locale_provider.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/doctor_profile/presentation/screens/doctor_profile_screen.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/medical_history/presentation/screens/medical_history_screen.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/home/presentation/screens/clinic_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DoctorProfileScreen(),
    MyAppointmentsScreen(),
    ClinicScreen(),
    MedicalHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.name ?? l10n.patient,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: Text(l10n.home),
                    onTap: () {
                      context.pop();
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(l10n.appointments),
                    onTap: () {
                      context.pop();
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.aboutDoctor),
                    onTap: () {
                      context.pop();
                      context.push('/doctor_details');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text(l10n.services),
                    onTap: () {
                      context.pop();
                      context.push('/services');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(l10n.team),
                    onTap: () {
                      context.pop();
                      context.push('/team');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: Text(l10n.clinic),
                    onTap: () {
                      context.pop();
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: Text(l10n.socialMedia),
                    onTap: () {
                      context.pop();
                      context.push('/social_media');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(l10n.settings),
                    onTap: () {
                      context.pop();
                      context.push('/settings');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
                    onTap: () {
                      ref.read(authStateProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                l10n.copyright,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 16),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Use fixed to show all labels for 4 items
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: l10n.appointments),
          BottomNavigationBarItem(icon: const Icon(Icons.local_hospital), label: l10n.clinic),
          BottomNavigationBarItem(icon: const Icon(Icons.account_circle), label: l10n.profile),
        ],
      ),
    );
  }
}
