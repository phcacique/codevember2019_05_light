//
//  Image+Pixel.swift
//  Light
//
//  Created by Pedro Cacique on 05/11/19.
//  Copyright © 2019 Pedro Cacique. All rights reserved.
//

import Foundation
import UIKit

public struct Pixel {
    public var value: UInt32
    public var red: UInt8 {
        get { return UInt8(value & 0xFF) }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    public var green: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    public var blue: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    public var alpha: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }
}

public class RGBA{

    public var pixels:UnsafeMutableBufferPointer<Pixel>
    public var width:Int
    public var height:Int
    
    public init(_ image:UIImage){
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bitsPerComponent = 8
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: (width * height))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        let CGPointZero = CGPoint(x: 0, y: 0)
        let rect = CGRect(origin: CGPointZero, size: (image.size))
        
        imageContext?.draw(image.cgImage!, in: rect)
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)

    }

    func toUIImage() -> UIImage? {
        let bitsPerComponent = 8 // 1

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB() // 2

        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)!
        guard let cgImage = imageContext.makeImage() else {return nil} // 3

        let image = UIImage(cgImage: cgImage)
        return image
    }
}
