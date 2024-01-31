import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;
  late String loggedUserEmail;
  Map<DateTime, List<Event>> events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState(){
    super.initState();
    _selectedDay = today;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    loggedUserEmail = user?.email ?? '';
    // await _fetchExamsForUser(loggedUserEmail); // Wait for data to be fetched
    // setState(() {}); // Trigger a rebuild after fetching data
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchExamsForUser(loggedUserEmail);
    setState(() {}); // Trigger a rebuild after fetching data
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
 }

  Future<void> _fetchExamsForUser(String userEmail) async {
    events.clear(); // Clear existing events before fetching new data
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('exams')
        .where('userEmail', isEqualTo: loggedUserEmail)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in querySnapshot.docs) {
      final Map<String, dynamic> data = document.data();
      final String examDate = data['examDate'];
      final String examName = data['examName'];

      // Assuming the date format is 'yyyy-MM-dd', you can parse it if needed
      final DateTime parsedExamDate = DateTime.parse(examDate);

      events.putIfAbsent(parsedExamDate, () => []);
      events[parsedExamDate]!.add(Event(examName));

      // Calculate minutes until the exam date
      DateTime now = DateTime.now();
      int minutesUntilExamDate = parsedExamDate.difference(now).inMinutes;

    }
  }

  List<Event> _getEventsForDay(DateTime day){
    final DateTime dayWithoutTime = DateTime(day.year, day.month, day.day);
    return events[dayWithoutTime] ?? [];
    //return events[day] ?? [];
  }


  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      _selectedEvents.value = _getEventsForDay(day);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Calendar"),
      ),
      body: Column(
        children: [
          Container(
            child: TableCalendar(
              focusedDay: today,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) => isSameDay(day, today),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.value.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents.value[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(12),
                  ),child: ListTile(
                  title: Text(event.title ?? ''),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

class Event{
  final String? title;
  Event(this.title);
}