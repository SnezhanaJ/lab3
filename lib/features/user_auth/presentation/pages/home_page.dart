import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab3/features/user_auth/presentation/pages/login_page.dart';
import 'package:lab3/global/common/toast.dart';
import 'package:intl/intl.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  late String loggedUserEmail;


  @override
  void initState() {
    super.initState();
    // Get the currently logged-in user's email
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    loggedUserEmail = user?.email ?? '';
  }

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
          title: Text('Add Exam'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exam Name
              TextField(
                decoration: InputDecoration(labelText: 'Exam Name'),
                onChanged: (value) {
                  examName = value;
                },
              ),
              SizedBox(height: 16),

              // Exam Date
              Text('Select Exam Date:'),
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
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8),
                    Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Exam Time
              Text('Select Exam Time:'),
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
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle saving exam details here
                // Print for now, replace with your logic
                print('Exam Name: $examName');
                print('Exam Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}');
                print('Exam Time: ${selectedTime.format(context)}');

                //saving the data
                _createData(ExamModel(userEmail:userEmail,examName: examName,examDate: selectedDate,examTime: selectedTime));

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Save'),
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
          IconButton(onPressed:  () {
            FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LoginPage()),(route)=>false);
            showToast(context,message: "Successfully signed out");
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("exams")
            .where('userEmail', isEqualTo: loggedUserEmail)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<DocumentSnapshot> exams = snapshot.data!.docs;
          return GridView.builder(
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
          );
        },
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Date: ${examData['examDate']}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Time: ${examData['examTime']}',
              style: TextStyle(
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
      "id":"id"
    };
  }
}