//
//  ParkingLotListView.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftUI
import SwiftData

struct ParkingLotListView: View {
    @EnvironmentObject var viewModel: ParkingViewModel
    @Query private var parkingLots: [ParkingLot]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(parkingLots) { lot in
                    HStack(alignment: .center, spacing: 12) {
                        Image(lot.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lot.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Car")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                HStack(spacing: 16) {
                                    Label("1st Hr: Rp\(viewModel.formatNumber(lot.carRateFirstHour))", systemImage: "clock")
                                        .font(.caption)
                                    Label("Per Hr: Rp\(viewModel.formatNumber(lot.carRatePerHour))", systemImage: "arrow.right")
                                        .font(.caption)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Motorcycle")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                HStack(spacing: 16) {
                                    Label("1st Hr: Rp\(viewModel.formatNumber(lot.motorcycleRateFirstHour))", systemImage: "clock")
                                        .font(.caption)
                                    Label("Per Hr: Rp\(viewModel.formatNumber(lot.motorcycleRatePerHour))", systemImage: "arrow.right")
                                        .font(.caption)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.leading, 12)
                    .frame(minWidth: 300, maxWidth: .infinity, minHeight: 120)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Parking Lots")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ParkingLot.self, ParkingSession.self, configurations: config)
        let viewModel = ParkingViewModel(modelContext: container.mainContext)
        return ParkingLotListView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
