//
//  ComicViewCell.swift
//  WebTesting
//
//  Created by Dev1 on 05/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import UIKit

class ComicViewCell: UITableViewCell {

   @IBOutlet weak var portada: UIImageView!
   @IBOutlet weak var titulo: UILabel!
   @IBOutlet weak var descripcion: UILabel!
   
   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
   override func prepareForReuse() {
      portada.image = nil
      titulo.text = nil
      descripcion.text = nil
   }
}
