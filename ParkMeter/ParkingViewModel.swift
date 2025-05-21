//
//  ParkingViewModel.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftData
import UserNotifications
import Foundation

@MainActor
class ParkingViewModel: ObservableObject {
    @Published var parkingLots: [ParkingLot] = []
    @Published var sessions: [ParkingSession] = []
    @Published var currentSession: ParkingSession?
    @Published var lastEndedSession: ParkingSession?
    @Published var isSessionActive: Bool = false
    @Published var showStartSession: Bool = false
    @Published var showSummary: Bool = false
    @Published var selectedLotID: UUID?
    @Published var vehicleType: VehicleType = .car
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        print("Initializing ParkingViewModel")
        setupDefaultParkingLots()
        fetchData()
        requestNotificationPermission()
    }

    private func setupDefaultParkingLots() {
        print("Setting up default parking lots")
        do {
            let descriptor = FetchDescriptor<ParkingLot>()
            let existingLots = try modelContext.fetch(descriptor)
            if !existingLots.isEmpty {
                print("Found \(existingLots.count) existing parking lots: \(existingLots.map { $0.name })")
                parkingLots = existingLots
                return
            }
        } catch {
            print("Failed to fetch existing parking lots: \(error)")
        }
        
        let defaultLots = [
            ParkingLot(name: "Green Office Park 1", image: "GOP1-park", carRateFirstHour: 5000, carRatePerHour: 4000, motorcycleRateFirstHour: 2000, motorcycleRatePerHour: 2000),
            ParkingLot(name: "Green Office Park 5", image: "GOP5-park", carRateFirstHour: 5000, carRatePerHour: 4000, motorcycleRateFirstHour: 2000, motorcycleRatePerHour: 2000),
            ParkingLot(name: "Green Office Park 6", image: "GOP6-park", carRateFirstHour: 5000, carRatePerHour: 4000, motorcycleRateFirstHour: 2000, motorcycleRatePerHour: 2000),
            ParkingLot(name: "Green Office Park 9", image: "GOP9-park", carRateFirstHour: 5000, carRatePerHour: 4000, motorcycleRateFirstHour: 2000, motorcycleRatePerHour: 2000),
            ParkingLot(name: "Sinarmas Land", image: "SML-park", carRateFirstHour: 5000, carRatePerHour: 4000, motorcycleRateFirstHour: 2000, motorcycleRatePerHour: 2000),
            ParkingLot(name: "The Breeze Parking", image: "the-breeze-park", carRateFirstHour: 5000, carRatePerHour: 5000, motorcycleRateFirstHour: 3000, motorcycleRatePerHour: 2000),
            ParkingLot(name: "Unilever Parking", image: "unilever-park", carRateFirstHour: 5000, carRatePerHour: 4000, motorcycleRateFirstHour: 2000, motorcycleRatePerHour: 2000)
        ]
        
        do {
            for lot in defaultLots {
                print("Inserting parking lot: \(lot.name)")
                modelContext.insert(lot)
            }
            try modelContext.save()
            parkingLots = defaultLots
            print("Successfully inserted and saved \(defaultLots.count) default parking lots")
        } catch {
            print("Failed to insert default parking lots: \(error)")
            parkingLots = []
        }
    }
    
    func fetchData() {
        print("Fetching data")
        do {
            let lotDescriptor = FetchDescriptor<ParkingLot>(sortBy: [SortDescriptor(\.name)])
            parkingLots = try modelContext.fetch(lotDescriptor)
            print("Fetched \(parkingLots.count) parking lots")
            
            let sessionDescriptor = FetchDescriptor<ParkingSession>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
            sessions = try modelContext.fetch(sessionDescriptor)
            currentSession = sessions.first { $0.endTime == nil }
            isSessionActive = currentSession != nil
            print("Fetched \(sessions.count) sessions, currentSession: \(currentSession != nil ? "valid" : "nil"), isSessionActive: \(isSessionActive)")
        } catch {
            print("Failed to fetch data: \(error)")
            parkingLots = []
            sessions = []
            currentSession = nil
            isSessionActive = false
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
                if !granted {
                    print("Warning: Notifications are disabled. Please enable them in Settings to receive parking reminders.")
                }
            }
        }
    }
    
    // Session Management
    func startSession(parkingLotID: UUID?, vehicleType: VehicleType, startTime: Date, reminderEnabled: Bool, reminderHours: Double?, parkingPosition: String?) {
        guard let parkingLotID = parkingLotID,
              let parkingLot = parkingLots.first(where: { $0.id == parkingLotID }) else {
            print("Invalid parking lot ID: \(String(describing: parkingLotID))")
            return
        }
        
        let newSession = ParkingSession(
            parkingLotID: parkingLotID,
            parkingLotName: parkingLot.name,
            vehicleType: vehicleType.rawValue,
            startTime: startTime,
            reminderEnabled: reminderEnabled,
            reminderHours: reminderEnabled ? reminderHours : nil,
            parkingPosition: parkingPosition?.isEmpty ?? true ? nil : parkingPosition
        )
        
        do {
            modelContext.insert(newSession)
            try modelContext.save()
            if reminderEnabled, let hours = reminderHours {
                print("Attempting to schedule reminder for sessionID: \(newSession.id), hours: \(hours)")
                scheduleReminder(for: newSession, after: hours)
            } else {
                print("Reminder not scheduled: reminderEnabled=\(reminderEnabled), reminderHours=\(String(describing: reminderHours))")
            }
            fetchData()
            isSessionActive = true
            showStartSession = false
            print("Started session at \(parkingLot.name), sessionID: \(newSession.id)")
        } catch {
            print("Failed to start session: \(error)")
        }
    }
    
    func editSession(_ session: ParkingSession, parkingLotID: UUID?, vehicleType: VehicleType, startTime: Date, reminderEnabled: Bool, reminderHours: Double?, parkingPosition: String?) {
        guard let parkingLotID = parkingLotID,
              let parkingLot = parkingLots.first(where: { $0.id == parkingLotID }) else {
            print("Invalid parking lot ID: \(String(describing: parkingLotID))")
            return
        }
        
        session.parkingLotID = parkingLotID
        session.parkingLotName = parkingLot.name
        session.vehicleType = vehicleType.rawValue
        session.startTime = startTime
        session.reminderEnabled = reminderEnabled
        session.reminderHours = reminderEnabled ? reminderHours : nil
        session.parkingPosition = parkingPosition?.isEmpty ?? true ? nil : parkingPosition
        
        do {
            try modelContext.save()
            if reminderEnabled, let hours = reminderHours {
                print("Attempting to schedule reminder for edited sessionID: \(session.id), hours: \(hours)")
                scheduleReminder(for: session, after: hours)
            } else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["parkingReminder_\(session.id)"])
                print("Removed reminder for sessionID: \(session.id)")
            }
            fetchData()
            print("Edited session for \(parkingLot.name), sessionID: \(session.id)")
        } catch {
            print("Failed to edit session: \(error)")
        }
    }
    
    func endSession(_ session: ParkingSession) {
        session.endTime = Date()
        session.totalCost = calculateCost(for: session)
        
        do {
            try modelContext.save()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["parkingReminder_\(session.id)"])
            lastEndedSession = session
            fetchData()
            isSessionActive = false
            showSummary = true
            print("Ended session for \(session.parkingLotName), cost: \(session.totalCost ?? 0.0), sessionID: \(session.id)")
        } catch {
            print("Failed to end session: \(error)")
        }
    }
    
    func resetSessionConfig() {
        selectedLotID = nil
        vehicleType = .car
        showSummary = false
        lastEndedSession = nil
        print("Reset session configuration")
    }
    
    func calculateCost(for session: ParkingSession) -> Double {
        guard let parkingLot = parkingLots.first(where: { $0.id == session.parkingLotID }) else {
            print("Parking lot not found: \(session.parkingLotName), sessionID: \(session.id)")
            return 0.0
        }
        
        let endTime = session.endTime ?? Date()
        let durationComponents = Calendar.current.dateComponents([.hour, .minute], from: session.startTime, to: endTime)
        let durationHours = durationComponents.hour ?? 0
        let durationMinutes = durationComponents.minute ?? 0
        
        // Round up to the next hour if there are any minutes
        let totalHours = durationHours + (durationMinutes > 0 ? 1 : 0)
        
        let isCar = session.vehicleType == VehicleType.car.rawValue
        let firstHourRate = isCar ? parkingLot.carRateFirstHour : parkingLot.motorcycleRateFirstHour
        let perHourRate = isCar ? parkingLot.carRatePerHour : parkingLot.motorcycleRatePerHour
        
        print("Calculating cost for \(session.parkingLotName), hours: \(totalHours), vehicle: \(session.vehicleType), sessionID: \(session.id)")
        
        if totalHours <= 0 {
            return 0.0
        } else if totalHours == 1 {
            return Double(firstHourRate)
        } else {
            return Double(firstHourRate + (Double(totalHours) - 1) * perHourRate)
        }
    }
    
    // Notifications
    private func scheduleReminder(for session: ParkingSession, after hours: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Parking Reminder"
        content.body = "Your parking at \(session.parkingLotName) is nearing \(Int(hours)) hours."
        content.sound = .default
        content.badge = 1 // Add badge for visibility

        let triggerTime = (hours * 3600) - (15 * 60) // TimeInterval(10)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        
        let request = UNNotificationRequest(identifier: "parkingReminder_\(session.id)", content: content, trigger: trigger)
        print("Scheduling reminder for \(session.parkingLotName), sessionID: \(session.id), triggerTime: \(triggerTime) seconds")
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error), sessionID: \(session.id)")
            } else {
                print("Successfully scheduled reminder for \(session.parkingLotName) with 10-second delay, sessionID: \(session.id)")
            }
        }
    }
    
    // Utilities
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
