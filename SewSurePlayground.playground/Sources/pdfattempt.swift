//import UIKit
//import CoreGraphics
//import Metal
//import MetalKit
//import MetalPerformanceShaders
//import CoreImage
//
//do {
//    guard let url = Bundle.main.url(forResource: "Atlas Wrap Dress Instructions", withExtension: "pdf") else {
//        fatalError("Failed to find PDF.")
//    }
//    let images = getEmbeddedImage(url: url, pageIndex: 0)
////    let image = images[2]
//    
////    guard let ciImage = CIImage(image: image) else {
////       fatalError("oh no")
////   }
////    guard let img =  wrapImageWithWhiteBorder(image: ciImage, borderWidth: 50.0) else {
////        fatalError("oh no")
////    }
////    applySobelEdgeDetection(ciImage: img)
//    
//}
//catch let error {
//    print(error.localizedDescription)
//}
//
//func getEmbeddedImage(url: URL, pageIndex: Int) -> [String] {
//    guard let document = CGPDFDocument(url as CFURL) else {
//        print("Couldn't open PDF.")
//        return []
//    }
//    // `page(at:)` uses pages numbered starting at 1.
//    let page = pageIndex + 1
//    guard let pdfPage = document.page(at: page), let dictionary = pdfPage.dictionary else {
//        print("Couldn't open page.")
//        return []
//    }
//    
//    var res: CGPDFDictionaryRef?
//    guard CGPDFDictionaryGetDictionary(dictionary, "Resources", &res), let resources = res else {
//        print("Couldn't get Resources.")
//        return []
//    }
//    var xObj: CGPDFDictionaryRef?
//    guard CGPDFDictionaryGetDictionary(resources, "XObject", &xObj), let xObject = xObj else {
//        print("Couldn't load page XObject.")
//        return []
//    }
//    
//    var imageKeys = [String]()
//    CGPDFDictionaryApplyBlock(xObject, { key, object, _ in
//        var stream: CGPDFStreamRef?
//        guard CGPDFObjectGetValue(object, .stream, &stream),
//            let objectStream = stream,
//            let streamDictionary = CGPDFStreamGetDictionary(objectStream) else { return true }
//        var subtype: UnsafePointer<Int8>?
//        guard CGPDFDictionaryGetName(streamDictionary, "Subtype", &subtype), let subtypeName = subtype else { return true }
//        
//        if String(cString: subtypeName) == "Image" {
//            imageKeys.append(String(cString: key))
//        }
//        return true
//    }, nil)
//
////    let allPageImages = imageKeys.compactMap { imageKey -> UIImage? in
////        var stream: CGPDFStreamRef?
////        guard CGPDFDictionaryGetStream(xObject, imageKey, &stream), let imageStream = stream else {
////            print("Couldn't get image stream.")
////            return nil
////        }
////        var format: CGPDFDataFormat = .raw
////        guard let data = CGPDFStreamCopyData(imageStream, &format) else {
////            print("Couldn't convert image stream to data.")
////            return nil
////        }
////        guard let image = UIImage(data: data as Data) else {
////            print("Couldn't convert image data to image.")
////            return nil
////        }
////        return image
////    }
//    return []
//}
//
//
//func makeBlackTransparentInsideShape(ciImage: CIImage, maskCIImage: CIImage) -> UIImage? {
// 
//    let maskedVariableBlurFilter = CIFilter(name: "CIMaskedVariableBlur")
//    maskedVariableBlurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
//    maskedVariableBlurFilter?.setValue(maskCIImage, forKey: "inputMask")
//    maskedVariableBlurFilter?.setValue(10.0, forKey: "inputRadius") // Adjust the blur radius as needed
//    
//    if let outputImage = maskedVariableBlurFilter?.outputImage {
//        let context = CIContext(options: nil)
//        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//            return UIImage(cgImage: cgImage)
//        }
//    }
//    
//    return nil
//}
//
//func applySobelEdgeDetection(ciImage: CIImage) -> UIImage? {
//    
//   
//   let edgeFilter = CIFilter(name: "CIEdges")
//   edgeFilter?.setValue(ciImage, forKey: kCIInputImageKey)
//   edgeFilter?.setValue(1, forKey: "inputIntensity") // Set the intensity for edge detection
//   
//   guard let edgeImage = edgeFilter?.outputImage else {
//       return nil
//   }
//    
//    edgeImage
//   
//   let maskFilter = CIFilter(name: "CIBlendWithMask")
//   maskFilter?.setValue(ciImage, forKey: kCIInputImageKey)
//   maskFilter?.setValue(edgeImage, forKey: kCIInputMaskImageKey)
//   
//   if let outputImage = maskFilter?.outputImage {
//       let context = CIContext(options: nil)
//       if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//           return UIImage(cgImage: cgImage)
//       }
//   }
//   
//   return nil
//}
//
//func wrapImageWithWhiteBorder(image: CIImage, borderWidth: CGFloat) -> CIImage? {
//    
//    let imageSize = image.extent.size
//    
//    // Calculate the size of the wrapped image
//    let wrappedSize = CGSize(width: imageSize.width + 2 * borderWidth, height: imageSize.height + 2 * borderWidth)
//    
//    // Create the white border rectangle
//    let borderRect = CGRect(origin: CGPoint.zero, size: wrappedSize)
//    
//    // Create a solid white color
//    let whiteColor = CIColor(red: 1.0, green: 1.0, blue: 1.0)
//    
//    // Create a white image with the border size
//    let whiteImage = CIImage(color: whiteColor).cropped(to: borderRect)
//    
//    // Crop the original image to fit within the border
//    let croppedImage = image.cropped(to: image.extent)
//    
//    // Calculate the translation to position the cropped image within the border
//    let translation = CGAffineTransform(translationX: borderWidth, y: borderWidth)
//    
//    // Apply the translation to the cropped image
//    let translatedImage = croppedImage.transformed(by: translation)
//    
//    // Composite the white border image and the translated image
//    let compositeImage = translatedImage.composited(over: whiteImage)
//    
//    return compositeImage
//}
//
//func applyFilter(inputImage: UIImage) {
//    do {
//        
//        
////        // Get the GPU
////        guard let device = MTLCreateSystemDefaultDevice() else {
////            print("Metal is not supported on this device")
////            return
////        }
////
////        // Make the command queue
////        guard let commandQueue = device.makeCommandQueue() else {
////            print("Failed to create command queue")
////            return
////        }
////
////        // Make the command buffer
////        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
////            print("Failed to create command buffer")
////            return
////        }
////
////        // Create the CG Image
////        guard let inputCGImage = inputImage.cgImage else {
////            print("Failed to create CGImage from UIImage.")
////            return
////        }
////
////        // Create the input texture
////        let textureLoader = MTKTextureLoader(device: device)
////        let inputTexture = try textureLoader.newTexture(cgImage: inputCGImage, options: [:])
////
////        inputTexture.pixelFormat
////
////        // Create the output texture
////        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: inputTexture.pixelFormat, width: inputTexture.width, height: inputTexture.height, mipmapped: false)
////        guard let outputTexture = device.makeTexture(descriptor: textureDescriptor) else {
////            print("Failed to create output texture")
////            return
////        }
////
////        // Create Sobel filter
////        let sobel = MPSImageSobel(device: device)
////        sobel.encode(commandBuffer: commandBuffer, sourceTexture: inputTexture, destinationTexture: outputTexture)
////
////        commandBuffer.commit()
////        commandBuffer.waitUntilCompleted()
////
////        // Create a buffer to hold the output texture data
////        let outputBytesPerRow = inputCGImage.bytesPerRow
////        let outputBytes = UnsafeMutableRawPointer.allocate(byteCount: outputBytesPerRow * outputTexture.height, alignment: MemoryLayout<UInt8>.alignment)
////
////        // Copy the output texture data to the buffer
////        outputTexture.getBytes(outputBytes, bytesPerRow: outputBytesPerRow, from: MTLRegionMake2D(0, 0, outputTexture.width, outputTexture.height), mipmapLevel: 0)
////
////        // Create a data provider from the buffer
////        let outputData = NSData(bytesNoCopy: outputBytes, length: outputBytesPerRow * outputTexture.height, freeWhenDone: true)
////
////        // Create a CGImage from the data provider
////        guard let outputCGImage = CGImage(width: outputTexture.width, height: outputTexture.height, bitsPerComponent: inputCGImage.bitsPerComponent, bitsPerPixel: inputCGImage.bitsPerPixel, bytesPerRow: inputCGImage.bytesPerRow, space: inputCGImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue, provider: CGDataProvider(data: outputData)!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
////            print("Failed to create output CG image")
////            return
////        }
////
////        // Create a UIImage from the CGImage
////        UIImage(cgImage: outputCGImage)
//    }
//    catch let error {
//        fatalError(error.localizedDescription)
//    }
//}
//
//func testImage() {
//    guard let imagePath = Bundle.main.path(forResource: "rainbow", ofType: "png") else {
//        print("Image file not found.")
//        return
//    }
//    guard let image = UIImage(contentsOfFile: imagePath) else {
//        print("Failed to create UIImage from file")
//        return
//    }
//    applyFilter(inputImage: image)
//}
//
