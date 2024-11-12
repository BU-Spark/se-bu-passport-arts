import 'dart:collection';

import 'package:bu_passport/components/event_filter.dart';
import 'package:bu_passport/components/event_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../classes/event.dart';
import '../services/firebase_service.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final user = FirebaseAuth.instance.currentUser?.uid ?? "";
  final db = FirebaseFirestore.instance;
  List<Event> eventList = [];
  late Future<List<Event>> fetchEventsFuture;
  HashSet<String> categories = HashSet<String>();
  HashSet<String> locations = HashSet<String>();
  bool showFilters = false;
  FirebaseService firebaseService =
  FirebaseService(db: FirebaseFirestore.instance);
  Map<String, dynamic> _filters = {
    'range': null,
    'search': '',
    'categoryIndex': [],
    'categoryList': [],
    'location': "",
  };
  bool _isFilterActive = false;


  @override
  void initState() {
    super.initState();
    fetchEventsFuture = firebaseService.fetchEventsFromNow();

  }

  void updateEventPage() {
    setState(() {
      fetchEventsFuture = firebaseService.fetchEventsFromNow();
    });
  }

  void onApplyFilters(RangeValues ptsRange, List<int> selectedChips, List<String> categoryList, bool isFilterActive, String location){
    setState(() {
      _filters['range'] = ptsRange;
      _filters['categoryIndex'] = selectedChips;
      _filters['categoryList'] = categoryList;
      _filters['location'] = location=="All places"?"":location;
      _isFilterActive = isFilterActive;
    });
  }
  void onResetFilters(){

  }

  void goBackToEvents(){
    showFilters=false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = (MediaQuery.of(context).size.height * 0.05);
    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.list : Icons.filter_alt_rounded, // Switch icons
            ),
            color: _isFilterActive&&(!showFilters) ? Theme.of(context).primaryColor : Colors.grey.shade700,
            onPressed: () {
              setState(() {
                showFilters = !showFilters; // Toggle view
              });
            },
          ),
        ],
      ),
      body: Center(
        child: showFilters
            ? // Display filter view
        FilterWidget(
          onApplyFilters: onApplyFilters,
          onResetFilters: onResetFilters,
          initRange: _filters['range'],
          categories: categories,
          locations: locations,
          goBackToEvents: goBackToEvents,
          selectedChips: (_filters['categoryIndex'] as List<dynamic>).map((item) => item as int)
              .toList(),
          selectedLocation: _filters['location'] == "" ? "All places" :_filters['location'].toString(),
        )
            : // Display event list view
        ListView(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _filters["search"] = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            FutureBuilder<List<Event>>(
              future: fetchEventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Event>? events = snapshot.data;

                  if (events != null && events.isNotEmpty) {
                    // get all categories
                    for(Event e in events){
                      locations.add(e.eventLocation);
                      for(String s in e.eventCategories){
                        categories.add(s);
                        //print(s);
                      }
                    }
                    //
                    List<Event> filteredEvents =
                    firebaseService.filterEvents(events, _filters);
                    return Padding(
                      padding: EdgeInsets.all(edgeInsets * 1.5),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: filteredEvents.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: sizedBoxHeight * 0.4);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return EventWidget(
                            event: filteredEvents[index],
                            onUpdateEventPage: updateEventPage,
                          );
                        },
                      ),
                    );
                  } else {
                    return Text('No events found');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
