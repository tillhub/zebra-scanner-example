//
//  ZebraTypes.swift
//  ZebraScanner
//
//  Created by Andreas Hilbert on 26.10.19.
//  Copyright © 2019 Andreas Hilbert. All rights reserved.
//

import Foundation


public enum ZebraConnectionMode: String, Codable {
    case invalid
    case mfi
    case btle
    
    public var connectionType: Int32 {
        switch self {
        case .invalid: return Int32(SBT_CONNTYPE_INVALID)
        case .mfi: return Int32(SBT_CONNTYPE_MFI)
        case .btle: return Int32(SBT_CONNTYPE_BTLE)
        }
    }
    
    public init(type: Int32) {
        switch type {
        case Int32(SBT_CONNTYPE_MFI): self = .mfi
        case Int32(SBT_CONNTYPE_BTLE): self = .btle
        default: self = .invalid
        }
    }
}

public enum ZebraModel: String, Codable {
    case invalid = "INVALID"
    case ssiRFD8500 = "SSI RFD8500"
    case ssiCS4070 = "SSI CS4070"
    case ssiLI3678 = "SSI LI3678"
    case ssiDS3678 = "SSI DS3678"
    case ssiDS8178 = "SSI DS8178"
    case ssiDS2278 = "SSI DS2278"
    case ssiGENERIC = "SSI GENERIC"
    case rfidRFD8500 = "RFID RFD8500"
    
    public init(model: Int32) {
        switch model {
        case Int32(SBT_DEVMODEL_SSI_RFD8500): self = .ssiRFD8500
        case Int32(SBT_DEVMODEL_SSI_CS4070): self = .ssiCS4070
        case Int32(SBT_DEVMODEL_SSI_LI3678): self = .ssiLI3678
        case Int32(SBT_DEVMODEL_SSI_DS3678): self = .ssiDS3678
        case Int32(SBT_DEVMODEL_SSI_DS8178): self = .ssiDS8178
        case Int32(SBT_DEVMODEL_SSI_DS2278): self = .ssiDS2278
        case Int32(SBT_DEVMODEL_SSI_GENERIC): self = .ssiGENERIC
        case Int32(SBT_DEVMODEL_RFID_RFD8500): self = .rfidRFD8500
        default: self = .invalid
        }
    }
    
    public var modelType: Int32 {
        switch self {
        case .invalid: return Int32(SBT_DEVMODEL_INVALID)
        case .ssiRFD8500: return Int32(SBT_DEVMODEL_SSI_RFD8500)
        case .ssiCS4070: return Int32(SBT_DEVMODEL_SSI_CS4070)
        case .ssiLI3678: return Int32(SBT_DEVMODEL_SSI_LI3678)
        case .ssiDS3678: return Int32(SBT_DEVMODEL_SSI_DS3678)
        case .ssiDS8178: return Int32(SBT_DEVMODEL_SSI_DS8178)
        case .ssiDS2278: return Int32(SBT_DEVMODEL_SSI_DS2278)
        case .ssiGENERIC: return Int32(SBT_DEVMODEL_SSI_GENERIC)
        case .rfidRFD8500: return Int32(SBT_DEVMODEL_RFID_RFD8500)
        }
    }
    
    public var resetFactoryDefaultsCode: String {
        switch self {
        case .ssiDS2278: return "92"
        default: return "92"
        }
    }
    
    public var btleSsiCode: String {
        switch self {
        case .ssiDS2278: return "N017F17"
        default: return "N017F17"
        }
    }
}

extension SbtScannerInfo {
    public override var description: String {
        return ZebraInfo(info: self).description
    }
}

public struct ZebraInfo: Codable {
    public let scannerId: Int32
    public var connectionType: ZebraConnectionMode
    public var autoCommunicationSessionReestablishment: Bool
    public var isActive: Bool
    public var isAvailable: Bool
    public let name: String
    public let model: ZebraModel
    
    public init(info: SbtScannerInfo) {
        self.scannerId = info.getScannerID()
        self.connectionType = ZebraConnectionMode(type: info.getConnectionType())
        self.autoCommunicationSessionReestablishment = info.getAutoCommunicationSessionReestablishment()
        self.isActive = info.isActive()
        self.isAvailable = info.isAvailable()
        self.name = info.getScannerName()
        self.model = ZebraModel(model: info.getScannerModel())
    }
    
    public init(scannerId: Int32,
         connectionType: ZebraConnectionMode = .btle,
         autoCommunicationSessionReestablishment: Bool = false,
         isActive: Bool = false,
         isAvailable: Bool = false,
         name: String = "Dummy",
         model: ZebraModel = .ssiDS2278) {
        self.scannerId = scannerId
        self.connectionType = connectionType
        self.autoCommunicationSessionReestablishment = autoCommunicationSessionReestablishment
        self.isActive = isActive
        self.isAvailable = isAvailable
        self.name = name
        self.model = model
    }
    
    public var description: String {
        return "\(self.name)(\(self.scannerId)) : \(self.model), isActive: \(self.isActive) isAvailable: \(self.isAvailable)"
    }
}
