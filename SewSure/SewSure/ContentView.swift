//
//  ContentView.swift
//  SewSure
//
//  Created by Mark Tooley on 20/07/23.
//

import SwiftUI
import UIKit
import CoreGraphics
import CoreImage

struct ContentView: View {
    @State var img: UIImage = UIImage(named: "Untitled")!

    var body: some View {
        Image("fabric") // Replace "your_image_name" with the name of your image asset
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all) // Extend the image behind the status bar
            .overlay() {
                Image(uiImage: img).onAppear(perform: run)
            }
    }
    
    func run() {
        print("start")
        img = bucketFillUsingCoreGraphics(image: img, point: CGPoint(x: 0, y: 0), fillColor: UIColor.green)!
        print("done")
        
        let white: [UInt8] = [255, 255, 255, 255]
        let transparent: [UInt8] = [0, 0, 0, 0]
        let green: [UInt8] = [0, 255, 0, 255]
        img = replaceColour(image: img, colourToFind: white, replacementColour: transparent, tolerance: 60.0)!
        print("coloured")
        img = replaceColour(image: img, colourToFind: green, replacementColour: white, tolerance: 0.0)!
        print("coloured")
    }

    func bucketFillUsingCoreGraphics(image: UIImage, point: CGPoint, fillColor: UIColor) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height

        // Create a mutable copy of the image
        guard let mutableData = CFDataCreateMutableCopy(nil, 0, cgImage.dataProvider?.data),
              let mutablePointer = CFDataGetMutableBytePtr(mutableData) else { return nil }

        // Define the target color (the color at the tap point)
        let targetColor = getPixelColor(from: point, in: cgImage)

        // Early exit if the target color and fill color are the same
        guard targetColor != fillColor else { return image }

        // Perform the flood fill
        floodFillWithTolerance(x: Int(point.x), y: Int(point.y), width: width, height: height,
                               sourcePixels: mutablePointer, targetColor: targetColor, fillColor: fillColor, tolerance: 1.0)

        // Create a CGImage from the modified data
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow

        let context = CGContext(data: mutablePointer,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)

        guard let finalImageRef = context?.makeImage() else { return nil }

        // Create a UIImage from the final CGImage
        let finalImage = UIImage(cgImage: finalImageRef)

        return finalImage
    }

    func getPixelColor(from point: CGPoint, in cgImage: CGImage) -> UIColor {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * cgImage.width
        var pixelData = [UInt8](repeating: 0, count: bytesPerPixel)
        
        guard let context = CGContext(data: &pixelData,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let image = cgImage.cropping(to: CGRect(x: point.x, y: point.y, width: 1, height: 1)) else {
            return UIColor.black
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        let red = CGFloat(pixelData[0]) / 255.0
        let green = CGFloat(pixelData[1]) / 255.0
        let blue = CGFloat(pixelData[2]) / 255.0
        let alpha = CGFloat(pixelData[3]) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func floodFillWithTolerance(x: Int, y: Int, width: Int, height: Int,
                                sourcePixels: UnsafeMutablePointer<UInt8>, targetColor: UIColor,
                                fillColor: UIColor, tolerance: CGFloat) {
        // Check if the starting point is within bounds
        guard x >= 0 && x < width && y >= 0 && y < height else { return }

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        // Create a stack to hold the points to be processed
        var stack = [(x, y)]

        // Define the target color components
        let targetComponents = targetColor.cgColor.components!

        // Define the fill color components
        let fillComponents = fillColor.cgColor.components!

        // Perform the flood fill using a stack-based approach
        while !stack.isEmpty {
            let (currentX, currentY) = stack.removeLast()

            // Check if the current point is within bounds
            guard currentX >= 0 && currentX < width && currentY >= 0 && currentY < height else { continue }

            let pixelOffset = (currentY * bytesPerRow) + (currentX * bytesPerPixel)
            let pixel = sourcePixels + pixelOffset

            // Calculate the color difference between the target color and the current pixel
            let redDiff = CGFloat(pixel[0]) / 255.0 - targetComponents[0]
            let greenDiff = CGFloat(pixel[1]) / 255.0 - targetComponents[1]
            let blueDiff = CGFloat(pixel[2]) / 255.0 - targetComponents[2]
            let alphaDiff = CGFloat(pixel[3]) / 255.0 - targetComponents[3]
            let colorDifference = sqrt(redDiff * redDiff + greenDiff * greenDiff + blueDiff * blueDiff + alphaDiff * alphaDiff)

            // Check if the color difference is within the tolerance
            if colorDifference <= tolerance {
                // Set the fill color for the current pixel
                pixel[0] = UInt8(fillComponents[0] * 255)
                pixel[1] = UInt8(fillComponents[1] * 255)
                pixel[2] = UInt8(fillComponents[2] * 255)

                // Add neighboring points to the stack
                stack.append((currentX + 1, currentY))
                stack.append((currentX - 1, currentY))
                stack.append((currentX, currentY + 1))
                stack.append((currentX, currentY - 1))
            }
        }
    }
    
    func replaceColour(image: UIImage, colourToFind: [UInt8], replacementColour: [UInt8], tolerance: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height

        // Create a color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Allocate memory for the pixels
        var rawData = [UInt8](repeating: 0, count: width * height * 4)

        // Create a context with the pixel data
        let context = CGContext(data: &rawData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * 4,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

        // Draw the image into the context
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Iterate through the pixel data and make white pixels purple
        DispatchQueue.concurrentPerform(iterations: width * height) { index in
            let pixelOffset = index * 4

            let redDiff = CGFloat(rawData[pixelOffset]) - CGFloat(colourToFind[0])
            let greenDiff = CGFloat(rawData[pixelOffset + 1]) - CGFloat(colourToFind[1])
            let blueDiff = CGFloat(rawData[pixelOffset + 2]) - CGFloat(colourToFind[2])
            let alphaDiff = CGFloat(rawData[pixelOffset + 3]) - CGFloat(colourToFind[3])
            let colorDifference = sqrt(redDiff * redDiff + greenDiff * greenDiff + blueDiff * blueDiff + alphaDiff * alphaDiff)

            // Check if the color difference is within the tolerance
            if colorDifference <= tolerance {
                // Set the pixel's color to purple
                rawData[pixelOffset] = replacementColour[0]
                rawData[pixelOffset + 1] = replacementColour[1]
                rawData[pixelOffset + 2] = replacementColour[2]
                rawData[pixelOffset + 3] = replacementColour[3]
            }
        }

        // Create a CGImage from the modified pixel data
        if let newCGImage = context?.makeImage() {
            // Create a UIImage from the new CGImage
            let newImage = UIImage(cgImage: newCGImage)
            return newImage
        }

        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

