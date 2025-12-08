//
//  MenuScreen.swift
//  CineMatch
//
//  Created by Aiden Baker on 12/1/25.
//

import SwiftUI

struct MenuScreen: View {
    var body: some View {
        VStack {
            Text("CineMatch")
                .font(.largeTitle)
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    MenuScreen()
}
