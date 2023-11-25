//
//  ViewController.swift
//  CustomPullToRefresh
//
//  Created by yc on 2023/11/25.
//

import UIKit
import SnapKit
import Then

final class ViewController: UIViewController {
    
    private let datas = (1...10).map { $0.description }
    
    private var isLoading = false
    
    private lazy var refreshControl = UIRefreshControl().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.tintColor = .clear
        $0.addTarget(
            self,
            action: #selector(beginRefresh),
            for: .valueChanged
        )
    }
    
    private lazy var refreshControlImageView = UIImageView(image: UIImage(systemName: "apple.logo")).then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .label
    }
    
    private lazy var refreshControlView = UIView().then {
        $0.clipsToBounds = true
        $0.addSubview(refreshControlImageView)
        
        refreshControlImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(30)
        }
    }
    
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = 100
        $0.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "CELL"
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.refreshControl = refreshControl
        refreshControl.addSubview(refreshControlView)
        refreshControlView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        setupNavigationBar()
        setupLayout()
    }
    
    @objc func beginRefresh(_ sender: UIRefreshControl) {
        isLoading = true
        animateRefreshControlImageView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isLoading = false
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }
    
    private func animateRefreshControlImageView() {
        if !isLoading { return }
        
        UIView.animate(withDuration: 0.5, delay: 0.3) {
            self.refreshControlImageView.transform = CGAffineTransform(rotationAngle: .pi)
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.refreshControlImageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
            } completion: { _ in
                self.animateRefreshControlImageView()
            }
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "CUSTOM REFRESH"
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        
        var copyDatas = datas
        
        copyDatas.shuffle()
        
        cell.textLabel?.text = copyDatas[indexPath.row]
        
        return cell
    }
}
