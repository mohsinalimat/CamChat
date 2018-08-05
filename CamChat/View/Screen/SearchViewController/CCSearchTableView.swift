//
//  CCSearchTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class CCSearchTableView: UITableView, UITableViewDataSource, UITableViewDelegate{
    private let cellID = "The Best cell ever"
    private let viewController: UIViewController
    init(owner: UIViewController){
        self.viewController = owner
        super.init(frame: CGRect.zero, style: .plain)
        tableFooterView = UIView()
        dataSource = self
        delegate = self
        separatorStyle = .none
        backgroundColor = .clear
        separatorInset.left = 0
        rowHeight = 70
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(CCSearchTableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            return CCSearchTableViewHeader(text: "My Friends")
        } else if section == 0{
            return CCSearchTableViewHeader(text: "Strangers")
        }
        return nil
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectRow(at: indexPath, animated: true)
        viewController.present(ChatViewController(), animated: true, completion: nil)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 10

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CCSearchTableViewCell
        configureTopLine_And_Corners(for: cell, indexPath: indexPath)
        return cell
    }
    
    private let preferredCornerRadius: CGFloat = 10

    
    private func configureTopLine_And_Corners(for cell: CCSearchTableViewCell, indexPath: IndexPath){
        cell.layer.cornerRadius = 0
        
        
        
        if indexPath.isFirstInSection() && indexPath.isLastInSection(for: self){
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            cell.layer.cornerRadius = preferredCornerRadius
            cell.hideLine()
        } else if indexPath.isFirstInSection(){
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.cornerRadius = preferredCornerRadius
            cell.hideLine()
        } else if indexPath.isLastInSection(for: self){
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.layer.cornerRadius = preferredCornerRadius
            cell.showLine()
        } else { cell.showLine() }
    }
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}







private class CCSearchTableViewHeader: UIView{
    private let text: String
    init(text: String){
        self.text = text
        super.init(frame: CGRect.zero)
        addSubview(labelBacking)
        addSubview(label)
        label.pin(anchors: [.centerX: centerXAnchor, .centerY: centerYAnchor])
        
        let sidePadding: CGFloat = -9
        labelBacking.pinAllSides(pinTo: label, insets: UIEdgeInsets(top: -6, left: sidePadding, bottom: -4, right: sidePadding))
        
        
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        labelBacking.layer.cornerRadius = labelBacking.frame.height / 2
    }
    
    private lazy var labelBacking: UIView = {
        let x = UIView()
        x.layer.masksToBounds = true
        let val: CGFloat = 55
        x.backgroundColor = UIColor(red: val, green: val, blue: val)
        return x
    }()
    
    
    
    private lazy var label: UILabel = {
        let x = UILabel()
        x.text = text.uppercased()
        x.textColor = .white
        x.textAlignment = .center
        x.font = SCFonts.getFont(type: .medium, size: 13)
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}




