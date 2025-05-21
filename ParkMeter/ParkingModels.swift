//
//  ParkingModels.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftData
import Foundation

// MARK: - Enums
enum VehicleType: String, CaseIterable, Identifiable {
    case car = "car"
    case motorcycle = "motorcycle"
    
    var id: String { rawValue }
}

// MARK: - Models
@Model
class ParkingLot {
    @Attribute(.unique) var name: String
    var id: UUID
    var image: String
    var carRateFirstHour: Double
    var carRatePerHour: Double
    var motorcycleRateFirstHour: Double
    var motorcycleRatePerHour: Double
    
    init(name: String, id: UUID = UUID(), image: String, carRateFirstHour: Double, carRatePerHour: Double, motorcycleRateFirstHour: Double, motorcycleRatePerHour: Double) {
        self.name = name
        self.id = id
        self.image = image
        self.carRateFirstHour = carRateFirstHour
        self.carRatePerHour = carRatePerHour
        self.motorcycleRateFirstHour = motorcycleRateFirstHour
        self.motorcycleRatePerHour = motorcycleRatePerHour
    }
}

@Model
class ParkingSession {
    var id: UUID
    var parkingLotID: UUID
    var parkingLotName: String
    var vehicleType: String
    var startTime: Date
    var endTime: Date?
    var reminderEnabled: Bool
    var reminderHours: Double?
    var parkingPosition: String?
    var totalCost: Double?
    
    init(id: UUID = UUID(), parkingLotID: UUID, parkingLotName: String, vehicleType: String, startTime: Date, reminderEnabled: Bool = false, reminderHours: Double? = nil, parkingPosition: String? = nil) {
        self.id = id
        self.parkingLotID = parkingLotID
        self.parkingLotName = parkingLotName
        self.vehicleType = vehicleType
        self.startTime = startTime
        self.reminderEnabled = reminderEnabled
        self.reminderHours = reminderHours
        self.parkingPosition = parkingPosition
    }
}
