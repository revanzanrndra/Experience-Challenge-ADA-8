//
//  SessionCardView.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftUI
import SwiftData

struct SessionCardView: View {
    let session: ParkingSession
    @EnvironmentObject var viewModel: ParkingViewModel
    
    var body: some View {
        HStack {
            if let parkingLot = viewModel.parkingLots.first(where: { $0.id == session.parkingLotID }) {
                Image(parkingLot.image)
                    .resizable()
                    .frame(maxWidth: 110, maxHeight: .infinity)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(maxWidth: 110, maxHeight: .infinity)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(session.parkingLotName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack() {
                        Image(systemName: "clock")
                            .foregroundStyle(.gray)
                        Text("Duration: \(formattedDuration)")
                            .font(.caption)
                    }
                    HStack() {
                        Image(systemName: "dollarsign.circle")
                            .foregroundStyle(.gray)
                        Text("Cost: Rp\(viewModel.formatNumber(session.totalCost ?? 0.0))")
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "\(session.vehicleType).fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
                .padding(16)
        }
        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
        .background(.white)
        .border(Color.gray.opacity(0.2), width: 1)
        .cornerRadius(10)
    }
    
    private var formattedDuration: String {
        let interval = (session.endTime ?? Date()).timeIntervalSince(session.startTime)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        return String(format: "%02d:%02d", hours, minutes)
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
        sampleSession.endTime = Date().addingTimeInterval(9000) // 2.5 hours
        sampleSession.totalCost = 6000
        return SessionCardView(session: sampleSession)
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
