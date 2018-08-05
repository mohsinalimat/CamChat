//
//  Screen_ButtonResponses.swift
//  CamChat
//
//  Created by Patrick Hanna on 8/4/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import HelpKit

extension Screen{
    
    func respondToSearchButtonTapped(){
        topBar_typed.topSearchBar.layoutIfNeeded()
        let searchBarHeight = topBar_typed.topSearchBar.frame.height
        present(CCSearchController(searchBarHeight: searchBarHeight), animated: true)
    }
}
