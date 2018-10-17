//
//  NameChangerVC.swift
//  CamChat
//
//  Created by Patrick Hanna on 10/15/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit


class NameChangerVC: SettingsNavigationVC{

    private lazy var _viewController = _NameChangerVC(style: .grouped)
    override var rootViewController: UIViewController{return _viewController}
    
}

private class _NameChangerVC: SettingsScreenVC{
    
    
    private let firstNameCell = NameChangerCell(type: .first)
    private let lastNameCell = NameChangerCell(type: .last)
    
    private var cells: [[NameChangerCell]]{
        return [[firstNameCell], [lastNameCell]]
    }
    
    private var headers = [NameChangerHeader(type: .first), NameChangerHeader(type: .last)]
    
    override var screenTitle: String { return "Edit Name" }
    
    private var saveButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        firstNameCell.textfield.becomeFirstResponder()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = 15
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(respondToCancelButtonTapped))
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(respondToSaveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        firstNameCell.textfield.text = DataCoordinator.currentUser!.firstName
        lastNameCell.textfield.text = DataCoordinator.currentUser!.lastName
        saveButton.isEnabled = false
        
        
        addTextDidChangeListenersToCells()
    
    }
    
    private func addTextDidChangeListenersToCells(){
        
        for cell in cells.flatMap({[$0.first!]}){
            cell.textfield.addTextDidChangeListener {[weak self] (text) in
                guard let self = self else {return}
                
                if ((self.firstNameCell.textfield.hasValidText && self.lastNameCell.textfield.hasValidText).isFalse)
                    
                    ||
                    
                    (self.firstNameCell.textfield.text?.withTrimmedWhiteSpaces() == DataCoordinator.currentUser?.firstName && self.lastNameCell.textfield.text?.withTrimmedWhiteSpaces() == DataCoordinator.currentUser?.lastName)
                    
                {
                    self.saveButton.isEnabled = false
                } else {
                    self.saveButton.isEnabled = true
                }
            }
        }
    }
    
    @objc private func respondToCancelButtonTapped(){
        dismissKeyboards()
        self.dismiss()
        
    }
    
    @objc private func respondToSaveButtonTapped(){
        guard let text1 = firstNameCell.textfield.text, let text2 = lastNameCell.textfield.text else {return}
        if text1.withTrimmedWhiteSpaces().count > 20 || text2.withTrimmedWhiteSpaces().count > 20{
            presentOopsAlert(description: "Names must not be longer than 20 characters")
            return
        }
        dismissKeyboards()
        self.dismiss()
        DataCoordinator.changeCurrentUsersNameTo(firstName: firstNameCell.textfield.text!, lastName: lastNameCell.textfield.text!.withTrimmedWhiteSpaces())
    }
    
    private func dismissKeyboards(){
        [firstNameCell, lastNameCell].forEach{
            $0.textfield.resignFirstResponder()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headers[section]
    }
    
    
}






private enum NameType{case first, last}

private class NameChangerCell: UITableViewCell{
    
    
    
    init(type: NameType){
        
        super.init(style: .default, reuseIdentifier: "You have to live like no one else, to live like no one else.")
        selectionStyle = .none
        let text = type == .first ? "first name" : "last name"
        textfield.placeholder = "Type \(text) here..."
        
        
        
        textfield.pin(addTo: self, anchors: [.left: leftAnchor, .top: topAnchor, .bottom: bottomAnchor, .right: rightAnchor], constants: [.left: 15, .right: 10])
    }
    
    
    private(set) lazy var textfield: UITextField = {
        let x = UITextField()
        x.font = CCFonts.getFont(type: .medium, size: 16)
        x.clearButtonMode = .always
        x.tintColor = BLUECOLOR
        return x
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}





private class NameChangerHeader: UITableViewHeaderFooterView{
    
    init(type: NameType){
        super.init(reuseIdentifier: "blah blah blah")
        
        mainLabel.text = type == .first ? "First Name" : "Last Name"
        mainLabel.pin(addTo: self, anchors: [.left: leftAnchor, .centerY: centerYAnchor], constants: [.left: 15])
        
        
    }
    
    private lazy var mainLabel: UILabel = {
        let x = UILabel(font: CCFonts.getFont(type: .medium, size: 17), textColor: BLUECOLOR)
        return x
    }()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not being implemented")
    }
}
