import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lab3/features/app/splash_screen/splash_screen.dart';
import 'package:lab3/firebase_options.dart';
import 'package:lab3/local_notifications.dart';

import 'features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

Future main() async {
   WidgetsFlutterBinding.ensureInitialized();
   // Initialize timezone
   // tz.initializeTimeZones();
   // tz.setLocalLocation(tz.getLocation('Europe/Belgrade')); // Replace with your actual timezone
   // NotificationService().initNotification();
   await AwesomeNotifications().initialize(null, [
     NotificationChannel(
       channelGroupKey: "basic_channel_group",
       channelKey: "basic_channel",
       channelName: "basic_notif",
       channelDescription: "basic notification channel",
     )
   ], channelGroups: [
     NotificationChannelGroup(
         channelGroupKey: "basic_channel_group", channelGroupName: "basic_group")
   ]);

   bool isAllowedToSendNotification =
   await AwesomeNotifications().isNotificationAllowed();

   if (!isAllowedToSendNotification) {
     AwesomeNotifications().requestPermissionToSendNotifications();
   }

   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   Fluttertoast.showToast(msg: "App Started");
   runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

}
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // // Initialise  localnotification
    // LocalNotifications.initialize();
    // LocalNotifications.messageListener(context);
    //
    // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    // // To initialise the sg
    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //     print("Initial message ${message.toString()}");
    // });
    //
    // // To initialise when app is not terminated
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   if (message.notification != null) {
    //     print("Message on App opened ${message.toString()}");
    //   }
    // });
    //
    // // To handle when app is open in
    // // user divide and heshe is using it
    // FirebaseMessaging.onMessage.listen((message) {
    //   print("Message when it is termination mode ${message.toString()}");
    //   if(message.notification != null) {
    //     LocalNotifications.display(message);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Flutter Firebase',
      home: SplashScreen(
        child: LoginPage(),
      ),
    );
  }
}
