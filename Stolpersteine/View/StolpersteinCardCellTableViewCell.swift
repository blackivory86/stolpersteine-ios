//
//  StolpersteinCardCellTableViewCell.swift
//  Stolpersteine
//
//  Created by Jan Rose on 09.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit

class StolpersteinCardCell: UITableViewCell {
    
    static var standardStolperstein: Stolperstein {
        return Stolperstein(id: nil,
                            stolpersteinType: .stein,
                            sourceName: nil,
                            sourceURL: nil,
                            personFirstName: "xxxxxxxxxx",
                            personLastName: "xxxxxxxxxx",
                            biographyURL: nil,
                            locationStreet: "xxxxxxxxxx xxx",
                            locationZIP: "xxxx",
                            locationCity: "xxxxxxxxxx",
                            locationCoordinate: CLLocationCoordinate2D())
    }
    
    public var linkDelegate: CCHLinkTextViewDelegate? {
        get {
            bodyTextView?.linkDelegate
        }
        set {
            bodyTextView?.linkDelegate = newValue
        }
    }
    
    private (set) var stolperstein: Stolperstein = StolpersteinCardCell.standardStolperstein
    
    public var canSelectCurrentStolperstein: Bool {
        return stolperstein.localizedBiographyURL != nil
    }
    
    @IBOutlet private weak var bodyTextView: CCHLinkTextView?
    @IBOutlet private weak var rightConstraint: NSLayoutConstraint?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUp()
    }
    
    private func setUp() {
        bodyTextView?.textContainer.lineFragmentPadding = 15
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPressRecognizer)
        if let linkGestureRecognizer = bodyTextView?.linkGestureRecognizer {
            longPressRecognizer.require(toFail: linkGestureRecognizer)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willHideEditMenu(notification:)), name: UIMenuController.willHideMenuNotification, object: nil)
    }

    public func update(withStolperstein stolperstein: Stolperstein, linksDisabled: Bool, index: UInt) {
        
        self.stolperstein = stolperstein
        
        bodyTextView?.attributedText = stolperstein.bodyAttributedString(linksDisabled: linksDisabled)
        
        accessoryType = canSelectCurrentStolperstein ? .disclosureIndicator : .none
    }
    
    public func heightForCurrentStolperstein(withTableViewWidth width: CGFloat) -> CGFloat {
        var width = width
        width -= (accessoryType == .none) ? 0 : 33
        
        let size = bodyTextView?.sizeThatFits(CGSize(width: width, height: CGFloat(MAXFLOAT)))
        return ceil(size?.height ?? 0) + 1 // add 1 for cell separator
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        self.becomeFirstResponder()
        
        let menu = UIMenuController.shared
        menu.setTargetRect(bounds, in: self)
        menu.setMenuVisible(true, animated: true)
    }
    
    @objc private func willHideEditMenu(notification: Notification) {
        self.setSelected(false, animated: false)
    }
    
    // MARK: Copy & Paste
    
    override func copy(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        if let url = stolperstein.localizedBiographyURL {
            pasteboard.url = url
        }
        pasteboard.string = stolperstein.pasteboardString
        
        setSelected(false, animated: true)
        
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}

extension Stolperstein {
    func bodyAttributedString(linksDisabled: Bool) -> NSAttributedString {
        let body = "\(name)\n\(longAddress)"
        let bodyAttrString = NSMutableAttributedString(string: body)
        
        bodyAttrString.addAttribute(.font,
                                    value: UIFont.preferredFont(forTextStyle: .headline),
                                    range: NSRange(location: 0, length: name.count))
        
        bodyAttrString.addAttribute(.font,
                                    value: UIFont.preferredFont(forTextStyle: .subheadline),
                                    range: NSRange(location: name.count + 1, length: longAddress.count))
        
        if !linksDisabled {
            bodyAttrString.addAttribute(.CCHLinkAttributeName, value: "", range: NSRange(location: name.count + 1, length: streetName.count))
        }
        
        return bodyAttrString
    }
}

extension NSAttributedString.Key {
    public static let CCHLinkAttributeName = NSAttributedString.Key(rawValue: "CCHLinkAttributeName")
}
