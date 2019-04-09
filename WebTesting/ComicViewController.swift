//
//  ComicViewController.swift
//  WebTesting
//
//  Created by Dev1 on 05/04/2019.
//  Copyright © 2019 Dev1. All rights reserved.
//

import UIKit
import CoreData

enum Ordenacion {
   case ascendente, descendente, ninguno
}

class ComicViewController: UITableViewController, UISearchResultsUpdating {

   var predicate:NSPredicate?
   var sorted:NSSortDescriptor?
   
   lazy var comicResult:NSFetchedResultsController<Comics> = {
      let fetchComic:NSFetchRequest<Comics> = Comics.fetchRequest()
      fetchComic.sortDescriptors = [NSSortDescriptor(key: #keyPath(Comics.id), ascending: true)]
      return NSFetchedResultsController(fetchRequest: fetchComic, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
   }()
   
   let searchController = UISearchController(searchResultsController: nil)
   
   override func viewDidLoad() {
      super.viewDidLoad()
      conexionMarvel()
      
      self.clearsSelectionOnViewWillAppear = false
      self.navigationItem.leftBarButtonItem = self.editButtonItem
      
      searchController.obscuresBackgroundDuringPresentation = false
      searchController.searchBar.placeholder = "Introduzca parte del título para filtrar"
      navigationItem.searchController = searchController
      searchController.searchResultsUpdater = self
      definesPresentationContext = true
      
      let blurEffect = UIBlurEffect(style: .dark)
      let blurredEffectView = UIVisualEffectView(effect: blurEffect)
      blurredEffectView.frame = navigationController?.view.frame ?? CGRect.zero
      blurredEffectView.tag = 200
      tabBarController?.view.addSubview(blurredEffectView)
      
      let activity = UIActivityIndicatorView(style: .whiteLarge)
      activity.frame = navigationController?.view.frame ?? CGRect.zero
      activity.tag = 201
      activity.startAnimating()
      tabBarController?.view.addSubview(activity)
      
      NotificationCenter.default.addObserver(forName: NSNotification.Name("OKCARGA"), object: nil, queue: OperationQueue.main) { [weak self] _ in
         self?.reloadTableData()
         guard let blur = self?.tabBarController?.view.viewWithTag(200) as? UIVisualEffectView, let activity = self?.tabBarController?.view.viewWithTag(201) as? UIActivityIndicatorView else {
            return
         }
         blur.removeFromSuperview()
         activity.stopAnimating()
         activity.removeFromSuperview()
      }
   }
   
   func newFetchedRC() {
      if let nuevoOrden = sorted {
         comicResult.fetchRequest.sortDescriptors =  [nuevoOrden]
      } else {
         comicResult.fetchRequest.sortDescriptors =  [NSSortDescriptor(key: #keyPath(Comics.id), ascending: true)]
      }
      comicResult.fetchRequest.predicate = predicate
   }
   
   func reloadTableData() {
      DispatchQueue.main.async { [weak self] in
         do {
            try self?.comicResult.performFetch()
         } catch {
            print("Error en la consulta")
         }
         self?.tableView.reloadData()
      }
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
      cell.descripcion.text = datosComic.comicDesc?.htmlString ?? "No hay descripción"
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
   
   @IBAction func ordenar(_ sender: UIBarButtonItem) {
      let alert = UIAlertController(title: "Ordenar", message: "Elija el orden de los datos", preferredStyle: .actionSheet)
      let accion1 = UIAlertAction(title: "Ascendente", style: .default) { [weak self] _ in
         self?.realizarOrden(tipo: .ascendente)
      }
      let accion2 = UIAlertAction(title: "Descendente", style: .default) { [weak self] _ in
         self?.realizarOrden(tipo: .descendente)
      }
      let accion3 = UIAlertAction(title: "Ninguno", style: .default) { [weak self] _ in
         self?.realizarOrden(tipo: .ninguno)
      }
      alert.addAction(accion1)
      alert.addAction(accion2)
      alert.addAction(accion3)
      present(alert, animated: true, completion: nil)
   }
   
   func realizarOrden(tipo:Ordenacion) {
      switch tipo {
      case .ascendente:
         sorted = NSSortDescriptor(key: #keyPath(Comics.title), ascending: true)
      case .descendente:
         sorted = NSSortDescriptor(key: #keyPath(Comics.title), ascending: false)
      case .ninguno:
         sorted = nil
      }
      newFetchedRC()
      reloadTableData()
   }
   
   func updateSearchResults(for searchController: UISearchController) {
      guard let texto = searchController.searchBar.text else {
         return
      }
      if texto.isEmpty {
         comicResult.fetchRequest.predicate = nil
      } else {
         comicResult.fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@", texto)
      }
      reloadTableData()
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
