import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lab3/features/user_auth/presentation/pages/calendar_page.dart';
import 'package:lab3/features/user_auth/presentation/pages/login_page.dart';
import 'package:lab3/global/common/toast.dart';
import 'package:intl/intl.dart';
import 'package:lab3/local_notifications.dart';

import '../../../../location_services.dart';
import '../widgets/map_widget.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  late String loggedUserEmail;
  late List<ExamModel> exams;



  @override
  void initState() {
    super.initState();
    // Get the currently logged-in user's email
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    loggedUserEmail = user?.email ?? '';

    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceiveMethod,
        onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceiveMethod,
        onNotificationCreatedMethod:
        NotificationController.onNotificationCreateMethod,
        onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayed);
    _fetchExamsAndScheduleNotifications();

  }
  Future<List<ExamModel>> _getExamsFromFirebase() async {
    // Implement your logic to fetch exams from Firebase
    // Example using cloud_firestore package
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('exams').where('userEmail', isEqualTo: loggedUserEmail).get();

    // Convert the documents to a list of Exam objects
    List<ExamModel> exams = querySnapshot.docs.map((doc) {
      return ExamModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    return exams;
  }

  Future<void> _fetchExamsAndScheduleNotifications() async {
    // Fetch exams from Firebase
    exams = await _getExamsFromFirebase();

    // Schedule notifications for existing exams
    for (int i = 0; i < exams.length; i++) {
      _scheduleNotification(exams[i]);
    }
  }

  void _scheduleNotification(ExamModel exam) {
    final int notificationId = exams.indexOf(exam);

    // Assuming examDate and examTime are DateTime? and TimeOfDay? respectively in ExamModel
    DateTime scheduledTime = DateTime(
      exam.examDate!.year,
      exam.examDate!.month,
      exam.examDate!.day,
      exam.examTime!.hour,
      exam.examTime!.minute,
    ).subtract(const Duration(days: 1));

    scheduleNotificationIfNearUniversity();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: "basic_channel",
        title: exam.examName!,
        body: "You have an exam tomorrow!",
      ),
      schedule: NotificationCalendar(
        day: scheduledTime.day,
        month: scheduledTime.month,
        year: scheduledTime.year,
        hour: scheduledTime.hour,
        minute: scheduledTime.minute,
      ),
    );
  }
  void scheduleNotificationIfNearUniversity() {
    LocationService().determinePosition().then((userPosition) {
      double userLatitude = userPosition.latitude;
      double userLongitude =userPosition.longitude;
      // for testing
      // double userLatitude = 42.004186212873655;
      // double userLongitude = 21.409531941596985;

      // Coordinates of the university
      double universityLatitude = 42.004186212873655;
      double universityLongitude = 21.409531941596985;

      // Calculate the distance between the user's location and the university
      double distance = Geolocator.distanceBetween(userLatitude, userLongitude, universityLatitude, universityLongitude);

      // If the distance is below a certain threshold, schedule a notification
      if (distance < 100) { // You can adjust the threshold distance as needed
        // Schedule the notification here
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Near University',
            body: 'You are near the university check if you have an exam!',
          ),
          schedule: NotificationInterval(interval: 5), // Example: Schedule a notification every 5 seconds
        );
      }
    });
  }
  // this function is for testing if the notifications are appearing
  // void _scheduleNotification(ExamModel exam) {
  //   final int notificationId = exams.indexOf(exam);
  //
  //   // Assuming examDate and examTime are DateTime? and TimeOfDay? respectively in ExamModel
  //   DateTime scheduledTime = DateTime.now().add(Duration(minutes: 1));
  //   print("this is the scheduled time ${scheduledTime}");
  //
  //   scheduleNotificationIfNearUniversity();
  //
  //
  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: notificationId,
  //       channelKey: "basic_channel",
  //       title: exam.examName!,
  //       body: "You have an exam in 2 minutes!",
  //     ),
  //     schedule: NotificationCalendar(
  //       day: scheduledTime.day,
  //       month: scheduledTime.month,
  //       year: scheduledTime.year,
  //       hour: scheduledTime.hour,
  //       minute: scheduledTime.minute,
  //     ),
  //   );
  // }


  // Function to show the dialog for adding exams
  Future<void> _showAddExamDialog(BuildContext context) async {
    String examName = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    // Get the currently logged-in user's email
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? userEmail = user?.email;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Exam'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exam Name
              TextField(
                decoration: const InputDecoration(labelText: 'Exam Name'),
                onChanged: (value) {
                  examName = value;
                },
              ),
              const SizedBox(height: 16),

              // Exam Date
              const Text('Select Exam Date:'),
              InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Exam Time
              const Text('Select Exam Time:'),
              InkWell(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null && pickedTime != selectedTime) {
                    selectedTime = pickedTime;
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(selectedTime.format(context)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle saving exam details here
                //saving the data
                _createData(ExamModel(userEmail:userEmail,examName: examName,examDate: selectedDate,examTime: selectedTime));

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddExamDialog(context); // Show the add exam dialog
            },
          ),
          IconButton(onPressed: _openMap, icon: const Icon(Icons.map)),
          IconButton(onPressed:  () {
            FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LoginPage()),(route)=>false);
            showToast(context,message: "Successfully signed out");
          }, icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("exams")
                .where('userEmail', isEqualTo: loggedUserEmail)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              List<DocumentSnapshot> exams = snapshot.data!.docs;
              return Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 2,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: exams.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildExamCard(exams[index]);
                  },
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
            child: const Text('Exam calendar'),
          ),
        ],
      ),
    );
  }
  Widget _buildExamCard(DocumentSnapshot examSnapshot) {
    Map<String, dynamic> examData = examSnapshot.data() as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            Text(
              examData['examName'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${examData['examDate']}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${examData['examTime']}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createData(ExamModel examModel) {
    final examCollection = FirebaseFirestore.instance.collection("exams");
    String id = examCollection.doc().id;
    final newExam = ExamModel(userEmail:examModel.userEmail, examName:examModel.examName,examDate: examModel.examDate,examTime: examModel.examTime, id: id).toJson();
    examCollection.doc(id).set(newExam);
  }
  void _openMap() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MapWidget()));
  }
}


class ExamModel{
  final String? userEmail;
  final String? examName;
  final DateTime? examDate;
  final TimeOfDay? examTime;
  final String? id;

  ExamModel({this.id, required this.examName, required this.userEmail, required this.examDate, required this.examTime});

  static ExamModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot){
    return ExamModel(
        userEmail: snapshot['userEmail'],
        examName: snapshot['examName'],
        examDate: snapshot['examDate'],
        examTime: _convertStringToTimeOfDay(snapshot['examTime']),
    id: snapshot['id']);
  }
  static TimeOfDay _convertStringToTimeOfDay(String? timeString) {
    if (timeString == null) return TimeOfDay.now();

    List<String> parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat('yyyy-MM-dd').format(date);
  }
  Map<String, dynamic> toJson(){
    return{
      "userEmail": userEmail,
      "examName": examName,
      "examDate":_formatDate(examDate),
      "examTime": "${examTime!.hour}:${examTime!.minute}", // Convert TimeOfDay to String
      "id":id,
    };
  }
  // Factory method to create Exam object from a map
  factory ExamModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExamModel(
      id: documentId,
      examName: map['examName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      examDate: DateTime.parse(map['examDate'] ?? ''),
      examTime: _convertStringToTimeOfDay(map['examTime']),
    );
  }

}