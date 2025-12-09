//
//  Welcome.swift
//  My PDF
//
//  Created by Эдвард on 12/8/25.
//
import SwiftUI

struct WelcomeView: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon / Logo
            Image(systemName: "doc.text.image")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .padding(.bottom, 20)
            // Title
            Text("Welcome to My PDF")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            // Features List
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "photo.on.rectangle.angled",
                    title: "Convert Images",
                    description: "Select photos from your gallery and convert them to PDF"
                )
                FeatureRow(
                    icon: "doc.on.doc",
                    title: "Manage Documents",
                    description: "Save, view and organize your PDF documents"
                )
                FeatureRow(
                    icon: "arrow.triangle.merge",
                    title: "Merge PDFs",
                    description: "Combine multiple documents into one"
                )
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Share Anywhere",
                    description: "Export and share your PDFs easily"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Get Started Button
            Button {
                isPresented = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(.capsule)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            
        }
    }
}

// MARK: - Feature Row Component
private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

