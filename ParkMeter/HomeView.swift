//
//  HomeView.swift
//  ParkMeter
//
//  Created by Tm Revanza Narendra Pradipta on 18/05/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var viewModel: ParkingViewModel
    @Query(filter: #Predicate<ParkingSession> { $0.endTime == nil }, sort: \.startTime, order: .reverse) private var activeSessions: [ParkingSession]
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ZStack {
                    VStack(spacing: 20) {
                        Text("ParkMeter")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Text("Track your parking time and costs effortlessly!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if let session = activeSessions.first {
                            ActiveSessionView(session: session)
                        } else {
                            Button {
                                viewModel.showStartSession = true
                            } label: {
                                Text("Start Parking Session")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .center) {
                            HStack {
                                Text("Recent Sessions")
                                    .font(.headline)
                                Spacer()
                            }
                            if viewModel.sessions.isEmpty {
                                Spacer()
                                VStack {
                                    Image(systemName: "document")
                                        .resizable()
                                        .frame(width: 40, height: 50)
                                        .foregroundColor(.gray)
                                    Text("No Session")
                                        .foregroundStyle(.gray)
                                        .fontWeight(.medium)
                                }
                                Spacer()
                            } else {
                                ScrollView {
                                    ForEach(viewModel.sessions.filter { $0.endTime != nil }.prefix(3)) { session in
                                        SessionCardView(session: session)
                                            .padding(.vertical, 5)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .fullScreenCover(isPresented: $viewModel.showStartSession) {
                    StartingSessionFormView()
                }
                .fullScreenCover(isPresented: $viewModel.showSummary) {
                    SummarySheetView()
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                ParkingLotListView()
            }
            .tabItem {
                Image(systemName: "parkingsign.circle")
                Text("Lots")
            }
            .tag(1)
            
//            NavigationStack {
//                StatisticsView()
//            }
//            .tabItem {
//                Image(systemName: "chart.bar")
//                Text("Stats")
//            }
//            .tag(2)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ParkingLot.self, ParkingSession.self, configurations: config)
        let viewModel = ParkingViewModel(modelContext: container.mainContext)
        return HomeView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
