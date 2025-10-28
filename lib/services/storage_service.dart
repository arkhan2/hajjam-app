import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _appointmentsCollection = 'appointments';

  // Save a single appointment
  Future<void> saveAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointment.id)
          .set(appointment.toJson());
    } catch (e) {
      throw Exception('Failed to save appointment: $e');
    }
  }

  // Load all appointments for a user
  Future<List<Appointment>> loadAppointments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data()))
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
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointment.id)
          .update(appointment.toJson());
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // Get appointments by status
  Future<List<Appointment>> getAppointmentsByStatus(
      String userId, String status) async {
    try {
      final snapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .get();
      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get appointments by status: $e');
    }
  }

  // Get upcoming appointments (today and future)
  Future<List<Appointment>> getUpcomingAppointments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('userId', isEqualTo: userId)
          .where('dateTime', isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
          .get();
      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming appointments: $e');
    }
  }

  // Get past appointments
  Future<List<Appointment>> getPastAppointments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('userId', isEqualTo: userId)
          .where('dateTime', isLessThan: DateTime.now().toIso8601String())
          .get();
      return snapshot.docs
          .map((doc) => Appointment.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get past appointments: $e');
    }
  }
}