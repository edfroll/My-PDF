//
//  MainTabView.swift
//  My PDF
//
//  Created by Эдвард on 12/9/25.
//
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            EditorView()
                .tabItem {
                    Label("Create", systemImage: "doc.badge.plus")
                }
            
            SavedDocumentsView()
                .tabItem {
                    Label("Documents", systemImage: "folder")
                }
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}

