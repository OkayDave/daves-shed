#!/usr/bin/env swift
import Foundation
import CoreGraphics

while true {
    guard let event = CGEvent(source: nil) else {
        print("0,0")
        fflush(stdout)
        usleep(50000)
        continue
    }
    let location = event.location
    print("\(Int(location.x)),\(Int(location.y))")
    fflush(stdout)

    break;
}
