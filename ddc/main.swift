//
//  main.swift
//  dcc
//
//  Created by Győrvári Gábor on 23/04/2024.
//

import Foundation
import Cocoa
import CoreGraphics

var displays : [Display] = configureDisplays()

func getDisplayService(_ id: Int32) -> IOAVService? {
    for display in displays {
        if (display.identifier == id) {
            let s = AppleSiliconDDC.getServiceMatches(displayIDs: [display.identifier])
            return s[0].service;
        }
    }
    return nil
}

func dump(_ service: IOAVService?) {
    enum Command:Int{
        case Brightness = 0x10
        case Contrast = 0x12
        case InputSource = 0x60
        case AutoAdjust = 0x18
        case PowerMode = 0xD6
        
        static let allValues = [Brightness, Contrast, InputSource, AutoAdjust, PowerMode]
    }
    for command in Command.allValues{
        let v = AppleSiliconDDC.read(service: service, command: UInt8(command.rawValue))
        print("\(command): \(v?.current ?? 0) / \(v?.max ?? 0)")
    }
}

/*
 // switch input to HDMI 2
 AppleSiliconDDC.write(service: s[0].service, command: 0x60, value: 18)
 */

let args = CommandLine.arguments
if CommandLine.argc == 1 {
    print("Displays: ")
    for display in displays {
        let s = AppleSiliconDDC.getServiceMatches(displayIDs: [display.identifier])
        if let dispAttr = s[0].serviceDetails.displayAttributes {
            if let prodAttr = dispAttr["ProductAttributes"] as? [String: Any]  {
                print("\(display.identifier): \(prodAttr["ProductName"] ?? "---")")
            }
        }
    }
    exit(0)
}

if CommandLine.argc < 3 {
    print("After command you must set the display ID")
    exit(1)
}

let displayId : Int32? = Int32(CommandLine.arguments[2])
if displayId == nil {
    print("Provided display ID is not numeric")
    exit(1)
}

let service : IOAVService? = getDisplayService(displayId!)
if service == nil {
    print("Unable to retrive the service for the selected display")
    exit(1)
}

let command = CommandLine.arguments[1]
switch command {
case "dump":
    dump(service)
default:
    print("Unknown command")
}
