import Flutter
import UIKit
import flutter_local_notifications   
import workmanager 
import flutter_tts
// import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? 
  ) -> Bool {

    // do {
    //   let audioSession = AVAudioSession.sharedInstance()
    //   try audioSession.setCategory(.playAndRecord, mode: .default)
    //   try audioSession.setActive(true)
    // } catch {
    //   print("Failed to set up audio session: \(error)")
    // }

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in 
      GeneratedPluginRegistrant.register(with: registry)
    }

    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "task-identifier")

    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh", frequency: NSNumber(value: 20 * 60))

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterTtsPlugin")) {
      FlutterTtsPlugin.register(with: registry.registrar(forPlugin: "FlutterTtsPlugin")!)
    }
  // Register other plugins here if needed
  }
}
