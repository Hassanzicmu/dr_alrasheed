import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dr_abdulaziz_al_rasheed/l10n/app_localizations.dart';
import 'package:dr_abdulaziz_al_rasheed/features/patient/appointments/data/models/appointment_model.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Booking booking;

  const AppointmentDetailsScreen({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointmentDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context, statusColor),
            const SizedBox(height: 32),
            _buildDetailSection(context, l10n.date, _formatDate(booking.date), Icons.calendar_today),
            const SizedBox(height: 16),
            _buildDetailSection(context, l10n.time, _formatTime(booking.time), Icons.access_time),
            const SizedBox(height: 16),
            _buildDetailSection(context, l10n.bookingId, '#${booking.id}', Icons.numbers),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            Text(l10n.clinicInfo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildDetailSection(context, l10n.location, l10n.clinicAddress, Icons.location_on),
            const SizedBox(height: 32),
            if (booking.status.toLowerCase() == 'pending')
              Card(
                color: const Color(0xFFFFF9C4), // light yellow
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.pendingReview,
                          style: const TextStyle(color: Colors.brown),
                        ),
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

  Widget _buildStatusHeader(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            booking.status.toUpperCase(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF3C178B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }
}
