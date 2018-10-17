//
//  MemorySenderTableView.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/6/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit





class MemorySenderTableView: UITableView {
    
    private var viewModel: MemorySenderVM!
    private let headerID = "HeaderID"
    
    
    private var allCells = Set<MemorySenderUserCell>()
    init() {
        super.init(frame: CGRect.zero, style: .plain)
        separatorStyle = .none
        
        backgroundColor = .clear
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = MemorySenderUserCell.cellHeight
        delegate = self
        showsVerticalScrollIndicator = false
        delaysContentTouches = false
        self.viewModel = MemorySenderVM(tableView: self, delegate: self)
        register(MemorySenderTableViewHeader.self, forHeaderFooterViewReuseIdentifier: headerID)
        
        emptyTableViewLabel.pin(addTo: self, anchors: [.top: contentLayoutGuide.topAnchor, .centerX: frameLayoutGuide.centerXAnchor], constants: [.top: 50])
    }
    
    private lazy var _memorySenderMessageCell: MemorySenderMessageCell = {
        let x = MemorySenderMessageCell()
        
        return x
    }()
    
    func searchTextChanged(to newText: String?){
        viewModel.searchTextChanged(to: newText)
    }
    
    let selectedUsers = HKBox<[User]>([])
    
    private lazy var emptyTableViewLabel: UILabel = {
        let x = UILabel(text: "blah", font: CCFonts.getFont(type: .medium, size: 16), textColor: .white)
        x.pin(constants: [.width: UIScreen.main.bounds.width - 100])
        x.textAlignment = .center
        x.numberOfLines = 0
        x.alpha = 0
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}

extension MemorySenderTableView: MemorySenderVMDelegate{
    func contentDidChange() {
        let noResultsText = "No Results 😭"
        let noUsersText = "You don't have any friends to send anything to. 😱"
        if viewModel!.hasUsers{
            if viewModel!.objects.isEmpty{
                emptyTableViewLabel.alpha = 1
                emptyTableViewLabel.text = noResultsText
            } else { emptyTableViewLabel.alpha = 0}
        } else {
            emptyTableViewLabel.alpha = 1
            emptyTableViewLabel.text = noUsersText
        }
    }
    
    
    var messageCell: MemorySenderMessageCell {
        return _memorySenderMessageCell
    }
    
    
    func configure(cell: MemorySenderUserCell, using object: User, for indexPath: IndexPath) {
        allCells.insert(cell)
        cell.setWith(user: object)
        configureAppearanceFor(cell: cell, at: indexPath)
        if selectedUsers.value.contains(object){
            cell.setSelectedTo(true, animated: false)
        } else {
            cell.setSelectedTo(false, animated: false)
        }
    }
    
    
    private func configureAppearanceFor(cell: MemorySenderUserCell, at indexPath: IndexPath){
        let radius: CGFloat = 10
        cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        cell.setCornerRadius(to: 0)
        cell.setShowsBottomLine(to: true)

        if indexPath.isFirstInSection() && indexPath.isLastInSection(for: self){
            cell.setCornerRadius(to: radius)
            cell.setShowsBottomLine(to: false)
        } else if indexPath.isFirstInSection(){
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.setCornerRadius(to: radius)
            cell.setShowsBottomLine(to: true)
        } else if indexPath.isLastInSection(for: self){
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.setCornerRadius(to: radius)
            cell.setShowsBottomLine(to: false)
        }
    }
}

extension MemorySenderTableView: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.objects[indexPath.section].objects[indexPath.row]
        if selectedUsers.value.contains(user){
            selectedUsers.value.removeElementsEqual(to: user)
            for cell in allCells{
                if cell.currentUser === user{
                    cell.setSelectedTo(false, animated: true)
                }
            }
            
        } else {
            self.selectedUsers.value.append(user)
            for cell in allCells{
                if cell.currentUser === user{
                    cell.setSelectedTo(true, animated: true)
                }
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as! MemorySenderTableViewHeader
        header.setText(to: viewModel.objects[section].title)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
}




private class MemorySenderTableViewHeader: UITableViewHeaderFooterView{
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundView = UIView()
        label.pin(addTo: self, anchors: [.left: leftAnchor, .bottom: bottomAnchor], constants: [.left: 6, .bottom: 6])
    }
    
    func setText(to newText: String){
        label.text = newText.uppercased()
    }
    
    private lazy var label: UILabel = {
        let x = UILabel(text: "RECENTS", font: CCFonts.getFont(type: .demiBold, size: 12), textColor: .white)
        x.applyShadow(width: 3)
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
