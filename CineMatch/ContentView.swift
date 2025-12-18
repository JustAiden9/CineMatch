//
//  ContentView.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var tmdbApiKey: String = ""
    @State private var selectedLanguage: String = "en-US"
    @State private var selectedPage: Int = 1
    let languages = ["en-US", "es-ES", "fr-FR", "de-DE", "it-IT", "ja-JP", "pt-BR"] // list of langs that I wanted to use, they all work with TMDB
    
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [Color(white: 0.15), Color.black]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 500
                )
                
                // the blurred circles behind the white gradient make glow (this is a new thing I learned to give a plain background a more suttle graident.)
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
                        Image(systemName: "popcorn.fill") // nvm people prefered this
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
                                .foregroundStyle(.white.opacity(0.4)) // giving the text different opacity allows me to show different depths for the text.
                                .padding(.leading, 4)
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                                SecureField("", text: $tmdbApiKey, prompt:  Text("TMDB API Key").foregroundColor(.gray)) // This is somthing new I learned about, it allows you to paste your key and make the bubble effect to make it secure/hidden
                                    .foregroundStyle(.white)
                                    .tint(.white) // Cursor color changed to white from blue
                            }
                            .padding()
                            //API KEY bubbles/outlines, this is what gives the sense that there is a box that you are typing into. If they are removed if has no box.
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.3)) // dark
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1) //outline
                            )
                        }
                        
                        HStack(spacing: 15) {
                            // Language Picker
                            VStack(alignment: .leading, spacing: 5) {
                                Text("LANGUAGE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(.leading, 4)
                                
                                Menu {
                                    Picker("Language", selection: $selectedLanguage) { // updates the selectedLanguage Var based on what is picked.
                                        ForEach(languages, id: \.self) { lang in
                                            Text(lang).tag(lang)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedLanguage)
                                        Spacer()
                                        Image(systemName: "chevron.down") // drop down arrow is a nice touch
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    // the overlay is for the white border
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                    .foregroundStyle(.white) // instead of blue
                                }
                            }
                            
                            // Page Picker
                            VStack(alignment: .leading, spacing: 5) {
                                Text("PAGE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white.opacity(0.4))
                                    .padding(.leading, 4)
                                
                                Menu {
                                    Picker("Page", selection: $selectedPage) { // same as lang it changes the Var based on what you pick
                                        ForEach(1...20, id: \.self) { page in // You have 1-20 however there are more pages on TMBD
                                            Text("Page \(page)").tag(page)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(selectedPage)")
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                       
                        // Start Button
                        NavigationLink {
                            if !tmdbApiKey.isEmpty {
                                SplitScreenView(apiKey: tmdbApiKey, language: selectedLanguage, page: selectedPage)
                            }
                        }
                        label: {
                            HStack {
                                Text("Start Session")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 18, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                // Button Gradient using linear becuase it is not a circle
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
