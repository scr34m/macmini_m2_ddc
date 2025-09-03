//
//  main.swift
//  dcc
//
//  Created by Győrvári Gábor on 23/04/2024.
//

import Foundation
import Cocoa
import CoreGraphics
import os.log

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

var displays: [Display] = []
   
func configureDisplays() {
  displays = []
  var onlineDisplayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
  var displayCount: UInt32 = 0
  guard CGGetOnlineDisplayList(16, &onlineDisplayIDs, &displayCount) == .success else {
    print("Unable to get display list.")
    return
  }
  for onlineDisplayID in onlineDisplayIDs where onlineDisplayID != 0 {
    let name = "YYY"
    let id = onlineDisplayID
    let vendorNumber = CGDisplayVendorNumber(onlineDisplayID)
    let modelNumber = CGDisplayModelNumber(onlineDisplayID)
    let serialNumber = CGDisplaySerialNumber(onlineDisplayID)
    let d = Display(id, name: name, vendorNumber: vendorNumber, modelNumber: modelNumber, serialNumber: serialNumber)
    os_log("Other display found - %{public}@", "ID: \(d.identifier), Name: \(d.name) (Vendor: \(d.vendorNumber ?? 0), Model: \(d.modelNumber ?? 0))")
    displays.append(d)
  }
}

configureDisplays()

enum Command:Int{
    case Brightness = 0x10
    case Contrast = 0x12
    case InputSource = 0x60
    case AutoAdjust = 0x18
    case PowerMode = 0xD6
    
    static let allValues = [Brightness, Contrast, InputSource, AutoAdjust, PowerMode]
}

let s = AppleSiliconDDC.getServiceMatches(displayIDs: [displays[0].identifier])
print(s[0])

for command in Command.allValues{
    let v = AppleSiliconDDC.read(service: s[0].service, command: UInt8(command.rawValue))
    print("\(command) \(v?.current ?? 0) / \(v?.max ?? 0)")
}

// switch input to HDMI 2
AppleSiliconDDC.write(service: s[0].service, command: 0x60, value: 18)
