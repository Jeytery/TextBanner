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
    
    var attributedText: NSAttributedString {
        guard let attributedString = textView.attributedText else {
            return NSAttributedString()
        }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedString.enumerateAttributes(in: NSRange(location: 0, length: mutableAttributedString.length), options: []) { (attributes, range, _) in
            if let font = attributes[.font] as? UIFont {
                let newFont = font.withSize(500)
                mutableAttributedString.addAttribute(.font, value: newFont, range: range)
            }
        }
        return mutableAttributedString
    }
    
    private let textView = UITextView()
    private var textViewBottomConstraint: NSLayoutConstraint!
    private var isPlaceholderShown = true
    private var keyboardToolBar: UIToolbar!
    private var selectedRange: UITextRange!
    
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
                        action: #selector(didTapItalic)
                    ),
                    .init(title: "Bold", style: .done, target: self, action:  #selector(boldDidTap)),
                    .init(title: "Color", style: .plain, target: self, action: #selector(colorDidTap)),
                    .init(title: "Remove", style: .plain, target: self, action: #selector(removeButtonTap)),
                ])
                self.selectedRange = selectedRange
            }
        }
        else {
            updateToolBar(items: [
                
            ])
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let selectedRange = textView.selectedTextRange else { return }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 33),
            .foregroundColor: UIColor.label
        ]
        let string = textView.text ?? ""
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        for (index, character) in string.enumerated() {
            if character == " " {
                attributedString.setAttributes(attributes, range: NSRange(location: index, length: 1))
            }
        } 
        self.textView.attributedText = attributedString
        textView.selectedTextRange = selectedRange
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
    
    func selectedRangeInTextView(_ textView: UITextView) -> NSRange {
        let beginning = textView.beginningOfDocument

        if let selectedRange = textView.selectedTextRange {
            let selectionStart = selectedRange.start
            let selectionEnd = selectedRange.end

            let location = textView.offset(from: beginning, to: selectionStart)
            let length = textView.offset(from: selectionStart, to: selectionEnd)

            return NSRange(location: location, length: length)
        } else {
            return NSRange(location: 0, length: 0)
        }
    }

    @objc func doneButtonAction() {
        textView.resignFirstResponder()
    }
    
    @objc func colorDidTap() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        self.navigationController?.present(colorPicker, animated: true)
    }
    
    @objc func boldDidTap() {
        let attr: NSMutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 33),
        ]
        attr.addAttributes(attributes, range: selectedRangeInTextView(textView))
//        textView.attributedText = attr
//        let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
//        textView.selectedTextRange = range
        
        if !(textView.text?.last == " ") {
            attr.append(
                NSAttributedString(string: " ", attributes: [
                    .font: UIFont.systemFont(ofSize: 33),
                    .foregroundColor: UIColor.label
                ]
            ))
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
        else {
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
    }
    
    @objc func didTapItalic() {
        guard let selectedRange = textView.selectedTextRange else { return }
        let attr: NSMutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 33),
        ]
        attr.addAttributes(attributes, range: selectedRangeInTextView(textView))
//        textView.attributedText = attr
//        let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
//        textView.selectedTextRange = range
        if !(textView.text?.last == " ") {
            attr.append(
                NSAttributedString(string: " ", attributes: [
                    .font: UIFont.systemFont(ofSize: 33),
                    .foregroundColor: UIColor.label
                ]
            ))
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
        else {
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
    }
    
    @objc func removeButtonTap() {
        guard let selectedRange = textView.selectedTextRange else { return }
        let attr: NSMutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 33),
            .foregroundColor: UIColor.label
        ]
        attr.addAttributes(attributes, range: selectedRangeInTextView(textView))
//        textView.attributedText = attr
//        let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
//        textView.selectedTextRange = range
        if !(textView.text?.last == " ") {
            attr.append(
                NSAttributedString(string: " ", attributes: [
                    .font: UIFont.systemFont(ofSize: 33),
                    .foregroundColor: UIColor.label
                ]
            ))
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
        else {
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo
        if let keyboardRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            textViewBottomConstraint.constant = -keyboardRect.height
            self.textView.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        textViewBottomConstraint.constant = 0
        self.textView.layoutIfNeeded()
    }
}

extension MenuViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let attr: NSMutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: viewController.selectedColor
        ]
        attr.addAttributes(attributes, range: selectedRangeInTextView(textView))
        if !(textView.text?.last == " ") {
            attr.append(
                NSAttributedString(string: " ", attributes: [
                    .font: UIFont.systemFont(ofSize: 33),
                    .foregroundColor: UIColor.label
                ]
            ))
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
        else {
            textView.attributedText = attr
            let range = textView.textRange(from: textView.position(from: selectedRange.end, offset: 1)!, to: textView.position(from: selectedRange.end, offset: 1)!)!
            textView.selectedTextRange = range
        }
    }
}
