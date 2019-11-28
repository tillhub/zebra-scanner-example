//
//  ZebraManager.swift
//  ZebraScanner
//
//  Created by Andreas Hilbert on 23.10.19.
//  Copyright © 2019 Andreas Hilbert. All rights reserved.
//

import Foundation

// TODO: read https://github.com/Shashank2406/cordova-plugin-zebra-scanner-ios/blob/master/src/ios/ZebraScanner.m

public protocol ZebraLogger {
    func log(_ message: String, level: ZebraLogLevel)
}

public protocol ZebraManagerDelegate: class {
    func updated(scanners: [ZebraInfo])
}

public enum ZebraLogLevel: String {
    case error
    case warning
    case info
    case debug
    case verbose
}

public enum ZebraManagerError: LocalizedError {
    case apiIsNotActive
    case apiIsAlreadyActive
    case scannerIsNotConnected
    case scannerIsAlreadyConnected
    
    public var errorDescription: String? {
        switch self {
        case .apiIsNotActive:
            return "zebra_error_api_is_not_active".localized()
        case .apiIsAlreadyActive:
            return "zebra_error_api_is_already_active".localized()
        case .scannerIsNotConnected:
            return "zebra_error_scanner_is_not_connected".localized()
        case .scannerIsAlreadyConnected:
            return "zebra_error_scanner_is_already_connected".localized()
        }
    }
}

public class ZebraManager: NSObject {
    
    public static let shared = ZebraManager()
    
    public init(zebraAPI: ISbtSdkApi = SbtSdkFactory.createSbtSdkApiInstance()) {
        self.zebraAPI = zebraAPI
        super.init()
        self.subscribeNotifications()
    }
    
    public var logger: ZebraLogger?
    public var errorHandler: ErrorHandler?
    public weak var delegate: ZebraManagerDelegate?
    
    public var isActivated: Bool {
        return isActive
    }
    
    public var scanners: [ZebraInfo] {
        return infos.sorted(by: {$0.key < $1.key}).compactMap({ $0.value })
    }
    
    public var scannersToStore: [ZebraInfo] {
        return desired.compactMap { info(for: $0) ?? ZebraInfo(scannerId: $0) }
    }
    
    public func activate(completion: ErrorCompletion?) {
        perform({ try self.activateApi() }, completion: completion)
    }
    
    public func deactivate(completion: ErrorCompletion?) {
        perform({ try self.deactivateApi() }, completion: completion)
    }
    
    public func connect(scannerId: Int32, completion: ErrorCompletion?) {
        perform({ try self.connect(scannerId) }, completion: completion)
    }
    
    public func disconnect(scannerId: Int32, completion: ErrorCompletion?) {
        desiredRemove(scannerId)
        perform({ try self.disconnect(scannerId) }, completion: completion)
    }
    
    // should not yet be used
    public func setReconnection(info: ZebraInfo, isAutomatic: Bool, completion: ErrorCompletion?) {
        perform({ self.zebraAPI.sbtEnableAutomaticSessionReestablishment(isAutomatic, forScanner: info.scannerId) }, completion: completion)
    }
    
    // MARK: - Private State
    
    private let zebraAPI: ISbtSdkApi
    private let managerQueue = DispatchQueue(label: "de.tillhub.zebraScannerDeviceManager.managerQueue", qos: .utility)
    private let sdkQueue = DispatchQueue(label: "de.tillhub.zebraScannerDeviceManager.sdkQueue", qos: .utility)
    private let listQueue = DispatchQueue(label: "de.tillhub.zebraScannerDeviceManager.listQueue", qos: .utility)
    private var isActive: Bool = false
    private var wasOnceActivated: Bool = false
    
    // MARK: - Private Helpers
    
    typealias SBT_Block = () -> SBT_RESULT
    
    private static func perform(_ block: SBT_Block) throws {
        let result = block()
        guard result == SBT_RESULT_SUCCESS else {
            throw ZebraError.statusError(error: result)
        }
    }
    
    private func perform(_ block: @escaping SBT_Block, completion: ErrorCompletion?) {
        self.sdkQueue.async {
            var performError: Error?
            do {
                try ZebraManager.perform(block)
            } catch let error {
                performError = error
            }
            DispatchQueue.main.async {
                completion?(performError)
            }
        }
    }
    
    private func perform(_ block: @escaping (() throws -> ()), completion: ErrorCompletion?) {
        self.sdkQueue.async {
            var performError: Error?
            do {
                try block()
            } catch let error {
                performError = error
            }
            DispatchQueue.main.async {
                completion?(performError)
            }
        }
    }
    
    // MARK: - Scanner List
    
