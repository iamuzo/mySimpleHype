//
//  HypeListViewController.swift
//  mySimpleHype
//
//  Created by Uzo on 2/3/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import UIKit

class HypeListViewController: UIViewController {

    // MARK: - PROPERTIES
    var indicator = UIActivityIndicatorView(style: .medium)
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
    // MARK: - OUTLETS
    @IBOutlet weak var hypeTableView: UITableView!
    @IBOutlet weak var composeHypeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        
    }
    
    // MARK: - ACTIONS
    @IBAction func composeHypeButtonTapped(_ sender: UIBarButtonItem) {
        presentHypeAlert(for: nil)
    }

    // MARK: - Custom Methods
    func configureTableView() {
        title = "Your Hype List"
        hypeTableView.delegate = self
        hypeTableView.dataSource = self
    }
    
    func showActivityIndicator() {
        self.hypeTableView.isHidden = true
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.tag = 100
        view.addSubview(indicator)
    }
    
    func removeActivityIndicator() {
        self.hypeTableView.isHidden = false
        indicator.stopAnimating()
    }
    
    func setupView() {
        showActivityIndicator()
        loadData()
    }
    
    func loadData() {
        HypeController.sharedGlobalInstance.fetch { (result) in
            switch result {
                case .success(_):
                    self.updateViews()
                case .failure(let error):
                    self.presentErrorToUser(localizedError: error)
            }
        }
    }

    func updateViews() {
        DispatchQueue.main.async {
            self.hypeTableView.reloadData()
            self.showMessage()
        }
    }
    
    func showMessage() {
        let hypeRecords = HypeController.sharedGlobalInstance.hypes.count
        
        if hypeRecords == 0 {
            showNoRecordsLabel()
        } else {
            removeActivityIndicator()
            removeNoRecordsLabel()
        }
    }
    
    func showNoRecordsLabel() {
        label.center = view.center
        label.textAlignment = .center
        label.text = "No Records Yet"
        self.view.addSubview(label)
    }
    
    func removeNoRecordsLabel() {
        label.isHidden = true
    }
}

extension HypeListViewController: UITableViewDelegate {
}

extension HypeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.sharedGlobalInstance.hypes.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = hypeTableView.dequeueReusableCell(
            withIdentifier: "hypeCell", for: indexPath
        )
        
        let hype = HypeController.sharedGlobalInstance.hypes[indexPath.row]
        
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.dateAsString()
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let hypeToDelete = HypeController.sharedGlobalInstance.hypes[indexPath.row]
            
            guard let index = HypeController.sharedGlobalInstance.hypes.firstIndex(of: hypeToDelete)
                else { return }
            
            HypeController.sharedGlobalInstance.delete(hypeToDelete) { (result) in
                /** result is either a Bool or an error */
                switch result {
                    case .success(let success):
                        if success {
                            HypeController.sharedGlobalInstance.hypes.remove(at: index)
                            DispatchQueue.main.async {
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    case .failure(let error):
                        print(error.errorDescription ?? error.localizedDescription)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hypeSelected = HypeController.sharedGlobalInstance.hypes[indexPath.row]
        presentHypeAlert(for: hypeSelected)
    }
    
}
