//
//  DynamicLabelViewSUI.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 08.04.2024.
//

import SwiftUI

class DynamicLabelViewSUIState: ObservableObject {
    @Published var text: AttributedString = "Text"
    
    var doubleTapHandler: (() -> Void)?
}

struct DynamicLabelViewSUI: View {
    @ObservedObject var state: DynamicLabelViewSUIState
    
    var body: some View {
        ZStack {
            Text(state.text)
                .padding(40)
                .font(.system(size: 500))
                .minimumScaleFactor(0.09)
                .multilineTextAlignment(.center)
            Color.red.opacity(0)
                .ignoresSafeArea()
                .onTapGesture(count: 2) {
                    state.doubleTapHandler?()
                }
        }
       
    }
}

#Preview {
    DynamicLabelViewSUI(state: .init())
}
