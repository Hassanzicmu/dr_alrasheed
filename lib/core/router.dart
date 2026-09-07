import 'package:go_router/go_router.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/patient/home/presentation/screens/home_screen.dart';
import '../features/patient/appointments/presentation/screens/book_appointment_screen.dart';
import '../features/patient/appointments/presentation/screens/appointment_details_screen.dart';
import '../features/patient/appointments/data/models/appointment_model.dart';
import '../features/patient/doctor_profile/presentation/screens/doctor_details_screen.dart';
import '../features/patient/home/presentation/screens/services_screen.dart';
import '../features/patient/home/presentation/screens/service_details_screen.dart';
import '../features/patient/home/presentation/screens/team_screen.dart';
import '../features/patient/home/presentation/screens/settings_screen.dart';
import '../features/patient/profile/presentation/screens/edit_profile_screen.dart';
import '../features/patient/home/presentation/screens/social_media_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/book_appointment',
      builder: (context, state) => const BookAppointmentScreen(),
    ),
    GoRoute(
      path: '/appointment_details',
      builder: (context, state) {
        final booking = state.extra as Booking;
        return AppointmentDetailsScreen(booking: booking);
      },
    ),
    GoRoute(
      path: '/doctor_details',
      builder: (context, state) => const DoctorDetailsScreen(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: '/service_details/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ServiceDetailedPage(serviceId: id);
      },
    ),
    GoRoute(
      path: '/team',
      builder: (context, state) => const TeamScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/edit_profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/social_media',
      builder: (context, state) => const SocialMediaScreen(),
    ),
  ],
);
