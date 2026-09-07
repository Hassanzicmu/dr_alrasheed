class Slot {
  final String key;
  final String label;

  Slot({required this.key, required this.label});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      key: json['key'],
      label: json['label'],
    );
  }
}

class Booking {
  final int id;
  final String date;
  final String time;
  final String status; // pending, approved, cancelled

  Booking({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      date: json['reservation_date'],
      time: json['reservation_time'],
      status: json['status'] ?? 'pending',
    );
  }
}
