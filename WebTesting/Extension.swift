//
//  Extension.swift
//  WebTesting
//
//  Created by Dev1 on 08/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import UIKit
import CommonCrypto

extension String {
   var MD5:String? {
      guard let messageData = data(using: .utf8) else {
         return nil
      }
      var dataMD5 = Data(count: Int(CC_MD5_DIGEST_LENGTH))
      _ = dataMD5.withUnsafeMutableBytes { bytes in
         messageData.withUnsafeBytes { messageBytes in
            CC_MD5(messageBytes.baseAddress, CC_LONG(messageData.count), bytes.bindMemory(to: UInt8.self).baseAddress)
         }
      }
      var MD5String = String()
      for c in dataMD5 {
         MD5String += String(format: "%02x", c)
      }
      return MD5String
   }
   
   var htmlString:String? {
      guard let dataString = data(using: .utf8) else {
         return nil
      }
      do {
         let atributos = try NSAttributedString(data: dataString, options: [.documentType:NSAttributedString.DocumentType.html,
             .characterEncoding: String.Encoding.utf8.rawValue]
            , documentAttributes: nil)
         return atributos.string
      } catch {
         return nil
      }
   }
}

extension DateFormatter {
   static let marvelDate:DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      return formatter
   }()
}

extension UIImage {
   func resizeImage(newWidth:CGFloat) -> UIImage? {
      let scale = newWidth / self.size.width
      let newHeight = self.size.height * scale
      let newSize = CGSize(width: newWidth, height: newHeight)
      UIGraphicsBeginImageContext(newSize)
      self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return newImage
   }
}
