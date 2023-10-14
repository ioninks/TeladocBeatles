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
  private var tableViewDataSource: UITableViewDiffableDataSource<Int, String>?
  
  private let viewModel: AlbumsViewModelProtocol
  
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
    setDataSource()
    setBindings()
  }
  
}

// MARK: - Data Source

private extension AlbumsViewController {
  
  func setDataSource() {
    tableViewDataSource = .init(tableView: tableView, cellProvider: { tableView, _, title in
      let cell: UITableViewCell
      if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) {
        cell = dequeuedCell
      } else {
        cell = UITableViewCell(style: .default, reuseIdentifier: Constants.cellIdentifier)
      }
      
      var content = cell.defaultContentConfiguration()
      content.text = title
      
      cell.contentConfiguration = content
      return cell
    })
  }
  
}

// MARK: - Bindings

private extension AlbumsViewController {
  
  func setBindings() {
    let output = viewModel.bind(input: .init())
    
    output.cellTitles
      .receive(on: DispatchQueue.main)
      .sink { [tableViewDataSource] titles in
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(titles)
        tableViewDataSource?.apply(snapshot)
      }
      .store(in: &disposeBag)
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