    private var _infos: Dictionary<Int32, ZebraInfo> = [:]
    private var infos: Dictionary<Int32, ZebraInfo> { return listQueue.sync { return _infos } }
    private func set(info: ZebraInfo, for id: Int32) { listQueue.sync { _infos[id] = info }; notify() }
    private func info(for id: Int32) -> ZebraInfo? { return listQueue.sync { return _infos[id] } }
    private func removeInfo(for id: Int32) { listQueue.sync { _ = _infos.removeValue(forKey: id) }; notify() }
    private func removeAllInfo() { listQueue.sync { _infos.removeAll() }; notify() }
    private func notify() { DispatchQueue.main.async { self.delegate?.updated(scanners: self.scanners) } }
    
    private func getAvailableScanners() throws -> [ZebraInfo] {
        var list: NSMutableArray? = NSMutableArray()
        let result = self.zebraAPI.sbtGetAvailableScannersList(&list)
        if result == SBT_RESULT_SUCCESS, let infos = list as? [SbtScannerInfo] {
            return infos.compactMap({ ZebraInfo(info: $0) })
        } else {
            throw ZebraError.statusError(error: result)
        }
    }
    
    private func getActiveScanners() throws -> [ZebraInfo] {
        var list: NSMutableArray? = NSMutableArray()
        let result = self.zebraAPI.sbtGetActiveScannersList(&list)
        if result == SBT_RESULT_SUCCESS, let infos = list as? [SbtScannerInfo] {
            return infos.compactMap({ ZebraInfo(info: $0) })
        } else {
            throw ZebraError.statusError(error: result)
        }
    }
    
    private func fillScannerList() throws {
        try ZebraManager.perform({ self.zebraAPI.sbtEnableAvailableScannersDetection(false) })
        try getAvailableScanners().forEach({ set(info: $0, for: $0.scannerId) })
        try getActiveScanners().forEach({ set(info: $0, for: $0.scannerId) })
        try ZebraManager.perform({ self.zebraAPI.sbtEnableAvailableScannersDetection(true) })
    }
    
    // MARK: - Desired Scanners
    
    private var _desired: Set<Int32> = []
    private var desired: Set<Int32> { return listQueue.sync { return _desired } }
    private func desiredInsert(_ id: Int32) { listQueue.sync { _ = _desired.insert(id) } }
    private func desiredRemove(_ id: Int32) { listQueue.sync { _ = _desired.remove(id) } }
    private func desiredContains(_ id: Int32) -> Bool { return listQueue.sync { return _desired.contains(id) } }
    
    private func connect(_ id: Int32) throws {
        desiredInsert(id)
        if let info = self.info(for: id), info.isActive == true {
            throw ZebraManagerError.scannerIsAlreadyConnected
        }
        try ZebraManager.perform({ self.zebraAPI.sbtEstablishCommunicationSession(id) })
    }
    
    private func disconnect(_ id: Int32) throws {
        if let info = self.info(for: id), info.isActive == false {
            throw ZebraManagerError.scannerIsNotConnected
        }
        try ZebraManager.perform({ self.zebraAPI.sbtTerminateCommunicationSession(id) })
    }
    
    private enum ConnectionAction {
        case connect
        case disconnect
    }
    
    private func allDesired(action: ConnectionAction) {
        desired.map({ $0 }).forEach({ id in
            switch action {
            case .connect:
                try? self.connect(id)
            case .disconnect:
                try? self.disconnect(id)
            }
        })
    }
    
    // MARK: - Global Activation
    
    private struct Constants {
        static let eventMask: Int32 = Int32(SBT_EVENT_BARCODE) | Int32(SBT_EVENT_IMAGE) | Int32(SBT_EVENT_SCANNER_APPEARANCE) | Int32(SBT_EVENT_SCANNER_DISAPPEARANCE) | Int32(SBT_EVENT_SESSION_ESTABLISHMENT) | Int32(SBT_EVENT_SESSION_TERMINATION)
    }
    
    private func activateApi() throws {
        cancelDelayedAction()
        guard isActive == false else {
            throw ZebraManagerError.apiIsAlreadyActive
        }
        try ZebraManager.perform({ zebraAPI.sbtSetOperationalMode(Int32(SBT_OPMODE_ALL)) })
        try ZebraManager.perform({ self.zebraAPI.sbtSetDelegate(self) })
        try ZebraManager.perform({ zebraAPI.sbtSubsribe(forEvents: Constants.eventMask) })
        isActive = true
        if wasOnceActivated {
            try fillScannerList()
        } else {
            try ZebraManager.perform({ zebraAPI.sbtEnableAvailableScannersDetection(true) })
            wasOnceActivated = true
        }
        allDesired(action: .connect)
    }
    
    private func deactivateApi() throws {
        guard isActive == true else {
            throw ZebraManagerError.apiIsNotActive
        }
        allDesired(action: .disconnect)
        try ZebraManager.perform({ self.zebraAPI.sbtEnableAvailableScannersDetection(false) })
        try ZebraManager.perform({ self.zebraAPI.sbtUnsubsribe(forEvents: Constants.eventMask) })
        try ZebraManager.perform({ self.zebraAPI.sbtSetDelegate(nil) })
        isActive = false
        removeAllInfo()
    }
    
