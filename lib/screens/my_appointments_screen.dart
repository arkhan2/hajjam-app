import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/appointment.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      List<Appointment> appointments;
      switch (_selectedFilter) {
        case 'upcoming':
          appointments = await _storageService.getUpcomingAppointments(user.id);
          break;
        case 'past':
          appointments = await _storageService.getPastAppointments(user.id);
          break;
        case 'pending':
          appointments = await _storageService.getAppointmentsByStatus(
            user.id,
            'pending',
          );
          break;
        case 'confirmed':
          appointments = await _storageService.getAppointmentsByStatus(
            user.id,
            'confirmed',
          );
          break;
        default:
          appointments = await _storageService.loadAppointments(user.id);
      }
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load appointments: $e');
    }
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
  }

  // Public method to refresh appointments from outside
  void refreshAppointments() {
    _loadAppointments();
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    try {
      await _storageService.deleteAppointment(appointment.id);
      await _loadAppointments();
      _showSuccessSnackBar('Appointment deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete appointment: $e');
    }
  }

  Future<void> _updateAppointmentStatus(
    Appointment appointment,
    String newStatus,
  ) async {
    try {
      final updatedAppointment = appointment.copyWith(status: newStatus);
      await _storageService.updateAppointment(updatedAppointment);
      await _loadAppointments();
      _showSuccessSnackBar('Appointment status updated');
    } catch (e) {
      _showErrorSnackBar('Failed to update appointment: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteConfirmation(Appointment appointment) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Appointment'),
        content: Text(
          'Are you sure you want to delete your ${appointment.serviceName} appointment?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointment);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'upcoming', 'label': 'Upcoming'},
      {'key': 'past', 'label': 'Past'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'confirmed', 'label': 'Confirmed'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter['key']!);
                _loadAppointments();
              },
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(51),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final theme = Theme.of(context);
    final isUpcoming = appointment.dateTime.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withAlpha(25),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _showAppointmentDetails(appointment),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with service name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.serviceName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          appointment.status,
                        ).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment.statusDisplayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(appointment.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date and time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.formattedDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(204),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.formattedTime,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(204),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Customer name
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.customerName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(204),
                      ),
                    ),
                  ],
                ),

                // Notes if available
                if (appointment.notes != null &&
                    appointment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Action buttons
                if (isUpcoming && appointment.status == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateAppointmentStatus(
                            appointment,
                            'confirmed',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateAppointmentStatus(
                            appointment,
                            'cancelled',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Details',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Service', appointment.serviceName),
                    _buildDetailRow('Date', appointment.formattedDate),
                    _buildDetailRow('Time', appointment.formattedTime),
                    _buildDetailRow('Customer', appointment.customerName),
                    _buildDetailRow('Status', appointment.statusDisplayName),
                    if (appointment.notes != null &&
                        appointment.notes!.isNotEmpty)
                      _buildDetailRow('Notes', appointment.notes!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshAppointments,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : _appointments.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshAppointments,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        return Dismissible(
                          key: Key(appointment.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            _showDeleteConfirmation(appointment);
                            return false; // We handle deletion in the confirmation dialog
                          },
                          child: _buildAppointmentCard(appointment),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 64,
              color: theme.colorScheme.primary.withAlpha(77),
            ),
            const SizedBox(height: 16),
            Text(
              'No Appointments',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'You haven\'t booked any appointments yet.'
                  : 'No appointments found for the selected filter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to booking screen
                Navigator.pushNamed(context, '/booking');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
