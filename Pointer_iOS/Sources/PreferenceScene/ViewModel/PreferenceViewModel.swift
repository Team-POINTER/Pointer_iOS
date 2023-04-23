//
//  PreferenceViewModel.swift
//  Pointer_iOS
//
//  Created by 김지수 on 2023/04/23.
//

import Foundation

class PreferenceViewModel {
    
    func indexPathToType(_ indexPath: IndexPath) -> PreferenceModel {
        let section = PreferenceModel.SectionType.allCases[indexPath.section]
        let typeModels = PreferenceModel.allCases.filter { $0.type == section }
        let type = typeModels[indexPath.row]
        return type
    }
}
