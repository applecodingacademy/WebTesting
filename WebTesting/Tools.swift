//
//  Tools.swift
//  WebTesting
//
//  Created by Dev1 on 08/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import Foundation

func saveUserPreferences(value:Any, key:String) {
   UserDefaults.standard.set(value, forKey: key)
}

func loadUserPreferences(value:String) -> Any? {
   return UserDefaults.standard.object(forKey: value)
}

func saveKeychain(key:String, data:Data) {
   let query = [kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrAccount as String: key,
                kSecValueData as String: data]
         as [String:Any]
   SecItemDelete(query as CFDictionary)
   let result = SecItemAdd(query as CFDictionary, nil)
   if result != noErr {
      print("Error en la grabación")
   }
}

func loadKeychain(key:String) -> Data? {
   let query = [kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrAccount as String: key,
                kSecReturnData as String: kCFBooleanTrue as Any,
                kSecMatchLimit as String: kSecMatchLimitOne]
         as [String:Any]
   var dataTypeRef:AnyObject?
   let status:OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
   if status == noErr {
      return dataTypeRef as! Data?
   } else {
      return nil
   }
}

