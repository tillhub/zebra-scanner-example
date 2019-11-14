//
//  ViewController.swift
//  TillhubZebraExample
//
//  Created by Baris Atamer on 11/13/19.
//  Copyright © 2019 Tillhub. All rights reserved.
//

import UIKit
import ZebraScanner
import PromiseKit

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
            deactivateZebra().done { _ in
                self.addLog("✅ Deactivated")
                self.switchButton.setTitle("Activate", for: .normal)
            }.catch { error in
                self.addLog("❌ Error: \(error)")
            }
        } else {
            addLog("⌛️ Activating...")
            self.switchButton.setTitle("Activating...", for: .normal)
            activateZebra().done { _ in
                self.addLog("✅ Activated")
                self.switchButton.setTitle("Deactivate", for: .normal)
            }.catch { error in
                self.addLog("❌ Error: \(error)")
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

extension ViewController {
    
    private func deactivateZebra() -> Promise<Void> {
        return Promise { seal in
            zebraManager.deactivate { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill_()
                }
            }
        }
    }
    
    private func activateZebra() -> Promise<Void> {
        return Promise { seal in
            zebraManager.activate { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill_()
                }
            }
        }
    }
}
