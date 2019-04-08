//
//  Extension.swift
//  WebTesting
//
//  Created by Dev1 on 08/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import Foundation
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
