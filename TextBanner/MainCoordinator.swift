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
    private lazy var dynamicLabelViewController = UIHostingController(rootView: DynamicLabelViewSUI(state: dynamicLabelViewState))
    //private lazy var dynamicLabelViewController = DynamicLabelViewController()
    
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
        dynamicLabelViewState.doubleTapHandler = { [weak self] in
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
        UIApplication.shared.isIdleTimerDisabled = true
        navigationController.present(dynamicLabelViewController, animated: true)
        if menuViewController.text.last == " " {
            let mutableAttributedString =  NSMutableAttributedString.init(attributedString:  menuViewController.attributedText)
            mutableAttributedString.deleteCharacters(in: NSRange(location:(mutableAttributedString.length) - 1,length:1))
            dynamicLabelViewState.text = .init(mutableAttributedString)
        }
        else {
            dynamicLabelViewState.text = .init(menuViewController.attributedText)
        }    
    }
    
    private func hideDynamicLabel() {
        UIApplication.shared.isIdleTimerDisabled = false
        dynamicLabelViewController.dismiss(animated: false)
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

