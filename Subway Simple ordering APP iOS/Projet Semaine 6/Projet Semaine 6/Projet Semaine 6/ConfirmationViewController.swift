//
//  ConfirmationViewController.swift
//  Projet Semaine 6
//
//  Created by user933722 on 2/14/24.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var breadLabel: UILabel!
    @IBOutlet weak var meatLabel: UILabel!
    
    var selectedBread: String?
    var selectedMeat: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        breadLabel.text = "Pain choisi: \(selectedBread ?? "N/A")"
        meatLabel.text = "Viande choisi: \(selectedMeat ?? "N/A")"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
