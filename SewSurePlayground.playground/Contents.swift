import UIKit

run()

func run() {
    guard let imagePath = Bundle.main.path(forResource: "Untitled", ofType: "png") else {
        print("Image file not found.")
        return
    }
    guard let image = UIImage(contentsOfFile: imagePath) else {
        print("Failed to create UIImage from file")
        return
    }
    bucketFillUsingCoreGraphics(image: image, point: CGPoint(x: 0, y: 0), fillColor: UIColor.green)
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
    floodFill(x: Int(point.x), y: Int(point.y), width: width, height: height,
              sourcePixels: mutablePointer, targetColor: targetColor, fillColor: fillColor)

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

func floodFill(x: Int, y: Int, width: Int, height: Int,
               sourcePixels: UnsafeMutablePointer<UInt8>, targetColor: UIColor, fillColor: UIColor) {
    // Check if the starting point is within bounds
    guard x >= 0 && x < width && y >= 0 && y < height else { return }

    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width

    // Create a stack to hold the points to be processed
    var stack = [(x, y)]

    // Define the target color components
    let targetColorComponents = targetColor.cgColor.components!

    // Define the fill color components
    let fillColorComponents = fillColor.cgColor.components!

    // Perform the flood fill using a stack-based approach
    while !stack.isEmpty {
        let (currentX, currentY) = stack.removeLast()

        // Check if the current point is within bounds and has the target color
        guard currentX >= 0 && currentX < width && currentY >= 0 && currentY < height else { continue }

        let pixelOffset = (currentY * bytesPerRow) + (currentX * bytesPerPixel)
        let pixel = sourcePixels + pixelOffset

        if pixel[0] == UInt8(targetColorComponents[0] * 255) &&
           pixel[1] == UInt8(targetColorComponents[1] * 255) &&
           pixel[2] == UInt8(targetColorComponents[2] * 255) {

            // Set the fill color for the current pixel
            pixel[0] = UInt8(fillColorComponents[0] * 255)
            pixel[1] = UInt8(fillColorComponents[1] * 255)
            pixel[2] = UInt8(fillColorComponents[2] * 255)

            // Add neighboring points to the stack
            stack.append((currentX + 1, currentY))
            stack.append((currentX - 1, currentY))
            stack.append((currentX, currentY + 1))
            stack.append((currentX, currentY - 1))
        }
    }
}
