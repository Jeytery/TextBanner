//
//  DynamicLabelViewController.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 08.04.2024.
//

import Foundation
import UIKit

class DynamicLabelViewController: UIViewController {
    private let label = UILabel()
    
    var doubleTapHandler: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .systemBackground
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        label.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        adjustFontSizeToFitWidth(label: label)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            doubleTapHandler?()
        }
    }
    
    private func adjustFontSizeToFitWidth(label: UILabel) {
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = minimumFontSize / maximumFontSize
        label.numberOfLines = 9
        label.font = label.font.withSize(maximumFontSize)
        label.adjustsFontForContentSizeCategory = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    private let maximumFontSize: CGFloat = 500
    private let minimumFontSize: CGFloat = 32
}

extension DynamicLabelViewController {
    func setDynamicText(_ text: String) {
        if text.isEmpty {
            label.text = "No phrase..."
            return
        }
        label.text = text
    }
}
