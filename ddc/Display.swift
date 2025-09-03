//
//  Display.swift
//  ddc
//
//  Created by Győrvári Gábor on 2025. 09. 03..
//

class Display {
    let identifier: CGDirectDisplayID
    // compund data let prefsId: String
    var name: String
    var vendorNumber: UInt32?
    var modelNumber: UInt32?
    var serialNumber: UInt32?
    var arm64avService: IOAVService?
    
    init(_ identifier: CGDirectDisplayID, name: String, vendorNumber: UInt32?, modelNumber: UInt32?, serialNumber: UInt32?) {
        self.identifier = identifier
        self.name = name
        self.vendorNumber = vendorNumber
        self.modelNumber = modelNumber
        self.serialNumber = serialNumber
    }
}

func configureDisplays() ->  [Display] {
    var displays: [Display] = []
    var onlineDisplayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
    var displayCount: UInt32 = 0
    guard CGGetOnlineDisplayList(16, &onlineDisplayIDs, &displayCount) == .success else {
        print("Unable to get display list.")
        return []
    }
    for onlineDisplayID in onlineDisplayIDs where onlineDisplayID != 0 {
        let name = "YYY"
        let id = onlineDisplayID
        let vendorNumber = CGDisplayVendorNumber(onlineDisplayID)
        let modelNumber = CGDisplayModelNumber(onlineDisplayID)
        let serialNumber = CGDisplaySerialNumber(onlineDisplayID)
        let d = Display(id, name: name, vendorNumber: vendorNumber, modelNumber: modelNumber, serialNumber: serialNumber)
        displays.append(d)
    }
    return displays
}

