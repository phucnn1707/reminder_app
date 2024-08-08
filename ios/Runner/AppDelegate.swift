import Flutter
import UIKit
import flutter_background_service_ios
import flutter_local_notifications
import flutter_tts
import BackgroundTasks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  // private let backgroundTaskChannel = FlutterMethodChannel(name: "com.example.reminder_app/background_task", binaryMessenger: (UIApplication.shared.delegate as! FlutterAppDelegate).window.rootViewController as! FlutterViewController)
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "dev.flutter.background.refresh"

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    // if #available(iOS 13.0, *) {
    //   BGTaskScheduler.shared.register(forTaskWithIdentifier: "dev.flutter.background.task", using: nil) { task in
    //       self.handleBackgroundTask(task: task as! BGProcessingTask)
    //   }
    // }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // @available(iOS 13.0, *)
  // func handleBackgroundTask(task: BGProcessingTask) {
  //   scheduleBackgroundTask() // Reschedule the background task

  //   let queue = OperationQueue()
  //   queue.maxConcurrentOperationCount = 1
  //   queue.addOperation {
  //     self.performBackgroundTask()
  //     task.setTaskCompleted(success: true)
  //   }

  //   task.expirationHandler = {
  //     queue.cancelAllOperations()
  //     task.setTaskCompleted(success: false)
  //   }
  // }

  // @available(iOS 13.0, *)
  // func performBackgroundTask() {
  //   backgroundTaskChannel.invokeMethod("performBackgroundTask", arguments: nil)
  // }

  // @available(iOS 13.0, *)
  // func scheduleBackgroundTask() {
  //   let request = BGProcessingTaskRequest(identifier: "dev.flutter.background.task")
  //   request.requiresNetworkConnectivity = false
  //   request.requiresExternalPower = false

  //   do {
  //     try BGTaskScheduler.shared.submit(request)
  //   } catch {
  //     print("Could not schedule background task: \(error)")
  //   }
  // }

  // override func applicationDidEnterBackground(_ application: UIApplication) {
  //   if #available(iOS 13.0, *) {
  //     scheduleBackgroundTask()
  //   }
  // }

  func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterTtsPlugin")) {
      FlutterTtsPlugin.register(with: registry.registrar(forPlugin: "FlutterTtsPlugin")!)
    }
  // Register other plugins here if needed
  }
}