    // MARK: - Background Handling
    
    private var dispatchWorkItem: DispatchWorkItem?
    private var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    private func cancelDelayedAction() {
        dispatchWorkItem?.cancel()
        dispatchWorkItem = nil
    }
    
    private func startActivation() {
        cancelDelayedAction()
        self.activate { (error) in
            if let error = error {
                switch error {
                case ZebraManagerError.apiIsAlreadyActive:
                    break
                default:
                    self.logger?.log(error.localizedDescription, level: .debug)
                }
            }
        }
    }
    
    private func startDeactivation(after: TimeInterval) {
        cancelDelayedAction()
        let dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard self?.backgroundTaskID != nil else { return }
            self?.deactivate(completion: { (error) in
                if let error = error {
                    switch error {
                    case ZebraManagerError.apiIsAlreadyActive:
                        break
                    default:
                        self?.logger?.log(error.localizedDescription, level: .debug)
                    }
                }
                if let backgroundTaskID = self?.backgroundTaskID {
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    self?.backgroundTaskID = .invalid
                }
            })
        }
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = .invalid
        }
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + after, execute: dispatchWorkItem)
        self.dispatchWorkItem = dispatchWorkItem
    }
   
    
    // MARK: - Notifications
    
    private var observers: [NSObjectProtocol] = []
    
    private func subscribeNotifications() {
        let willEnterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { notification in
                self.startDeactivation(after: 25.0)
        })
        observers.append(willEnterBackgroundObserver)
        
        let willEnterForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { notification in
                self.startActivation()
        })
        observers.append(willEnterForegroundObserver)
    }
    
    private func unsubscribeNotifications() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }
}

// MARK: - ISbtSdkApiDelegate

extension ZebraManager: ISbtSdkApiDelegate {
    
    public func sbtEventScannerAppeared(_ availableScanner: SbtScannerInfo!) {
        if let availableScanner = availableScanner {
            logger?.log("sbtEventScannerAppeared: \(availableScanner)", level: .debug)
            let info = ZebraInfo(info: availableScanner)
            self.set(info: info, for: info.scannerId)
            if desiredContains(info.scannerId), info.isActive == false {
                connect(scannerId: info.scannerId) { (error) in
                    if let error = error {
                        self.errorHandler?.displayError(error)
                    }
                }
            }
        }
    }
    
    public func sbtEventScannerDisappeared(_ scannerID: Int32) {
        logger?.log("sbtEventScannerDisappeared: \(scannerID)", level: .debug)
        self.removeInfo(for: scannerID)
    }
    
    public func sbtEventCommunicationSessionEstablished(_ activeScanner: SbtScannerInfo!) {
        if let activeScanner = activeScanner {
            logger?.log("sbtEventCommunicationSessionEstablished: \(activeScanner)", level: .debug)
            let info = ZebraInfo(info: activeScanner)
            self.set(info: info, for: info.scannerId)
        }
    }
    
    public func sbtEventCommunicationSessionTerminated(_ scannerID: Int32) {
        logger?.log("sbtEventCommunicationSessionTerminated: \(scannerID)", level: .debug)
        if var info = info(for: scannerID) {
            info.isActive = false
            self.set(info: info, for: info.scannerId)
        }
    }
    
    // DEPRECATED
    // Don't implement this.
    // This and sbtEventBarcodeData functions are both called, resulting calling the barcode handler twice.
    public func sbtEventBarcode(_ barcodeData: String!, barcodeType: Int32, fromScanner scannerID: Int32) {
        // logger?.log("sbtEventBarcode: \(barcodeData), \(barcodeType), \(scannerID)", level: .debug)
        // if let barcode = barcodeData, barcode.isEmpty == false {
        //     BarcodeInputHandler.shared.handle(scanData: barcodeData)
        // }
    }
    
    public func sbtEventBarcodeData(_ barcodeData: Data!, barcodeType: Int32, fromScanner scannerID: Int32) {
        // logger?.log("sbtEventBarcodeData: \(barcodeData), \(barcodeType), \(scannerID)", level: .debug)
        if let data = barcodeData, let barcode = String(data: data, encoding: .utf8) {
            // BarcodeInputHandler.shared.handle(scanData: barcode)
            print("Barcode: \(barcode)")
        }
    }
    
    public func sbtEventFirmwareUpdate(_ fwUpdateEventObj: FirmwareUpdateEvent!) {
        // logger?.log("sbtEventFirmwareUpdate: \(fwUpdateEventObj)", level: .debug)
    }
    
    public func sbtEventImage(_ imageData: Data!, fromScanner scannerID: Int32) {
        // logger?.log("sbtEventImage: \(imageData), \(scannerID)", level: .debug)
    }
    
    public func sbtEventVideo(_ videoFrame: Data!, fromScanner scannerID: Int32) {
        // logger?.log("sbtEventVideo: \(videoFrame), \(scannerID)", level: .debug)
    }
}
