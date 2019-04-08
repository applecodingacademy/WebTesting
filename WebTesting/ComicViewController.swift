//
//  ComicViewController.swift
//  WebTesting
//
//  Created by Dev1 on 05/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import UIKit
import CoreData

class ComicViewController: UITableViewController {
   
   var predicate:NSPredicate?
   var sortedResult:[NSSortDescriptor] = []
   
   lazy var comicResult:NSFetchedResultsController<Comics> = {
      let fetchComic:NSFetchRequest<Comics> = Comics.fetchRequest()
      var orden = [NSSortDescriptor(key: #keyPath(Comics.id), ascending: true)]
      orden.append(contentsOf: sortedResult)
      fetchComic.sortDescriptors = orden
      fetchComic.predicate = predicate
      return NSFetchedResultsController(fetchRequest: fetchComic, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      conexionMarvel()
      
      self.clearsSelectionOnViewWillAppear = false
      self.navigationItem.rightBarButtonItem = self.editButtonItem
      
      let blurEffect = UIBlurEffect(style: .dark)
      let blurredEffectView = UIVisualEffectView(effect: blurEffect)
      blurredEffectView.frame = navigationController?.view.frame ?? CGRect.zero
      blurredEffectView.tag = 200
      navigationController?.view.addSubview(blurredEffectView)
      
      let activity = UIActivityIndicatorView(style: .whiteLarge)
      activity.frame = navigationController?.view.frame ?? CGRect.zero
      activity.tag = 201
      activity.startAnimating()
      navigationController?.view.addSubview(activity)
      
      NotificationCenter.default.addObserver(forName: NSNotification.Name("OKCARGA"), object: nil, queue: OperationQueue.main) { [weak self] _ in
         self?.reloadTableData()
         guard let blur = self?.navigationController?.view.viewWithTag(200) as? UIVisualEffectView, let activity = self?.navigationController?.view.viewWithTag(201) as? UIActivityIndicatorView else {
            return
         }
         blur.removeFromSuperview()
         activity.stopAnimating()
         activity.removeFromSuperview()
      }
   }
   
   func reloadTableData() {
      do {
         try comicResult.performFetch()
      } catch {
         print("Error en la consulta")
      }
      tableView.reloadData()
   }
   
   // MARK: - Table view data source
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      return comicResult.sections?.count ?? 0
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return comicResult.sections?[section].numberOfObjects ?? 0
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "zelda", for: indexPath) as! ComicViewCell
      
      let datosComic = comicResult.object(at: indexPath)
      cell.titulo.text = datosComic.title
      cell.descripcion.text = datosComic.comicDesc ?? "No hay descripción"
      if let imagen = datosComic.thumbnailIMG {
         cell.portada.image = UIImage(data: imagen)
      } else {
         if let imagenURL = datosComic.thumbnailURL {
            recuperarImagen(url: imagenURL) { imagen in
               if let resize = imagen.resizeImage(newWidth: cell.portada.frame.size.width) {
                  if tableView.visibleCells.contains(cell) {
                     cell.portada.image = resize
                  }
                  datosComic.thumbnailIMG = resize.pngData()
                  saveContext()
               }
            }
         }
      }
      return cell
   }
   
   
   /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
   
   /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
    // Delete the row from the data source
    tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
   
   /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    
    }
    */
   
   /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
   
   /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    }
    */
   
   deinit {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name("OKCARGA"), object: nil)
   }
   
}
