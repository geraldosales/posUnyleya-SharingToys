//
//  ListTableViewController.swift
//  Sharing Toys
//
//  Created by Geraldo O Sales Jr on 05/09/21.
//

import Firebase
import UIKit

class ListTableViewController: UITableViewController {
    let collectionName = "sharingToys"
    var toys: [Toy] = []
    lazy var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()

    var listener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadToys()
    }

    func loadToys() {
        listener = firestore.collection(collectionName).order(by: "name", descending: false).addSnapshotListener(includeMetadataChanges: true, listener: { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshop = snapshot else { return }
                print("\(snapshop.documents.count)")

                if snapshop.metadata.isFromCache || snapshop.documentChanges.count > 0 {
                    self.showItensFrom(snapshop)
                }
            }
        })
    }

    func showItensFrom(_ snapshot: QuerySnapshot) {
        toys.removeAll()
        for remoteToy in snapshot.documents {
            let data = remoteToy.data()
            if let name = data["name"] as? String,
               let state = data["state"] as? Int,
               let giver = data["giver"] as? String,
               let address = data["address"] as? String,
               let phone = data["phone"] as? String {
                    let toy = Toy(name: name, state: state, giver: giver, address: address, phone: phone, id: remoteToy.documentID)
                    toys.append(toy)
            }
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toys.count
    }

    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = toys[indexPath.row].name
        cell.detailTextLabel?.text = toys[indexPath.row].getState()
        

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
}