
/**
* This class is the cordova native interface code that calls the LocalNotification.
*/
import UserNotifications


@objc(LocalNotification) class LocalNotification : CDVPlugin {
	
	@objc(requestPermission:) func requestPermission(command: CDVInvokedUrlCommand) {
		// possible options include: [.alert, .badge, .sound]
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [], completionHandler: { (granted: Bool, error: Error?) in
			if (error != nil) {
				print("ERROR LocalNotification.requestAuthorization \(error)")
			}
			print("GRANTED \(granted)")
			let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: granted)
			self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
		})
	}
	
	@objc(schedule:) func schedule(command: CDVInvokedUrlCommand) {
		let id: String = command.arguments[0] as? String ?? ""
		let title: String = command.arguments[1] as? String ?? ""
		let body: String = command.arguments[2] as? String ?? ""
		let when: Double = command.arguments[3] as? Double ?? 0.0
		let data: String = command.arguments[4] as? String ?? ""
		
		print("ID \(id)  TITLE \(title)  BODY \(body)  WHEN \(when)")
		
		let content = UNMutableNotificationContent()
		content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
		content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
		content.userInfo = ["data": data]
		
		let datetime = Date(timeIntervalSince1970: when/1000)
		let calendar = Calendar(identifier: .gregorian)
		let units: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
		let components: DateComponents = calendar.dateComponents(units, from: datetime)
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
		let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
		
		let center = UNUserNotificationCenter.current()
		center.add(request, withCompletionHandler: { (error: Error?) in
			var pluginResult: CDVPluginResult
		    if let theError = error {
		        print(theError.localizedDescription)
		        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: theError.localizedDescription)
		    } else {
			    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
		    }
		    self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
		})
	}
	
	@objc(getScheduledIds:) func getScheduledIds(command: CDVInvokedUrlCommand) {
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests(completionHandler: { (notifications: [UNNotificationRequest]) in
			var ids: [String] = []
			for note in notifications {
				print("SCHED NOTE \(note)")
				ids.append(note.identifier)
			}
			print("IDS \(ids)")
			let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ids)
			self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
		})
	}
	
	@objc(getTriggeredIds:) func getTriggeredIds(command: CDVInvokedUrlCommand) {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications(completionHandler: { (notifications: [UNNotification]) in
            var ids: [String] = []
            for note in notifications {
                print("TRIG NOTE \(note)")
                ids.append(note.request.identifier)
            }
            print("TRIG IDS \(ids)")
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: ids)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        })
	}
	
	@objc(getScheduledById:) func getScheduledById(command: CDVInvokedUrlCommand) {
		let id: String = command.arguments[0] as? String ?? ""
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests(completionHandler: { (notifications: [UNNotificationRequest]) in
			var selectedNote: UNNotificationRequest? = nil
			for note in notifications {
				print("SCHED NOTE \(note)")
				if (note.identifier == id) {
					selectedNote = note
				}
			}
			let returnObj: Dictionary? = self.notification2Dictionary(note: selectedNote)
			let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: returnObj)
			self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
		})
	}
	
	@objc(getTriggeredById:) func getTriggeredById(command: CDVInvokedUrlCommand) {
		let id: String = command.arguments[0] as? String ?? ""
		let center = UNUserNotificationCenter.current()
		center.getDeliveredNotifications(completionHandler: { (notifications: [UNNotification]) in
			var selectedNote: UNNotificationRequest? = nil
            for note in notifications {
                print("TRIG NOTE \(note)")
                if (note.request.identifier == id) {
	                selectedNote = note.request
                }
            }
            let returnObj: Dictionary? = self.notification2Dictionary(note: selectedNote)
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: returnObj)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        })
	}
	
	func notification2Dictionary(note: UNNotificationRequest?) -> Dictionary<String, String>? {
		if (note == nil) {
			return nil
		} else {
			var obj: Dictionary = [String : String]()
			obj["identifier"] = note!.identifier
			obj["title"] = note!.content.title
			obj["body"] = note!.content.body
			obj["data"] = note!.content.userInfo["data"] as? String
			
			let trigger = note!.trigger as! UNCalendarNotificationTrigger
			let components: DateComponents = trigger.dateComponents
			let calendar = Calendar(identifier: .gregorian)
			let date: Date = calendar.date(from: components)!
			obj["when"] = String(date.timeIntervalSince1970 * 1000.0)
			return obj
		}
	}
	
	@objc(clearAllScheduled:) func clearAllScheduled(command: CDVInvokedUrlCommand) {
		let center = UNUserNotificationCenter.current()	
		center.removeAllPendingNotificationRequests()
		let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
	}
	
	@objc(clearAllTriggered:) func clearAllTriggered(command: CDVInvokedUrlCommand) {
		let center = UNUserNotificationCenter.current()	
		center.removeAllDeliveredNotifications()
		let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
	}
}



