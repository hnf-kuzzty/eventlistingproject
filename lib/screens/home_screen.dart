import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Initialize auth if not already done
      if (!authProvider.isInitialized) {
        await authProvider.checkAuthStatus();
      }

      // Load events if authenticated
      if (authProvider.isAuthenticated) {
        Provider.of<EventProvider>(context, listen: false).loadEvents();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<EventProvider>(context, listen: false).loadEvents();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (eventProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${eventProvider.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => eventProvider.loadEvents(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => eventProvider.loadEvents(),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          eventProvider.updateSearchQuery('');
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onChanged: (value) {
                      eventProvider.updateSearchQuery(value);
                    },
                  ),
                ),
                // Category Filters
                Container(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      FilterChip(
                        label: Text('All'),
                        selected: eventProvider.selectedCategory == null,
                        onSelected: (_) => eventProvider.updateCategoryFilter(null),
                      ),
                      SizedBox(width: 8),
                      ...['Music', 'Sports', 'Food', 'Technology', 'Art', 'Business']
                          .map((category) => Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: eventProvider.selectedCategory == category,
                          onSelected: (_) => eventProvider.updateCategoryFilter(category),
                        ),
                      ))
                          .toList(),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Events List
                Expanded(
                  child: eventProvider.displayedEvents.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (eventProvider.searchQuery.isNotEmpty ||
                            eventProvider.selectedCategory != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Try adjusting your filters',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: eventProvider.displayedEvents.length,
                    itemBuilder: (context, index) {
                      final event = eventProvider.displayedEvents[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/event-detail',
                            arguments: event,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/create-event');
          if (result == true) {
            // Refresh events if a new event was created
            Provider.of<EventProvider>(context, listen: false).loadEvents();
          }
        },
        icon: Icon(Icons.add),
        label: Text('Create Event'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
