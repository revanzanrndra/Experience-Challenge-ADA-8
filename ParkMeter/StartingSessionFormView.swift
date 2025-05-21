//
//  StartingSessionFormView.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftUI
import SwiftData

struct StartingSessionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: ParkingViewModel
    @Query private var parkingLots: [ParkingLot]
    
    @State private var currentDate = Date()
    @State private var isEnable = false
    @State private var maxHour = 1
    @State private var parkingPosition = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Start Parking Session")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Select lot")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: $viewModel.selectedLotID) {
                        Text("Select Lot").tag(UUID?.none)
                        ForEach(parkingLots) { lot in
                            Text(lot.name).tag(lot.id as UUID?)
                        }
                    }
                }
                
                HStack {
                    Text("Vehicle used")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: $viewModel.vehicleType) {
                        ForEach(VehicleType.allCases) { type in
                            Image(systemName: "\(type.rawValue).fill").tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }
                
                HStack {
                    Text("Start time")
                        .font(.headline)
                    Spacer()
                    DatePicker("Enter a date here: ", selection: $currentDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }
                
                HStack {
                    Text("Enable reminder")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $isEnable)
                }
                
                reminderEnabled()
                
                HStack(spacing: 4) {
                    Text("Parking position")
                        .font(.headline)
                    Text("(Optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                TextField("Enter parking position", text: $parkingPosition)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.separator), lineWidth: 0.4)
                    )
                
                HStack {
                    Button {
                        // Placeholder for camera functionality
                    } label: {
                        VStack {
                            Image(systemName: "camera.viewfinder")
                                .resizable()
                                .frame(width: 36, height: 36)
                            Text("Take a picture")
                                .foregroundStyle(.blue)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 0.4)
                        )
                    }
                    
                    Spacer()
                    
                    Button {
                        // Placeholder for photo library
                    } label: {
                        VStack {
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .frame(width: 40, height: 36)
                            Text("Browse pictures")
                                .foregroundStyle(.blue)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 0.4)
                        )
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button {
                    viewModel.startSession(
                        parkingLotID: viewModel.selectedLotID,
                        vehicleType: viewModel.vehicleType,
                        startTime: currentDate,
                        reminderEnabled: isEnable,
                        reminderHours: isEnable ? Double(maxHour) : nil,
                        parkingPosition: parkingPosition
                    )
                    dismiss()
                } label: {
                    Text("Start Session")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.selectedLotID != nil ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(viewModel.selectedLotID == nil)
                .padding(.horizontal)
                
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder func reminderEnabled() -> some View {
        if isEnable {
            VStack(spacing: 16) {
                HStack {
                    Text("Maximum hour to park: \(maxHour)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                    Spacer()
                    Stepper("", value: $maxHour, in: 1...12)
                        .scaleEffect(0.9)
                }
                Text("Advice: You will be reminded 15 minutes before the chosen hour")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ParkingLot.self, ParkingSession.self, configurations: config)
        let viewModel = ParkingViewModel(modelContext: container.mainContext)
        return StartingSessionFormView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
