//
//  Model.swift
//  WebTesting
//
//  Created by Dev1 on 05/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import Foundation
import CommonCrypto

let publicKey = "ae4ff7f58cd44114fe2049f565e9c60c"
let privateKey = "644b11844d29e62f98227d861c457ac0b7fd66be"

let baseURL = URL(string: "https://gateway.marvel.com/v1/public")!

var datos:MarvelRoot?

struct MarvelRoot:Codable {
   let code:Int
   let etag:String
   struct MarvelData:Codable {
      let offset:Int
      let limit:Int
      let total:Int
      let count:Int
   }
   let data:MarvelData
   struct MarvelResults:Codable {
      let id:Int
      let title:String
      let issueNumber:Int
      let description:String
      let format:String
      let resourceURI:URL
      struct ComicDate:Codable {
         let type:String
         let date:Date
      }
      let dates:[ComicDate]
      struct ComicPrice:Codable {
         let type:String
         let price:Double
      }
      let prices:[ComicPrice]
      struct Thumbnail:Codable {
         enum CodingKeys:String,CodingKey {
            case path
            case imageExtension = "extension"
         }
         let path:URL
         let imageExtension:String
      }
      let thumbnail:Thumbnail
   }
}

func conexionMarvel() {
   let ts = "\(Date().timeIntervalSince1970)"
   let valorFirma = ts+privateKey+publicKey
   let hash = valorFirma.MD5
   var url = URLComponents()
   url.scheme = baseURL.scheme
   url.host = baseURL.host
   url.path = baseURL.path
   let queryts = URLQueryItem(name: "ts", value: ts)
   let queryApiKey = URLQueryItem(name: "apikey", value: publicKey)
   let queryHash = URLQueryItem(name: "hash", value: hash)
   url.queryItems = [queryts, queryApiKey, queryHash]
   let urlFinal = url.url!.appendingPathComponent("comics")
   
   let session = URLSession.shared
   var request = URLRequest(url: urlFinal)
   request.httpMethod = "GET"
   request.addValue("*/*", forHTTPHeaderField: "Accept")
   session.dataTask(with: request) { data, response, error in
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print("ERROR : \(error)")
         }
         return
      }
      if response.statusCode == 200 {
         let decoder = JSONDecoder()
         decoder.dateDecodingStrategy = .formatted(DateFormatter.marvelDate)
         do {
            datos = try decoder.decode(MarvelRoot.self, from: data)
            print(datos ?? "No hay nada")
         } catch {
            print("Error en la serialización \(error)")
         }
      }
   }.resume()
}

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
