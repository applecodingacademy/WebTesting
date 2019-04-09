//
//  FavCollectionViewCell.swift
//  WebTesting
//
//  Created by Dev1 on 09/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import UIKit

class FavCollectionViewCell: UICollectionViewCell {
   @IBOutlet weak var portada: UIImageView!
   @IBOutlet weak var titulo: UILabel!
   
   override func prepareForReuse() {
      portada.image = nil
      titulo.text = nil
   }
}
