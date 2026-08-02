import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // Instancia única (Singleton)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Función para inicializar las notificaciones
  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS (Apple)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // ¡EL GRAN DESCUBRIMIENTO! 
    // En tu versión, el parámetro se llama 'settings:', no 'initializationSettings:'
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings, // <---- ¡ESTA ES LA SOLUCIÓN DEFINITIVA!
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'nueva_solicitud') {
          navigatorKey.currentState?.pushNamed('/solicitudes');
        }
      },
    );

    // Pedir permiso explícito en Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Función para mostrar la notificación visual
  Future<void> mostrarNotificacion({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jobhub_solicitudes', // ID del canal
      'Nuevas Solicitudes', // Nombre del canal
      channelDescription: 'Notificaciones de nuevos clientes que quieren contratarte',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Este ya estaba perfecto desde el intento anterior
    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }
}