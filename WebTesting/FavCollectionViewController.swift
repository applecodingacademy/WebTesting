//
//  FavCollectionViewController.swift
//  WebTesting
//
//  Created by Dev1 on 09/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import UIKit
import CoreData

class FavCollectionViewController: UICollectionViewController, UITabBarControllerDelegate {
   
   lazy var comicResult:NSFetchedResultsController<Comics> = {
      let fetchComic:NSFetchRequest<Comics> = Comics.fetchRequest()
      fetchComic.sortDescriptors = [NSSortDescriptor(key: #keyPath(Comics.id), ascending: true)]
      fetchComic.predicate = NSPredicate(format: "favorito = %@", NSNumber(value: true))
      return NSFetchedResultsController(fetchRequest: fetchComic, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      reloadTableData()
      tabBarController?.delegate = self
   }
   
   func reloadTableData() {
      DispatchQueue.main.async { [weak self] in
         do {
            try self?.comicResult.performFetch()
         } catch {
            print("Error en la consulta")
         }
         self?.collectionView.reloadData()
      }
   }
   
   // MARK: UICollectionViewDataSource
   
   override func numberOfSections(in collectionView: UICollectionView) -> Int {
      return comicResult.sections?.count ?? 0
   }
   
   
   override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return comicResult.sections?[section].numberOfObjects ?? 0
   }
   
   override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "zelda", for: indexPath) as! FavCollectionViewCell
      let dato = comicResult.object(at: indexPath)
      cell.titulo.text = dato.title
      if let imagen = dato.thumbnailIMG {
         cell.portada.image = UIImage(data: imagen)
      }
      return cell
   }
   
   func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//      if tabBarController.selectedIndex == 1 {
//      }
//      if let titulo = navigationController?.tabBarItem.title, titulo == "Favorites" {
//
//      }
      if let controller = viewController as? UINavigationController, controller.topViewController is FavCollectionViewController {
         reloadTableData()
      }
   }
   
   // MARK: UICollectionViewDelegate
   
   /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    return true
    }
    */
   
   /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return true
    }
    */
   
   /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
   
}
