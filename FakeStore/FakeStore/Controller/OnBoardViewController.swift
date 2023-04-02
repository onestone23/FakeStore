//
//  OnboardViewController.swift
//  FakeStore
//
//  Created by leewonseok on 2023/04/01.
//

import UIKit

class OnBoardViewController: UIViewController{
    
    let pageControl = UIPageControl()
    
    let items: [(String, String, UIImage)] = [
        ("Welcome to PpakCoding", "신선한 과일", UIImage(named: "pageA")!),
        ("Welcome to PpakCoding", "Spend smarter every day, all from one app.", UIImage(named: "pageB")!),
        ("Welcome to PpakCoding", "Safe and secure international ppak-coding deep dive", UIImage(named: "pageC")!)
    ]
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let cellWidth = UIScreen.main.bounds.width - 16
        flowLayout.itemSize = CGSize(width: cellWidth, height: 500)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    @objc private let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .colorWithHex(hex: 0xD2D2D2)
        button.layer.cornerRadius = 12
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.colorWithHex(hex: 0x204EC5), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setConstarints()
        setPageControl()
        setCollectionView()
        setAction()
    }
}

extension OnBoardViewController {
    @objc private func loginButtonTapped() {
        let loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
}

// MARK: - Configure Method
extension OnBoardViewController {
    private func setPageControl() {
        pageControl.numberOfPages = items.count
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OnBoardCell.self, forCellWithReuseIdentifier: OnBoardCell.identifier)
    }
    
    private func setUI() {
        [pageControl, collectionView, loginButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setAction() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func setConstarints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

// MARK: - CollectionView Method
extension OnBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnBoardCell.identifier, for: indexPath) as? OnBoardCell else {
            return OnBoardCell()
        }
        
        cell.setData(title: items[indexPath.item].0,
                     content: items[indexPath.item].1,
                     image: items[indexPath.item].2)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / collectionView.frame.size.width)
        pageControl.currentPage = currentPage
    }
}
