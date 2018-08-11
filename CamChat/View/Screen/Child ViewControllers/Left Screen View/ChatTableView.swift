//
//  ChatTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 7/1/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit


class ChatTableView: SCTableView{
    let cellID = "cell reuse identifier"
    
 
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        
        
        
        
    }
    
    override func registerCells() {
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellID)
    }
    
    
    
    override var topLabelText: String{
        return "Chats"
    }
    
    override var topLabelTextColor: UIColor{
        return BLUECOLOR
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      
        let vc = ChatViewController()
        vc.tappedCell = tableView.cellForRow(at: indexPath)!
        
        DispatchQueue.main.async {
            
            self.present(vc, animated: true, completion: nil)
        }
    }
}
