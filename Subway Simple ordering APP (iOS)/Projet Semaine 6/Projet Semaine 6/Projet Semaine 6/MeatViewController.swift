//
//  MeatViewController.swift
//  Projet Semaine 6
//
//  Created by user933722 on 2/14/24.
//

import UIKit

class MeatViewController: UIViewController {
    
    var selectedBread: String?
    var selectedMeat: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func meatButtonTapped(_ sender: UIButton) {
        if let selectedMeat = sender.titleLabel?.text{
            performSegue(withIdentifier: "ShowConfirmation", sender: selectedMeat)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowConfirmation"{
            if let selectedMeat = sender as? String{
                if let destinationVC = segue.destination as? ConfirmationViewController{
                    destinationVC.selectedBread = selectedBread
                    destinationVC.selectedMeat = selectedMeat
                }
            }
        }
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
