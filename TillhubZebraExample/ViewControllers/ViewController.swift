//
//  ViewController.swift
//  TillhubZebraExample
//
//  Created by Baris Atamer on 11/13/19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import UIKit
import ZebraScanner

class ViewController: UIViewController {
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    
    private var zebraManager: ZebraManager {
        return ZebraManager.shared
    }
    
    // MARK: - Private Methods
    
    private func activate() {
        if zebraManager.isActivated {
            addLog("⌛️ Deactivating...")
            self.switchButton.setTitle("Deactivating...", for: .normal)
            
            zebraManager.deactivate { [weak self] error in
                if let error = error {
                    self?.addLog("❌ Error: \(error)")
                } else {
                    self?.addLog("✅ Deactivated")
                    self?.switchButton.setTitle("Activate", for: .normal)
                }
            }
        } else {
            addLog("⌛️ Activating...")
            self.switchButton.setTitle("Activating...", for: .normal)
            
            zebraManager.activate { [weak self] error in
                if let error = error {
                    self?.addLog("❌ Error: \(error)")
                } else {
                    self?.addLog("✅ Activated")
                    self?.switchButton.setTitle("Deactivate", for: .normal)
                }
            }
        }
    }
    
    private func addLog(_ text: String) {
        logTextView.text = "\(logTextView.text ?? "")\n\(text)"
        logTextView.contentOffset = CGPoint(x: 0, y: logTextView.contentSize.height - logTextView.frame.size.height)
    }
    
    // MARK: - IBActions
    
    @IBAction func switchButtonDidTap(_ sender: Any) {
        activate()
    }
}
