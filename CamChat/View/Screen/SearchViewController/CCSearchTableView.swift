//
//  CCSearchTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit



class CCSearchTableView: UITableView, UITableViewDelegate, SearchControllerVMDelegate{
    
    
    
    
    
    
    private weak var vcOwner: UIViewController!
    init(owner: UIViewController){
        self.vcOwner = owner
        super.init(frame: CGRect.zero, style: .plain)
        self.viewModel = SearchControllerVM(tableView: self, delegate: self)
        tableFooterView = UIView()
        
        delegate = self
        separatorStyle = .none
        backgroundColor = .clear
        separatorInset.left = 0
        rowHeight = 70
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false

    }
    
    private var viewModel: SearchControllerVM<CCSearchTableView>!
    
   typealias CellType = CCSearchTableViewCell
    
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let title = tableView.dataSource?.tableView?(self, titleForHeaderInSection: section){
            return CCSearchTableViewHeader(text: title)
        } else {return nil}
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectRow(at: indexPath, animated: true)
        let object = viewModel.objects[indexPath.row]
        
        if let user = User.getObjectWith(uniqueID: object.uniqueID){
            self.vcOwner.present(ChatViewController(presenter: vcOwner, user: user))
        } else {
            viewModel.objects[indexPath.row].persist(){ (callback) in
                
                switch callback{
                case .success(let user):
                    self.vcOwner.present(ChatViewController(presenter: self.vcOwner, user: user), animated: true, completion: nil)
                case .failure(let error): print(error)
                }
            }
        }
    }
    
    
    func configureCell(_ cell: CCSearchTableView.CellType, for indexPath: IndexPath, with object: TempUser) {
        
        configureTopLine_And_Corners(for: cell, indexPath: indexPath)
        cell.setWithUser(user: object)
        
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
        isUserInteractionEnabled = false
        
        
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        labelBacking.layer.cornerRadius = labelBacking.frame.height / 2
    }
    
    private lazy var labelBacking: UIView = {
        let x = UIView()
        x.layer.masksToBounds = true
        let val: CGFloat = 65
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




