//
//  SplashView.swift
//  KombinApp
//
//  Created by Burak Gökce on 21.07.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showMainView = false
    
    var body: some View {
        if showMainView {
            MainTabView()
        } else {
            ZStack {
                // Pink to purple gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "ffb6c1"), // Light pink
                        Color(hex: "d291bc")  // Lilac
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // App logo/icon
                    Image(systemName: "tshirt.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.0)
                    
                    // App name
                    Text("KombinApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 1.0 : 0.0)
                    
                    Text("Style Your Perfect Look")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(isAnimating ? 1.0 : 0.0)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isAnimating = true
                }
                
                // Navigate to main view after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showMainView = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}