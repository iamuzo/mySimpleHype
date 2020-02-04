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
    
    // MARK: - OUTLETS
    @IBOutlet weak var hypeTableView: UITableView!
    @IBOutlet weak var composeHypeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupView()
    }
    
    // MARK: - ACTIONS
    @IBAction func composeHypeButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        HypeController.sharedGlobalInstance.fetchHypes { (success) in
            if success {
                self.updateViews()
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
            noRecordsLabel()
        } else {
            removeActivityIndicator()
        }
    }
    
    func noRecordsLabel() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = view.center
        label.textAlignment = .center
        label.text = "No Records Yet"
        self.view.addSubview(label)
    }
}

extension HypeListViewController: UITableViewDelegate {
}

extension HypeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.sharedGlobalInstance.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hypeTableView.dequeueReusableCell(
            withIdentifier: "hypeCell", for: indexPath
        )
        
        let hype = HypeController.sharedGlobalInstance.hypes[indexPath.row]
        
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.dateAsString()
        return cell
    }
    
    
}
