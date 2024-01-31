// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
//
// class NotificationService {
//   static final NotificationService _notificationService =
//   NotificationService._internal();
//
//   factory NotificationService() {
//     return _notificationService;
//   }
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   NotificationService._internal();
//
//   Future<void> initNotification() async {
//
//     // Android initialization
//     const AndroidInitializationSettings initializationSettingsAndroid =
//      AndroidInitializationSettings('@mipmap/ic_launcher');
//
//
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: initializationSettingsAndroid);
//     // the initialization settings are initialized after they are setted
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   Future<void> showNotification(int id, String title, String body,) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.now(tz.local).add(const Duration(
//           seconds: 1)), //schedule the notification to show after 2 seconds.
//       const NotificationDetails(
//
//         // Android details
//         android: AndroidNotificationDetails('main_channel', 'Main Channel',
//             channelDescription: "snowy",
//             importance: Importance.max,
//             priority: Priority.max)
//       ),
//
//       // Type of time interpretation
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       androidAllowWhileIdle: true, // To show notification even when the app is closed
//     );
    // const AndroidNotificationDetails androidNotificationDetails =
    // AndroidNotificationDetails(
    //   'periodic_channel',
    //   'Periodic Channel',
    //   channelDescription: 'Periodic notifications',
    //   importance: Importance.max,
    //   priority: Priority.max,
    // );
    //
    // const NotificationDetails notificationDetails =
    // NotificationDetails(android: androidNotificationDetails);
    //
    // await flutterLocalNotificationsPlugin.periodicallyShow(
    //   id,
    //   title,
    //   body,
    //   RepeatInterval.everyMinute, // You can adjust the interval as needed
    //   notificationDetails,
    //   androidAllowWhileIdle: true,
    // );
//   }
// }
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreateMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayed(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceiveMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceiveMethod(
      ReceivedNotification receivedNotification) async {}
}