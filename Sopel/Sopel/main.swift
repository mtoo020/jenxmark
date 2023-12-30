//
//  Sopel.swift
//  Sopel
//
//  Created by Mark Tooley on 17/07/23.
//

import Foundation
import MetalKit

@main
func calculate() {
  
    // Create the Metal device & compute shaders, etc.
    guard let device = MTLCreateSystemDefaultDevice() else {
        print("GPU is not supported")
        return
    }
    guard let library = device.makeDefaultLibrary() else {
        print("Cannot find library")
        return
    }
    print("made it this far")
    
   
}
