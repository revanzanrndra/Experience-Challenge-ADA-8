//
//  SummarySheetView.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftUI
import SwiftData

struct SummarySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: ParkingViewModel
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Parking Session Complete!")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            if let session = viewModel.lastEndedSession {
                VStack(spacing: 15) {
                    HStack(alignment: .top) {
                        Image(systemName: "parkingsign.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("You parked at \(session.parkingLotName)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "\(session.vehicleType).fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Vehicle: \(session.vehicleType.capitalized)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("Your session lasted \(formattedDuration(session: session)).")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "dollarsign.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        Text("You’ve spent Rp\(viewModel.formatNumber(session.totalCost ?? 0.0)) on parking.")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 0.3), value: scale)
                .onAppear {
                    scale = 1.0
                }
            } else {
                Text("No session details available.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                viewModel.resetSessionConfig()
                dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .accessibilityLabel("Done")
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func formattedDuration(session: ParkingSession) -> String {
        let interval = (session.endTime ?? Date()).timeIntervalSince(session.startTime)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        return String(format: "%d hours and %d minutes", hours, minutes)
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
            startTime: Date().addingTimeInterval(-7200), // 2 hours ago
            reminderEnabled: false
        )
        sampleSession.endTime = Date()
        sampleSession.totalCost = 6000
        viewModel.lastEndedSession = sampleSession
        return SummarySheetView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
