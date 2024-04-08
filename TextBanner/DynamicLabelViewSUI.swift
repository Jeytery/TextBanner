//
//  DynamicLabelViewSUI.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 08.04.2024.
//

import SwiftUI

class DynamicLabelViewSUIState: ObservableObject {
    @Published var text = "*Text*🤡🤡🤡🤡"
}

struct DynamicLabelViewSUI: View {
    let state: DynamicLabelViewSUIState
    
    var body: some View {
        Text(state.text)
            .padding(40)
            .font(.system(size: 500))
            .minimumScaleFactor(0.01)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    DynamicLabelViewSUI(state: .init())
}
