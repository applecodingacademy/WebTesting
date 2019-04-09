//
//  Model.swift
//  WebTesting
//
//  Created by Dev1 on 05/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import Foundation
import CoreData

let publicKey = "ae4ff7f58cd44114fe2049f565e9c60c"
let privateKey = "644b11844d29e62f98227d861c457ac0b7fd66be"

let baseURL = URL(string: "https://gateway.marvel.com/v1/public")!

var persistentContainer:NSPersistentContainer = {
   let container = NSPersistentContainer(name: "ComicModel")
   container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
         fatalError("Error al abrir la base de datos")
      }
   }
   return container
}()

var ctx:NSManagedObjectContext {
   return persistentContainer.viewContext
}

var datos:MarvelRoot?

enum ComicFormat:String, Codable {
   case Comic, Magazine, Hardcover, Digest
   case tradepaperback = "Trade Paperback"
   case graphicnovel = "Graphic Novel"
   case digitalcomic = "Digital Comic"
   case infinitecomic = "Infinite Comic"
}

struct MarvelRoot:Codable {
   let code:Int
   let etag:String
   struct MarvelData:Codable {
      let offset:Int
      let limit:Int
      let total:Int
      let count:Int
      struct MarvelResults:Codable {
         let id:Int
         let title:String
         let issueNumber:Int
         let description:String?
         let format:ComicFormat
         let resourceURI:URL
         struct ComicDate:Codable {
            let type:String
            let date:String
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
            var fullPath:URL? {
               var pathComponents = URLComponents(url: path, resolvingAgainstBaseURL: false)
               pathComponents?.scheme = "https"
               return pathComponents?.url?.appendingPathExtension(imageExtension)
            }
         }
         let thumbnail:Thumbnail
      }
      let results:[MarvelResults]
   }
   let data:MarvelData
}

func saveContext() {
   DispatchQueue.main.async {
      if ctx.hasChanges {
         do {
            try ctx.save()
         } catch {
            print("Error en la grabación")
         }
      }
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
   let limit = URLQueryItem(name: "limit", value: "100")
   let format = URLQueryItem(name: "format", value: "hardcover")
   let order = URLQueryItem(name: "orderBy", value: "onsaleDate")
   url.queryItems = [limit, format, order, queryts, queryApiKey, queryHash]
   let urlFinal = url.url!.appendingPathComponent("comics")
   
   let session = URLSession.shared
   var request = URLRequest(url: urlFinal)
   request.httpMethod = "GET"
   request.addValue("*/*", forHTTPHeaderField: "Accept")
   if let etag = loadKeychain(key: "etag"), let ETag = String(data: etag, encoding: .utf8) {
      request.addValue(ETag, forHTTPHeaderField: "ETag")
   }
   session.dataTask(with: request) { data, response, error in
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print("ERROR : \(error)")
         }
         return
      }
      if response.statusCode == 200 {
         let decoder = JSONDecoder()
         do {
            let cargaDatos = try decoder.decode(MarvelRoot.self, from: data)
            cargaDatos.data.results.forEach { dato in
               if !comicExists(id: dato.id) {
                  let newComic = Comics(context: ctx)
                  newComic.id = Int64(dato.id)
                  newComic.title = dato.title
                  newComic.issueNumber = Int16(dato.issueNumber)
                  newComic.comicDesc = dato.description
                  newComic.resourceURI = dato.resourceURI
                  newComic.thumbnailURL = dato.thumbnail.fullPath
                  let newFecha = dato.dates.filter { $0.type == "onsaleDate" }
                  if newFecha.count > 0, let fecha = newFecha.first?.date {
                     newComic.onSaleDate = DateFormatter.marvelDate.date(from: fecha)
                  }
                  let newPrice = dato.prices.filter { $0.type == "printPrice" }
                  if newPrice.count > 0 {
                     newComic.price = newPrice.first?.price ?? 0.0
                  }
                  let formatQuery:NSFetchRequest<Formats> = Formats.fetchRequest()
                  formatQuery.predicate = NSPredicate(format: "format = %@", dato.format.rawValue)
                  do {
                     let formato = try ctx.fetch(formatQuery)
                     if let valorFormato = formato.first {
                        newComic.format = valorFormato
                     } else {
                        let newFormat = Formats(context: ctx)
                        newFormat.format = dato.format.rawValue
                        newComic.format = newFormat
                     }
                  } catch {
                     print("Error al recuperar el formato")
                  }
               }
            }
            if let etagData = cargaDatos.etag.data(using: .utf8) {
               saveKeychain(key: "etag", data: etagData)
            }
         } catch {
            print("Error en la serialización \(error)")
         }
         saveContext()
         NotificationCenter.default.post(name: NSNotification.Name("OKCARGA"), object: nil)
      }
   }.resume()
}

func comicExists(id:Int) -> Bool {
   let consulta:NSFetchRequest<Comics> = Comics.fetchRequest()
   consulta.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
   return ((try? ctx.count(for: consulta)) ?? 0) > 0 ? true : false
}
