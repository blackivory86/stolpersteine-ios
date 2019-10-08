//
//  InfoViewController.swift
//  Stolpersteine
//
//  Created by Jan Rose on 08.10.19.
//  Copyright © 2019 Option-U Software. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UITableViewController {
    
    private struct Constants {
        static let AppStoreID = 640731757
        struct Section {
            static let Stolpersteine = 0
            static let About = 1
            static let Acknowledgements = 2
            static let Legal = 3
        }
        struct Padding {
            static let Left: CGFloat = 15
            static let Right: CGFloat = 20
            static let Top: CGFloat = 15
            static let Bottom: CGFloat = 15
            static let Spacing: CGFloat = 8
            static let Stolpersteine: CGFloat = 150 + Spacing + Bottom
            static let About: CGFloat = Top + Bottom
            static let Sources: CGFloat = Top + Bottom
            static let Acknowledgements: CGFloat = Top + Bottom
            static let Legal: CGFloat = Top + 88 + Spacing + Bottom
        }
    }
    
    @IBOutlet private weak var stolpersteineLabel: UILabel?
    @IBOutlet private weak var stolpersteineInfoButton: UIButton?
    @IBOutlet private weak var artistInfoButton: UIButton?
    
    @IBOutlet private weak var aboutLabel: UILabel?
    @IBOutlet private weak var ratingButton: UIButton?
    @IBOutlet private weak var recommendButton: UIButton?
    
    @IBOutlet private weak var sourcesLabel: UILabel?
    @IBOutlet private weak var berlinKSSButton: UIButton?
    @IBOutlet private weak var bochumAFGButton: UIButton?
    @IBOutlet private weak var berlinWikipediaButton: UIButton?
    
    @IBOutlet private weak var acknowledgementsLabel: UILabel?
    @IBOutlet private weak var contactButton: UIButton?
    @IBOutlet private weak var gitHubButton: UIButton?
    
    @IBOutlet private weak var legalLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("InfoViewController.title", comment: "")
        
        // Stolpersteine
        stolpersteineLabel?.text = NSLocalizedString("InfoViewController.stolpersteineText", comment: "")
        stolpersteineInfoButton?.setTitle(NSLocalizedString("InfoViewController.stolpersteineInfoTitle", comment: ""), for: .normal)
        artistInfoButton?.setTitle(NSLocalizedString("InfoViewController.artistInfoTitle", comment: ""), for: .normal)
        
        // About
        let formatString = NSLocalizedString("InfoViewController.aboutText", comment: "")
        aboutLabel?.text = String(format: formatString, ConfigurationService.appShortVersion ?? "-", ConfigurationService.appVersion ?? "-")
        ratingButton?.setTitle(NSLocalizedString("InfoViewController.ratingTitle", comment: ""), for: .normal)
        recommendButton?.setTitle(NSLocalizedString("InfoViewController.recommendTitle", comment: ""), for: .normal)
        
        // Acknowledgements
        sourcesLabel?.text = NSLocalizedString("InfoViewController.sourcesText", comment: "")
        berlinKSSButton?.setTitle(NSLocalizedString("InfoViewController.berlinKSSTitle", comment: ""), for: .normal)
        bochumAFGButton?.setTitle(NSLocalizedString("InfoViewController.bochumAFGTitle", comment: ""), for: .normal)
        berlinWikipediaButton?.setTitle(NSLocalizedString("InfoViewController.berlinWikipediaTitle", comment: ""), for: .normal)
        acknowledgementsLabel?.text = NSLocalizedString("InfoViewController.acknowledgementsText", comment: "")
        contactButton?.setTitle(NSLocalizedString("InfoViewController.contactTitle", comment: ""), for: .normal)
        gitHubButton?.setTitle(NSLocalizedString("InfoViewController.gitHubTitle", comment: ""), for: .normal)
        
        legalLabel?.text = NSLocalizedString("InfoViewController.legalText", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #warning("Re-enable tracking")
        //[AppDelegate.diagnosticsService trackViewWithClass:self.class];
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (label, padding): (UILabel?, CGFloat?) = {
            switch (indexPath.section, indexPath.row) {
            case (Constants.Section.Stolpersteine, 0):
                return (stolpersteineLabel, Constants.Padding.Stolpersteine)
            case (Constants.Section.About, 0):
                return (aboutLabel, Constants.Padding.About)
            case (Constants.Section.Acknowledgements, 0):
                return (sourcesLabel, Constants.Padding.Sources)
            case (Constants.Section.Acknowledgements, 4):
                return (acknowledgementsLabel, Constants.Padding.Acknowledgements)
            case (Constants.Section.Legal, 0):
                return (legalLabel, Constants.Padding.Legal)
            default:
                return (nil, nil)
            }
        }()
        
        if let label = label {
            let width = tableView.frame.size.width - Constants.Padding.Left - Constants.Padding.Right
            label.preferredMaxLayoutWidth = width
            
            // the original objective-c code was not directly transferable to swift - test if this wors
//            CGRect boundingRect = [label.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
//            height = ceil(boundingRect.size.height) + padding;
            label.sizeToFit()
            
            return ceil(label.frame.height) + (padding ?? 0)
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Constants.Section.Stolpersteine:
            return NSLocalizedString("InfoViewController.stolpersteineSection", comment: "")
        case Constants.Section.About:
            return NSLocalizedString("InfoViewController.aboutSection", comment: "")
        case Constants.Section.Acknowledgements:
            return NSLocalizedString("InfoViewController.acknowledgementsSection", comment: "")
        case Constants.Section.Legal:
            return NSLocalizedString("InfoViewController.legalSection", comment: "")
        default:
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var urlString: String? = nil
        var diagnosticsLabel: String? = nil
        
        switch (indexPath.section, indexPath.row) {
        case (Constants.Section.Stolpersteine, 1):
            urlString = NSLocalizedString("InfoViewController.wikipediaURL", comment: "")
            diagnosticsLabel = "wikipedia"
        case (Constants.Section.Stolpersteine, 2):
            urlString = NSLocalizedString("InfoViewController.demnigURL", comment: "")
            diagnosticsLabel = "demnig"
        case (Constants.Section.About, 1):
            urlString = "itms-apps://itunes.apple.com/app/id\(Constants.AppStoreID)"
            diagnosticsLabel = "appStore"
        case (Constants.Section.About, 2):
            let subject = NSLocalizedString("InfoViewController.recommendationSubject", comment: "")
            let message = NSLocalizedString("InfoViewController.recommendationMessage", comment: "")
            sendMail(withRecipient: nil, subject: subject, message: message)
            diagnosticsLabel = "recommendation"
        case (Constants.Section.Acknowledgements, 1):
            urlString = NSLocalizedString("InfoViewController.berlinKSSURL", comment: "")
            diagnosticsLabel = "kssBerlin"
        case (Constants.Section.Acknowledgements, 2):
            urlString = NSLocalizedString("InfoViewController.bochumAFGURL", comment: "")
            diagnosticsLabel = "wikipediaBerlin"
        case (Constants.Section.Acknowledgements, 3):
            urlString = NSLocalizedString("InfoViewController.berlinWikipediaURL", comment: "")
            diagnosticsLabel = "wikipediaBerlin"
        case (Constants.Section.Acknowledgements, 5):
            let subject = NSLocalizedString("InfoViewController.contactSubject", comment: "")
            let messageFormat = NSLocalizedString("InfoViewController.contactMessage", comment: "")
            let message = String(format: messageFormat, ConfigurationService.appShortVersion ?? "-", ConfigurationService.appVersion ?? "-")
            #warning("adapt mail address")
            sendMail(withRecipient: "stolpersteine@option-u.com", subject: subject, message: message)
            
            diagnosticsLabel = "contact"
        case (Constants.Section.Acknowledgements, 6):
            #warning("Adapt Github URL")
            urlString = NSLocalizedString("InfoViewController.gitHubURL", comment: "")
            diagnosticsLabel = "gitHub"
        default:
            urlString = nil
            diagnosticsLabel = nil
        }
        
        #warning("Re-enable Analytics")
//        [AppDelegate.diagnosticsService trackEvent:DiagnosticsServiceEventInfoItemTapped withClass:self.class label:diagnosticsLabel];
        
        if let urlString = urlString, let url = URL(string: urlString),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func sendMail(withRecipient recipient: String?, subject: String, message: String) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let composeViewController = MFMailComposeViewController()
        composeViewController.mailComposeDelegate = self
        if let recipient = recipient {
            composeViewController.setToRecipients([recipient])
        }
        composeViewController.setSubject(subject)
        composeViewController.setMessageBody(message, isHTML: false)
        
        present(composeViewController, animated: true, completion: nil)
    }

    @IBAction func close(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
