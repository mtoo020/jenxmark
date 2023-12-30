import CoreGraphics
import Metal
import MetalKit
import MetalPerformanceShaders
import CoreImage

do {
    let url = URL(fileURLWithPath: "/Users/mark/Downloads/rainbow-color.pdf")
    let images = getEmbeddedImage(url: url, pageIndex: 0)
//    let image = images[2]
    
//    guard let ciImage = CIImage(image: image) else {
//       fatalError("oh no")
//   }
//    guard let img =  wrapImageWithWhiteBorder(image: ciImage, borderWidth: 50.0) else {
//        fatalError("oh no")
//    }
//    applySobelEdgeDetection(ciImage: img)
    
}
catch let error {
    print(error.localizedDescription)
}

func getEmbeddedImage(url: URL, pageIndex: Int) -> [String] {
    guard let document = CGPDFDocument(url as CFURL) else {
        print("Couldn't open PDF.")
        return []
    }
    
    let t = document.outline
    
    // `page(at:)` uses pages numbered starting at 1.
    let page = pageIndex + 1
    guard let pdfPage = document.page(at: page), let dictionary = pdfPage.dictionary else {
        print("Couldn't open page.")
        return []
    }
    
    print("Getting dictionary items...")
    CGPDFDictionaryApplyFunction(dictionary, { (key, object, info) -> Void in
        print(String(cString: key), object, info)
    }, nil)
    
    var res: CGPDFDictionaryRef?
    guard CGPDFDictionaryGetDictionary(dictionary, "Resources", &res), let resources = res else {
        print("Couldn't get Resources.")
        return []
    }
    
    print("Getting resources...")
    CGPDFDictionaryApplyFunction(resources, { (key, object, info) -> Void in
        print(String(cString: key), object, info)
    }, nil)
    
    var xObj: CGPDFDictionaryRef?
    guard CGPDFDictionaryGetDictionary(resources, "XObject", &xObj), let xObject = xObj else {
        print("Couldn't load page XObject.")
        return []
    }
    
    print("Getting xObject...")
    CGPDFDictionaryApplyFunction(xObject, { (key, object, info) -> Void in
        print(String(cString: key), object, info)
    }, nil)
    
    var imageKeys = [String]()
    CGPDFDictionaryApplyBlock(xObject, { key, object, _ in
        var stream: CGPDFStreamRef?
        guard CGPDFObjectGetValue(object, .stream, &stream),
            let objectStream = stream,
            let streamDictionary = CGPDFStreamGetDictionary(objectStream) else { return true }
        var subtype: UnsafePointer<Int8>?
        guard CGPDFDictionaryGetName(streamDictionary, "Subtype", &subtype), let subtypeName = subtype else { return true }
        
        if String(cString: subtypeName) == "Image" {
            imageKeys.append(String(cString: key))
        }
        return true
    }, nil)

//    let allPageImages = imageKeys.compactMap { imageKey -> UIImage? in
//        var stream: CGPDFStreamRef?
//        guard CGPDFDictionaryGetStream(xObject, imageKey, &stream), let imageStream = stream else {
//            print("Couldn't get image stream.")
//            return nil
//        }
//        var format: CGPDFDataFormat = .raw
//        guard let data = CGPDFStreamCopyData(imageStream, &format) else {
//            print("Couldn't convert image stream to data.")
//            return nil
//        }
//        guard let image = UIImage(data: data as Data) else {
//            print("Couldn't convert image data to image.")
//            return nil
//        }
//        return image
//    }
    return []
}
