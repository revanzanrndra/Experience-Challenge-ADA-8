//
//  ActiveSessionView.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @EnvironmentObject var viewModel: ParkingViewModel
    let session: ParkingSession
    @State private var currentTime = Date()
    
    private var formattedDuration: String {
        let interval = currentTime.timeIntervalSince(session.startTime)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Active Parking Session")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Divider()
            
            HStack(spacing: 16) {
                if let parkingLot = viewModel.parkingLots.first(where: { $0.id == session.parkingLotID }) {
                    Image(parkingLot.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding()
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(formattedDuration)")
                        .fontWeight(.medium)
                    Text("Estimated Cost: Rp\(viewModel.formatNumber(viewModel.calculateCost(for: session)))")
                        .fontWeight(.medium)
                    
                    Text("Park Location:")
                    
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.gray)
                        Text(session.parkingLotName)
                    }
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            Button {
                viewModel.endSession(session)
            } label: {
                Text("End Session")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            
            Button {
                viewModel.showStartSession = true
            } label: {
                Text("Edit")
            }
        }
        .padding(16)
        .background(Color.white)
        .border(Color.gray.opacity(0.2), width: 1)
        .cornerRadius(10)
        .shadow(radius: 1)
        .onAppear {
            // Start timer when view appears
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date()
            }
        }
        .onDisappear {
            // Invalidate timer when view disappears (optional, to save resources)
            // Note: Timer is automatically invalidated when view is deallocated in SwiftUI
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ParkingLot.self, ParkingSession.self, configurations: config)
        let viewModel = ParkingViewModel(modelContext: container.mainContext)
        let sampleSession = ParkingSession(
            parkingLotID: UUID(),
            parkingLotName: "GOP9 Parking Lot",
            vehicleType: VehicleType.car.rawValue,
            startTime: Date(),
            reminderEnabled: false
        )
        return ActiveSessionView(session: sampleSession)
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
