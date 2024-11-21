//
//  BreadViewController.swift
//  Projet Semaine 6
//
//  Created by user933722 on 2/14/24.
//

import UIKit

class BreadViewController: UIViewController {
    
    var selectedBread: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func breadButtonTapped(_ sender: UIButton) {
        if let selectedBread = sender.titleLabel?.text{
            performSegue(withIdentifier: "ShowMeatSelection", sender: selectedBread)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMeatSelection"{
            if let selectedBread = sender as? String{
                if let destinationVC = segue.destination as? MeatViewController{
                    destinationVC.selectedBread = selectedBread
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
