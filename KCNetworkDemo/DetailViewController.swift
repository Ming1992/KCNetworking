//
//  DetailViewController.swift
//  KCNetworkDemo
//
//  Created by liaozhenming on 2019/7/4.
//  Copyright © 2019 ©2018 STAIONING BLOCK CHAIN Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var btn_item: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        weak var weakSelf = self
        KCNetworking<KCTestUser>().sendRequest("https://api.m.900sui.com/api/u/Login", parameters: ["username":"18616733727","password":"123456"], responseItemBlock: { (eMsg, user) in
            print(user.nick)
        }, responseItemsBlock: nil)
    }
    
    deinit {
        print("DetailViewController..deinit")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func action_start(){
 
    }
}
