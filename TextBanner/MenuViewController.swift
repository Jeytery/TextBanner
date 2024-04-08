//
//  MenuViewController.swift
//  TextBanner
//
//  Created by Dmytro Ostapchenko on 07.04.2024.
//

import Foundation
import UIKit

class MenuViewController: UIViewController {
    var text: String {
        return textView.text
    }
    
    private let textView = UITextView()
    private var textViewBottomConstraint: NSLayoutConstraint!
    
    private var isPlaceholderShown = true
    
    private var keyboardToolBar: UIToolbar!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            textView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            textView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20),
        ])
        self.textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        self.textViewBottomConstraint.isActive = true
        textView.font = .systemFont(ofSize: 33, weight: .regular)
        textView.keyboardDismissMode = .onDrag
        self.view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textView.text = "Enter phrase..."
        textView.textColor = UIColor.lightGray
        
        textView.delegate = self
        
        addDoneButtonOnKeyboard()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo
        if let keyboardRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            textViewBottomConstraint.constant = -keyboardRect.height
            UIView.animate(withDuration: 0.4, animations: {
                self.textView.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        textViewBottomConstraint.constant = 0
        self.textView.layoutIfNeeded()
    }
}
  
extension MenuViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if let selectedRange = textView.selectedTextRange, let selectedText = textView.text(in: selectedRange)  {
            if selectedText.isEmpty {
                updateToolBar(items: [
                    
                ])
            }
            else {
                updateToolBar(items: [
                    .init(
                        image: UIImage(systemName: "italic"),
                        style: .plain,
                        target: self,
                        action: #selector(doneButtonAction)
                    ),
                    .init(title: "Bold", style: .done, target: self, action:  #selector(doneButtonAction)),
                    .init(title: "Color", style: .plain, target: self, action: #selector(doneButtonAction)),
                ])
            }
           
        }
        else {
            updateToolBar(items: [
                
            ])
        }
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
            isPlaceholderShown = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter phrase..."
            textView.textColor = UIColor.lightGray
            isPlaceholderShown = true
        }
    }
    
    func removeAllText() {
        if isPlaceholderShown {
            return
        }
        textView.text = ""
        if !textView.isFirstResponder {
            textViewDidEndEditing(textView)
        }
    }
}

private extension MenuViewController {
    func updateToolBar(items: [UIBarButtonItem]) {
        let doneToolbar = keyboardToolBar
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        var _items: [UIBarButtonItem] = []
        _items.append(contentsOf: items)
        _items.append(flexSpace)
        _items.append(done)
        doneToolbar?.items = _items
        doneToolbar?.sizeToFit()
        textView.inputAccessoryView = doneToolbar
    }
    
    func addDoneButtonOnKeyboard() {
        self.keyboardToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        var items: [UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        keyboardToolBar.items = items
        keyboardToolBar.sizeToFit()
        textView.inputAccessoryView = keyboardToolBar
    }

    @objc func doneButtonAction() {
        textView.resignFirstResponder()
    }
}
