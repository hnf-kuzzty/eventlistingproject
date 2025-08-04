import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../models/event.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();


  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Music',
    'Sports',
    'Food',
    'Technology',
    'Art',
    'Business',
  ];

  @override
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedStartDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedEndDate = picked);
    }
  }


  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateMaxParticipants(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Max participants is required';
    }
    final int? number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return 'Please enter a valid number greater than 0';
    }
    return null;
  }

  Future<void> _createEvent() async {
    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select start and end date'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (!_selectedEndDate!.isAfter(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('End date must be after start date'),
        backgroundColor: Colors.red,
      ));
      return;
    }


    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be logged in to create an event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Format date and time as strings to match your API
      final formattedStartDate = '${_selectedStartDate!.year}-${_selectedStartDate!.month.toString().padLeft(2, '0')}-${_selectedStartDate!.day.toString().padLeft(2, '0')}';
      final formattedEndDate = '${_selectedEndDate!.year}-${_selectedEndDate!.month.toString().padLeft(2, '0')}-${_selectedEndDate!.day.toString().padLeft(2, '0')}';
      final formattedTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      print('Start: $formattedStartDate');
      print('End: $formattedEndDate');

      final event = Event(
        id: 0,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        date: formattedStartDate,
        endDate: formattedEndDate,
        time: formattedTime,
        location: _locationController.text.trim(),
        maxParticipants: int.parse(_maxParticipantsController.text.trim()),
        currentParticipants: 0,
        category: _selectedCategory!,
        creatorId: authProvider.user!.id,
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        createdAt: DateTime.now(),
      );


      await eventProvider.createEvent(event);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Event Name',
                hint: 'Enter event name',
                validator: (value) => _validateRequired(value, 'Event name'),
                prefixIcon: Icons.event,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter event description',
                validator: (value) => _validateRequired(value, 'Description'),
                prefixIcon: Icons.description,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter event location',
                validator: (value) => _validateRequired(value, 'Location'),
                prefixIcon: Icons.location_on,
              ),
              SizedBox(height: 16),
// Start Date
              InkWell(
                onTap: _selectStartDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedStartDate == null
                        ? 'Select Start Date'
                        : '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}',
                    style: TextStyle(
                      color: _selectedStartDate == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

// End Date
              InkWell(
                onTap: _selectEndDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedEndDate == null
                        ? 'Select End Date'
                        : '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}',
                    style: TextStyle(
                      color: _selectedEndDate == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Time Selection
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Event Time',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedTime == null
                        ? 'Select Time'
                        : _selectedTime!.format(context),
                    style: TextStyle(
                      color: _selectedTime == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Category Selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _maxParticipantsController,
                label: 'Max Participants',
                hint: 'Enter maximum number of participants',
                validator: _validateMaxParticipants,
                prefixIcon: Icons.people,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _imageUrlController,
                label: 'Image URL (Optional)',
                hint: 'Enter image URL',
                prefixIcon: Icons.image,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 32),
              CustomTextField(
                controller: _priceController,
                label: 'Price',
                hint: 'Enter price (e.g. 10.0)',
                validator: (value) => _validateRequired(value, 'Price'),
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              CustomButton(
                text: 'Create Event',
                onPressed: _isLoading ? null : _createEvent,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}