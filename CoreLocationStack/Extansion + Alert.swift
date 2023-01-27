//
//  MainAlertController.swift
//  CoreLocationStack
//
//  Created by Александр Коробицын on 25.01.2023.
//

import UIKit

//MARK: - instanceAlertController

extension MainViewController {
    
    func presentAddAlert(title: String, completion: @escaping(String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField() { text in
            text.placeholder = "enter address"
        }
        
        let firstAction = UIAlertAction(title: "Ok", style: .default) { action in
            guard let text = alert.textFields?.first?.text else {return}
            completion(text)
        }
        let secondAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        
        present(alert, animated: true)
    }
    
    func presentErrorAlert(title: String) {
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}
