import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class StorageService {
  static const String _appointmentsKey = 'appointments';
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Save a single appointment
  Future<void> saveAppointment(Appointment appointment) async {
    try {
      final appointments = await loadAppointments();
      appointments.add(appointment);
      await _saveAppointments(appointments);
    } catch (e) {
      throw Exception('Failed to save appointment: $e');
    }
  }

  // Load all appointments
  Future<List<Appointment>> loadAppointments() async {
    try {
      final appointmentsJson = _prefs!.getStringList(_appointmentsKey) ?? [];
      return appointmentsJson
          .map((jsonString) => Appointment.fromJson(jsonDecode(jsonString)))
          .toList()
        ..sort(
          (a, b) => b.dateTime.compareTo(a.dateTime),
        ); // Sort by date, newest first
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  // Update an existing appointment
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      final appointments = await loadAppointments();
      final index = appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        appointments[index] = appointment;
        await _saveAppointments(appointments);
      } else {
        throw Exception('Appointment not found');
      }
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final appointments = await loadAppointments();
      appointments.removeWhere(
        (appointment) => appointment.id == appointmentId,
      );
      await _saveAppointments(appointments);
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // Get appointments by status
  Future<List<Appointment>> getAppointmentsByStatus(String status) async {
    try {
      final appointments = await loadAppointments();
      return appointments
          .where((appointment) => appointment.status == status)
          .toList();
    } catch (e) {
      throw Exception('Failed to get appointments by status: $e');
    }
  }

  // Get upcoming appointments (today and future)
  Future<List<Appointment>> getUpcomingAppointments() async {
    try {
      final appointments = await loadAppointments();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return appointments.where((appointment) {
        final appointmentDate = DateTime(
          appointment.dateTime.year,
          appointment.dateTime.month,
          appointment.dateTime.day,
        );
        return appointmentDate.isAtSameMomentAs(today) ||
            appointmentDate.isAfter(today);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming appointments: $e');
    }
  }

  // Get past appointments
  Future<List<Appointment>> getPastAppointments() async {
    try {
      final appointments = await loadAppointments();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return appointments.where((appointment) {
        final appointmentDate = DateTime(
          appointment.dateTime.year,
          appointment.dateTime.month,
          appointment.dateTime.day,
        );
        return appointmentDate.isBefore(today);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get past appointments: $e');
    }
  }

  // Clear all appointments (for testing or reset)
  Future<void> clearAllAppointments() async {
    try {
      await _prefs!.remove(_appointmentsKey);
    } catch (e) {
      throw Exception('Failed to clear appointments: $e');
    }
  }

  // Get appointment count
  Future<int> getAppointmentCount() async {
    try {
      final appointments = await loadAppointments();
      return appointments.length;
    } catch (e) {
      throw Exception('Failed to get appointment count: $e');
    }
  }

  // Check if appointment exists
  Future<bool> appointmentExists(String appointmentId) async {
    try {
      final appointments = await loadAppointments();
      return appointments.any((appointment) => appointment.id == appointmentId);
    } catch (e) {
      throw Exception('Failed to check if appointment exists: $e');
    }
  }

  // Private method to save appointments list
  Future<void> _saveAppointments(List<Appointment> appointments) async {
    final appointmentsJson = appointments
        .map((appointment) => jsonEncode(appointment.toJson()))
        .toList();
    await _prefs!.setStringList(_appointmentsKey, appointmentsJson);
  }

  // Export appointments as JSON string (for backup)
  Future<String> exportAppointments() async {
    try {
      final appointments = await loadAppointments();
      final appointmentsJson = appointments.map((a) => a.toJson()).toList();
      return jsonEncode(appointmentsJson);
    } catch (e) {
      throw Exception('Failed to export appointments: $e');
    }
  }

  // Import appointments from JSON string (for restore)
  Future<void> importAppointments(String jsonString) async {
    try {
      final List<dynamic> appointmentsJson = jsonDecode(jsonString);
      final appointments = appointmentsJson
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
      await _saveAppointments(appointments);
    } catch (e) {
      throw Exception('Failed to import appointments: $e');
    }
  }
}
