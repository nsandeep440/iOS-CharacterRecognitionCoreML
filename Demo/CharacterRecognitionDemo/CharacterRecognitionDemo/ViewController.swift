//
//  ViewController.swift
//  CharacterRecognitionDemo
//
//  Created by Sandeep N on 05/05/19.
//  Copyright © 2019 fishTheData. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var labelOriginal: UILabel!
    @IBOutlet weak var labelPrediction: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var classifier: CharacterRecognition!
    
    @IBAction func buttonNext(_ sender: UIButton) {
        currentIndex = currentIndex + 1
        if currentIndex >= images.count {
            currentIndex = 0
        }
        self.updateImage(atIndex: currentIndex)
    }
    
    @IBAction func buttonPrevious(_ sender: UIButton) {
        currentIndex = currentIndex - 1
        if currentIndex < 0 {
            currentIndex = images.count - 1
        }
        self.updateImage(atIndex: currentIndex)
    }
    
    var currentIndex = 0
    
    let images: [UIImage] = [#imageLiteral(resourceName: "2.jpeg"), #imageLiteral(resourceName: "4.jpg"), #imageLiteral(resourceName: "6.jpg"), #imageLiteral(resourceName: "8.jpeg"), #imageLiteral(resourceName: "9.jpeg"), #imageLiteral(resourceName: "p1.jpeg"), #imageLiteral(resourceName: "z.jpeg")]
    let targetLabels = ["2", "4", "6", "8", "9", "p1", "Z"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.updateImage(atIndex: currentIndex)
    }

    func updateImage(atIndex index: Int) {
        let image = self.images[index]
        let target = self.targetLabels[index]
        self.imageView.image = image
        self.labelOriginal.text = "Original Character value: \(target)"
        self.makePrediction()
    }
    
    func makePrediction() {
        guard let cvPixelBuffer: CVPixelBuffer = self.images[currentIndex].resize(to: CGSize(width: 28, height: 28)).pixelBuffer() else { return }
        let charRecogInput = CharacterRecognitionInput(data: cvPixelBuffer)
        guard let prediction = try? CharacterRecognition().prediction(input: charRecogInput) else { return }
        
        print(prediction)
        self.labelPrediction.text = "Predicted Classificatoin value: \(prediction.classLabel)."
        print("----")
        print(prediction.featureNames)
        print("+++++")
        print(prediction.Handwritten_Value_is)

    }
}

extension UIImage {
    public func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
