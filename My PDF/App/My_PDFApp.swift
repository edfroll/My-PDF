//
//  My_PDFApp.swift
//  My PDF
//
//  Created by Эдвард on 04.12.2025.
//
import SwiftUI

@main
struct PDFAppApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    init() {
        _ = CoreDataManager.shared.persistentContainer
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .fullScreenCover(isPresented: .constant(!hasSeenWelcome)) {
                    WelcomeView(isPresented: $hasSeenWelcome)
                        .interactiveDismissDisabled()
                }
        }
    }
}
