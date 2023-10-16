//
//  ViewController.swift
//  TeladocBeatles
//
//  Created by Konstantin Ionin on 14.10.2023.
//

import Combine
import UIKit

private enum Constants {
  static let cellIdentifier = "AlbumCell"
}

final class AlbumsViewController: UIViewController {
  
  // MARK: UI
  
  private let tableView = UITableView()
  
  // MARK: Private Properties
  
  private var tableViewDataSource: UITableViewDiffableDataSource<Int, AlbumCellConfiguration>?
  
  private let viewModel: AlbumsViewModelProtocol
  
  private let searchQueryDidChangeSubject = PassthroughSubject<String, Never>()
  
  private var disposeBag = Set<AnyCancellable>()
  
  // MARK: Init
  
  init(viewModel: AlbumsViewModelProtocol) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setHierarchy()
    setUI()
    setLayout()
    setUpSearch()
    setDataSource()
    setBindings()
  }
  
}

// MARK: - Data Source

private extension AlbumsViewController {
  
  func setDataSource() {
    tableViewDataSource = .init(tableView: tableView, cellProvider: { tableView, _, configuration in
      let cell: UITableViewCell
      if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) {
        cell = dequeuedCell
      } else {
        cell = UITableViewCell(style: .default, reuseIdentifier: Constants.cellIdentifier)
      }
      
      var content = cell.defaultContentConfiguration()
      content.text = configuration.title
      
      cell.contentConfiguration = content
      return cell
    })
  }
  
}

// MARK: - Bindings

private extension AlbumsViewController {
  
  func setBindings() {
    let output = viewModel.bind(
      input: .init(
        searchQueryDidChange: searchQueryDidChangeSubject.eraseToAnyPublisher()
      )
    )
    
    output.cellConfigurations
      .receive(on: DispatchQueue.main)
      .sink { [tableViewDataSource] configurations in
        var snapshot = NSDiffableDataSourceSnapshot<Int, AlbumCellConfiguration>()
        snapshot.appendSections([0])
        snapshot.appendItems(configurations)
        tableViewDataSource?.apply(snapshot)
      }
      .store(in: &disposeBag)
  }
  
}

// MARK: - Search

private extension AlbumsViewController {
  
  func setUpSearch() {
    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
    searchController.searchResultsUpdater = self
  }
  
}

extension AlbumsViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    let query = searchController.searchBar.text
    searchQueryDidChangeSubject.send(query ?? "")
  }
  
}

// MARK: Views Setup

private extension AlbumsViewController {
  
  func setHierarchy() {
    view.addSubview(tableView)
  }
  
  func setUI() {

  }
  
  func setLayout() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
}
