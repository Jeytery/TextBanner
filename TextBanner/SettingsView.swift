//
//  SettingsView.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 08.04.2024.
//

import SwiftUI
import SettingsIconGenerator
import MessageUI

struct InvestorsResponse: Codable {
    let investors: [String]
}

struct SettingsView: View {
    @State private var investors: [String] = []
    @State private var isInvestorsFailed: String? = nil
    @State private var isVersionTapped: Bool = false
    @State private var isShowingMailView = false
    
    private let githubService = GitHubStorageService<InvestorsResponse>(
        remoteStorageUrl: "https://api.github.com/repos/Jeytery/text-banner-investors/contents/README.md"
    )
    
    private func infoCell(
        title1: String,
        title2: String,
        disclosureIndicator: Bool,
        imageName: String,
        imageColor: UIColor,
        didTap: @escaping () -> Void
    ) -> some View {
        ZStack {
            HStack {
                Image(
                    uiImage: .generateSettingsIcon(
                        imageName,
                        backgroundColor: imageColor
                    ) ?? UIImage()
                )
                Text(title1)
                Spacer()
                Text(title2)
                    .foregroundColor(.secondary)
                if disclosureIndicator {
                    Image(systemName: "chevron.forward")
                        .font(Font.system(.caption).weight(.bold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            Button("", action: {
                didTap()
            })
        }
    }
    var body: some View {
        List {
            Section(header: Text("Support")) {
                infoCell(
                    title1: "Ask question",
                    title2: "Telegram",
                    disclosureIndicator: true,
                    imageName: "bubble.left.fill",
                    imageColor: .orange,
                    didTap: {
                        if let url = URL(string: "https://telegram.im/@Jeytery") {
                            UIApplication.shared.open(url)
                        }
                    })
                infoCell(
                    title1: "Ask question",
                    title2: "Mail",
                    disclosureIndicator: true,
                    imageName: "bubble.left.fill",
                    imageColor: .systemBlue,
                    didTap: {
                        if MFMailComposeViewController.canSendMail() {
                            isShowingMailView = true
                        }
                        else {
                            let email = "dimaostapchenko@gmail.com"
                            if let url = URL(string: "mailto:\(email)") {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                        }
                    })
            }
            
            Section {
                infoCell(
                    title1: "Privacy policy",
                    title2: "",
                    disclosureIndicator: true,
                    imageName: "doc.text.fill",
                    imageColor: .systemPink,
                    didTap: {
                        if let url = URL(string: "https://github.com/Jeytery/role-cards-docs/blob/main/privacy-policy") {
                            UIApplication.shared.open(url)
                        }
                    })
            }
            Section {
                infoCell(
                    title1: "Version",
                    title2: isVersionTapped ? "don't hurt your friends" : "1.0",
                    disclosureIndicator: false,
                    imageName: "1.circle.fill",
                    imageColor: .darkGray,
                    didTap: {
                        isVersionTapped.toggle()
                    })
            }
            Section(header: Text("protip")) {
                Text("Double tap to exit fullscreen")
            }
            Section(header: Text("More apps"), footer: Text("App to shuffle any information")) {
                ZStack {
                    Button("") {
                        if let url = URL(string: "https://apps.apple.com/ua/app/rolecards/id1589786089") {
                            UIApplication.shared.open(url)
                        }
                    }
                    HStack {
                        Text("RoleCards")
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(Font.system(.caption).weight(.bold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }   
                }
            }
            if investors.isEmpty, isInvestorsFailed == nil {
                Section(header: Text("Investors")) {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            else if let isInvestorsFailed = isInvestorsFailed {
                Section(header: Text("Investors")) {
                    Text(isInvestorsFailed)
                        .foregroundColor(.red)
                }
            }
            else {
                Section(header: Text("Investors")) {
                    ForEach(investors, id: \.self) { value in
                        Text(value)
                    }
                }
            }
        }
        .onAppear {
            githubService.getCodableType(completion: {result in
                switch result {
                case .success(let _investorsResponse):
                    self.investors = _investorsResponse.investors
                case .failure(let error):
                    self.isInvestorsFailed = error.localizedDescription
                }
            })
        }
    }
}

#Preview {
    SettingsView()
}
