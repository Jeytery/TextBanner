//
//  MainCoordinator.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 07.04.2024.
//

import Foundation
import UIKit
import SwiftUI

class MainCoordinator {
    private(set) var navigationController = UINavigationController()
    private let menuViewController = MenuViewController()
    private let dynamicLabelViewController = DynamicLabelViewController()
    
    private var dynamicLabelViewState = DynamicLabelViewSUIState()
    
    func start() {
        navigationController.setViewControllers([menuViewController], animated: false)
        menuViewController.navigationItem.leftBarButtonItem = .init(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(didTapSettings))
        let trashImage = UIImage(systemName: "trash")
        menuViewController.navigationItem.rightBarButtonItems = [
            .init(
                image: UIImage(systemName: "pip.exit"),
                style: .plain,
                target: self,
                action: #selector(didTapFullScreen)
            ),
            .init(
                image: trashImage,
                style: .plain,
                target: self,
                action: #selector(trashDidTap)
            )
        ]
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iphoneDidChangeOrientation),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iphoneDidChangeOrientation),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        dynamicLabelViewController.modalTransitionStyle = .crossDissolve
        dynamicLabelViewController.modalPresentationStyle = .overFullScreen
        dynamicLabelViewController.doubleTapHandler = { [weak self] in
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self?.hideDynamicLabel()
        }
    }
    
    @objc func trashDidTap() {
        menuViewController.removeAllText()
    }
    
    @objc func didTapSettings() {
        let hosting = UIHostingController(rootView: SettingsView())
        navigationController.pushViewController(hosting, animated: true)
    }
    
    @objc func didTapFullScreen() {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    private func showDynamicLabel() {
        navigationController.present(dynamicLabelViewController, animated: true)
        dynamicLabelViewController.setDynamicText(menuViewController.text)
    }
    
    private func hideDynamicLabel() {
        dynamicLabelViewController.dismiss(animated: true)
    }
    
    @objc func iphoneDidChangeOrientation() {
        if UIDevice.current.orientation == .portraitUpsideDown {
            return
        }
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            if dynamicLabelViewController.presentingViewController == nil {
                menuViewController.view.endEditing(true)
                showDynamicLabel()
            }
            return
        }
        if UIDevice.current.orientation == .portrait {
            hideDynamicLabel()
        }
    }
}

