//
//  MainCoordinator.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 07.04.2024.
//

import Foundation
import UIKit
import SwiftUI

final class MainCoorinatorNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

final class MainCoordinator {
    private(set) var navigationController = MainCoorinatorNavigationController()
    private let menuViewController = MenuViewController()
    private lazy var dynamicLabelViewController = UIHostingController(
        rootView: DynamicLabelViewSUI(state: dynamicLabelViewState)
    )
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
        dynamicLabelViewState.doubleTapHandler = { [weak self] in }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAction))
        tap.numberOfTapsRequired = 2
        dynamicLabelViewController.view.addGestureRecognizer(tap)
        
        dynamicLabelViewController.view.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.addSubview(dynamicLabelViewController.view)
        
        dynamicLabelViewController.view.topAnchor.constraint(equalTo: navigationController.view.topAnchor).isActive = true
        dynamicLabelViewController.view.leftAnchor.constraint(equalTo: navigationController.view.leftAnchor).isActive = true
        dynamicLabelViewController.view.rightAnchor.constraint(equalTo: navigationController.view.rightAnchor).isActive = true
        dynamicLabelViewController.view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor).isActive = true
        dynamicLabelViewController.view.alpha = 0
    }
    
    @objc func didTapAction() {
        if #available(iOS 16.0, *) {
            DispatchQueue.main.async {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                self.menuViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
                self.navigationController.setNeedsUpdateOfSupportedInterfaceOrientations()
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                    print(error)
                    print(windowScene?.effectiveGeometry ?? "")
                }
                self.dynamicLabelViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.hideDynamicLabel()
            }
        }
        else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.hideDynamicLabel()
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
        if #available(iOS 16.0, *) {
            DispatchQueue.main.async {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                self.menuViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
                self.navigationController.setNeedsUpdateOfSupportedInterfaceOrientations()
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight)) { error in
                    print(error)
                    print(windowScene?.effectiveGeometry ?? "")
                }
                self.dynamicLabelViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showDynamicLabel()
            }
        }
        else {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    private func showDynamicLabel() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dynamicLabelViewController.view.alpha = 1
        })
      
        if menuViewController.text.last == " " {
            let mutableAttributedString =  NSMutableAttributedString.init(attributedString:  menuViewController.attributedText)
            mutableAttributedString.deleteCharacters(in: NSRange(location:(mutableAttributedString.length) - 1, length: 1))
            dynamicLabelViewState.text = .init(mutableAttributedString)
        }
        else {
            dynamicLabelViewState.text = .init(menuViewController.attributedText)
        }    
    }
    
    private func hideDynamicLabel() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dynamicLabelViewController.view.alpha = 0
        })
        UIApplication.shared.isIdleTimerDisabled = false
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

