//
//  ContentView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var tmdbApiKey: String = ""
    @State private var isInputFocused: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [Color(white: 0.15), Color.black]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 500
                )
                
                // the blurred circles behind the white gradient make glow
                VStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: 0, y: 100)
                }

                VStack(spacing: 40) {
                    VStack(spacing: 12) {
                        Image(systemName: "popcorn.fill") // switch to app icon soon...
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                            .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 0)
                        Text("CineMatch")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                        
                        Text("The ultimate movie matchup game")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 25) {
                        // Input Field Container
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ENTER ACCESS KEY")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white.opacity(0.4))
                                .padding(.leading, 4)
                            
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                SecureField("", text: $tmdbApiKey, prompt:  Text("TMDB API Key").foregroundColor(.gray)) // This is somthing new I learned about, it allows you to paste your key and make the bubble effect to make it secure/hidden
                                    .foregroundStyle(.white)
                                    .tint(.white) // Cursor color changed to white from blue
                            }
                            .padding()
                            
                            //API KEY bubbles
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.3)) // dark
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1) //outline
                            )
                        }
                       
                        // Start Button
                        NavigationLink {
                            if !tmdbApiKey.isEmpty {
                                SplitScreenView(apiKey: tmdbApiKey)
                            }
                        } label: {
                            HStack {
                                Text("Start Session")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 18, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                // Button Gradient
                                LinearGradient(
                                    colors: [.white, Color(white: 0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                            .shadow(color: .white.opacity(0.25), radius: 10, x: 0, y: 5)
                        }
                        .disabled(tmdbApiKey.isEmpty) // makes it so that if the user tries to click it, it wont work.
                        .opacity(tmdbApiKey.isEmpty ? 0.5 : 1.0)
                        .animation(.easeInOut, value: tmdbApiKey.isEmpty)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial) 
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Text("Made By Aiden o-0")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.bottom, 20)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    ContentView()
}
