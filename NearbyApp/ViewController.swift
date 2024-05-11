//
//  ViewController.swift
//  NearbyApp
//
//  Created by Debartha Chakraborty on 11/05/24.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    static func make(with viewModel: NearbyPlacesViewModel) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "ViewController") as! ViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: NearbyPlacesViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        addObservers()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func addObservers() {
        viewModel.places
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.isFetching
            .sink { [weak self] value in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.places.value.count + (viewModel.isFetching.value ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == viewModel.places.value.count {
            cell.textLabel?.text = "Loading"
        } else {
            cell.textLabel?.text = viewModel.places.value[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !viewModel.isFetching.value, indexPath.row == viewModel.places.value.count - 1 {
            viewModel.fetchMorePlaces()
        }
    }
}

