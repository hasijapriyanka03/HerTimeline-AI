import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AppointmentsScreen extends StatefulWidget {
  final String userId;

  const AppointmentsScreen({super.key, required this.userId});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  // Modern mint/teal color palette
  static const Color _primaryMint = Color(0xFF98D8C8);
  static const Color _lightMint = Color(0xFFF0FFF8);
  static const Color _darkMint = Color(0xFF66A896);
  static const Color _backgroundColor = Color(0xFFF5FFF8);
  static const Color _greenAccent = Color(0xFFB8D4C8);
  static const Color _blueAccent = Color(0xFF64B5F6);
  static const Color _purpleAccent = Color(0xFFD4C4E8);
  static const Color _orangeAccent = Color(0xFFFFB74D);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final appointmentsData = await _apiService.getAppointments(widget.userId);
      if (mounted) {
        setState(() {
          _appointments = appointmentsData
              .map((data) => Appointment.fromJson(data))
              .toList();
          _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcomingAppointments = _appointments
        .where((a) => a.isUpcoming && !a.completed)
        .toList();
    final pastAppointments = _appointments
        .where((a) => a.isPast || a.completed)
        .toList();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () => _showAddAppointmentDialog(),
            tooltip: 'Add Appointment',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryMint))
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              color: _primaryMint,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_primaryMint, _lightMint],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryMint.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${upcomingAppointments.length}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Upcoming Appointments',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Upcoming Appointments
                      if (upcomingAppointments.isNotEmpty) ...[
                        const Text(
                          'Upcoming',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...upcomingAppointments.map((appointment) {
                          return _buildAppointmentCard(appointment, false);
                        }).toList(),
                        const SizedBox(height: 32),
                      ],

                      // Past Appointments
                      if (pastAppointments.isNotEmpty) ...[
                        const Text(
                          'Past',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...pastAppointments.map((appointment) {
                          return _buildAppointmentCard(appointment, true);
                        }).toList(),
                      ],

                      // Empty State
                      if (_appointments.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.event_available,
                                size: 80,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No appointments yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first appointment',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isPast) {
    final typeColor = _getTypeColor(appointment.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAppointmentDetails(appointment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date Badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appointment.dateTime.day.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(appointment.dateTime),
                        style: TextStyle(fontSize: 12, color: typeColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointment.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPast ? Colors.black54 : Colors.black87,
                                decoration: appointment.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (appointment.reminderSet)
                            Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: _orangeAccent,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      if (appointment.doctorName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appointment.doctorName!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return _greenAccent;
      case 'ultrasound':
        return _blueAccent;
      case 'test':
        return _purpleAccent;
      case 'consultation':
        return _orangeAccent;
      default:
        return _primaryMint;
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  appointment.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Details
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  appointment.formattedDate,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  appointment.formattedTime,
                ),
                if (appointment.doctorName != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.person,
                    'Doctor',
                    appointment.doctorName!,
                  ),
                ],
                if (appointment.location != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.location_on,
                    'Location',
                    appointment.location!,
                  ),
                ],
                if (appointment.notes != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.notes, 'Notes', appointment.notes!),
                ],
                const SizedBox(height: 24),
                // Actions
                Row(
                  children: [
                    if (!appointment.completed && appointment.isUpcoming)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _markAsCompleted(appointment);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Mark Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _greenAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (!appointment.completed && appointment.isUpcoming)
                      const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteAppointment(appointment);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _lightMint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: _darkMint),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    final doctorController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = 'Checkup';
    bool setReminder = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Add Appointment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title Field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Appointment Title',
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor: _lightMint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      prefixIcon: const Icon(Icons.category),
                      filled: true,
                      fillColor: _lightMint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Checkup', 'Ultrasound', 'Test', 'Consultation']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: _primaryMint,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              setModalState(() => selectedDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _lightMint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: _darkMint,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: _primaryMint,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setModalState(() => selectedTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _lightMint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: _darkMint,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedTime.format(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Doctor Name
                  TextField(
                    controller: doctorController,
                    decoration: InputDecoration(
                      labelText: 'Doctor Name (Optional)',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: _lightMint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Location (Optional)',
                      prefixIcon: const Icon(Icons.location_on),
                      filled: true,
                      fillColor: _lightMint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Notes
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: const Icon(Icons.notes),
                      filled: true,
                      fillColor: _lightMint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reminder Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _lightMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: _darkMint),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Set Reminder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: setReminder,
                          onChanged: (value) {
                            setModalState(() => setReminder = value);
                          },
                          activeColor: _primaryMint,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please enter a title'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }

                        final dateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        final appointment = Appointment(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: widget.userId,
                          title: titleController.text.trim(),
                          dateTime: dateTime,
                          type: selectedType,
                          doctorName: doctorController.text.trim().isEmpty
                              ? null
                              : doctorController.text.trim(),
                          location: locationController.text.trim().isEmpty
                              ? null
                              : locationController.text.trim(),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                          reminderSet: setReminder,
                          completed: false,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        final success = await _apiService.createAppointment(
                          appointment.toJson(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Appointment added! ✓'
                                    : 'Failed to add appointment',
                              ),
                              backgroundColor: success
                                  ? _greenAccent
                                  : Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );

                          if (success) {
                            _loadAppointments();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryMint,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Add Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markAsCompleted(Appointment appointment) async {
    final updated = appointment.copyWith(
      completed: true,
      updatedAt: DateTime.now(),
    );

    final success = await _apiService.updateAppointment(updated.toJson());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Appointment marked as completed! ✓'
                : 'Failed to update appointment',
          ),
          backgroundColor: success ? _greenAccent : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (success) {
        _loadAppointments();
      }
    }
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Appointment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiService.deleteAppointment(
        widget.userId,
        appointment.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Appointment deleted' : 'Failed to delete appointment',
            ),
            backgroundColor: success ? _greenAccent : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (success) {
          _loadAppointments();
        }
      }
    }
  }
}
