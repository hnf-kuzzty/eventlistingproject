import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class EventDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context)!.settings.arguments as Event;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null
                  ? Image.network(
                event.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
                  : _buildImagePlaceholder(),
            ),
          ),

          // Event Details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.category,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Event Name
                  Text(
                    event.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Event Info Cards
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date & Time',
                    content: '${_formatDate(event.date)} at ${event.time}',
                  ),
                  SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Location',
                    content: event.location,
                  ),
                  SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.people,
                    title: 'Participants',
                    content:
                    '${event.currentParticipants} / ${event.maxParticipants} registered',
                  ),
                  SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Registration Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final isEventFull = event.currentParticipants >= event.maxParticipants;

                      return CustomButton(
                        text: isEventFull ? 'Event Full' : 'Register for Event',
                        onPressed:
                        isEventFull ? null : () => _handleRegistration(context, event),
                        backgroundColor:
                        isEventFull ? AppColors.textSecondary : AppColors.primary,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.secondary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              size: 64,
              color: AppColors.primary,
            ),
            SizedBox(height: 8),
            Text(
              'Event Image',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleRegistration(BuildContext context, Event event) async {
    final shouldRegister = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register for Event'),
        content: Text('Are you sure you want to register for "${event.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Register'),
          ),
        ],
      ),
    );

    if (shouldRegister == true) {
      // TODO: Replace with actual API registration logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for ${event.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
