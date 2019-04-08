//
//  Network.swift
//  PrimeraAppSeria
//
//  Created by Dev1 on 26/03/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import UIKit

func recuperarImagen(url:URL, callback:@escaping (UIImage) -> ()) {
   recuperarDatos(url: url) { datos in
      if let imagen = UIImage(data: datos) {
         callback(imagen)
      } else {
         print("ERROR: Los datos no corresponden a una imagen")
      }
   }
}

func recuperarDatos(url:URL, callback:@escaping (Data) -> ()) {
   let session = URLSession.shared
   let tarea = session.dataTask(with: url) {
      (data:Data?, response:URLResponse?, error:Error?) in
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print("Error de red: \(error)")
         }
         return
      }
      if response.statusCode == 200 {
         DispatchQueue.main.async {
            callback(data)
         }
      } else {
         print("Error de código \(response.statusCode)")
      }
   }
   tarea.resume()
}
