//
//  ListViewController.swift
//  FakeStore
//
//  Created by leewonseok on 2023/03/27.
//

import UIKit

class ListViewController: UIViewController {
    private let sortList = [SortType.desc.description, SortType.asc.description]
    private var sortState = 0
    
    private var items: [Item]? {
        didSet {
            DispatchQueue.main.async {
                self.sortStackView.isHidden = false
                self.spinnerView.isHidden = true
                self.itemCountLabel.text = "\(self.items?.count ?? 0)개의 상품"
                self.sortLabel.text = self.sortList[self.sortState]
                self.collectionView.reloadData()
            }
        }
    }
    
    private let toTopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.circle"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.tintColor = .colorWithHex(hex: 0xD9D9D9)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sortTextField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.backgroundColor = .colorWithHex(hex: 0xF7F7F7)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .gray
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .colorWithHex(hex: 0x696B72)
        return label
    }()
    
    private let sortStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = true
        stackView.isHidden = true
        return stackView
    }()
    
    private let sortLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .colorWithHex(hex: 0x696B72)
        return label
    }()
    
    private let sortImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = .colorWithHex(hex: 0x696B72)
        return imageView
    }()
    
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = (UIScreen.main.bounds.width - 50) / 2
        flowLayout.itemSize = CGSize(width: cellWidth, height: 300)
        flowLayout.minimumInteritemSpacing = 15
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNaviBar()
        setUI()
        setConstraints()
        setCollectionView()
        setSortTextField()
        setActionAndGesture()
        fetchItemAll()
    }
    
    private func sortItem(type: SortType?) {
        switch type {
        case .desc:
            items = items?.sorted {
                $0.id < $1.id
            }
        case .asc:
            items = items?.sorted {
                $0.id > $1.id
            }
        case .none:
            break
        }
    }
    
    private func fetchItemAll() {
        spinnerView.startAnimating()
        
        NetworkManager.fetchItemAll(urlString: Constants.URL) { result in
            switch result {
            case .success(let items):
                self.items = items
            case .failure(_):
                break
            }
        }
    }
}
// MARK: - Action
extension ListViewController {
    @objc private func sortDoneButtonTapped() {
        self.view.endEditing(true)
        sortLabel.text = sortList[sortState]
        sortItem(type: SortType(rawValue: sortState))
    }
    
    @objc private func sortButtonTapped() {
        sortTextField.becomeFirstResponder()
    }
    
    @objc private func toTopButtonTapped() {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

// MARK: - CollectionView Method
extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.identifier, for: indexPath) as? ItemCell else {
            return ItemCell()
        }
    
        if let item = items?[indexPath.item] {
            cell.setData(item: item)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        
        if let item = items?[indexPath.item] {
            detailViewController.setData(item: item)
        }
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - PickerView Method
extension ListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(sortList[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         sortState = row
    }
}

// MARK: - Coniguration Method
extension ListViewController {
    private func setNaviBar() {
        navigationItem.title = "상품목록"
    }
    
    private func setCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.identifier)
    }
    
    private func setSortTextField() {
        let barButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(sortDoneButtonTapped))
        toolbar.setItems([barButton], animated: true)
        pickerView.delegate = self
        pickerView.dataSource = self
        sortTextField.inputAccessoryView = toolbar
        sortTextField.inputView = pickerView
    }
    
    private func setActionAndGesture() {
        let sortGesture = UITapGestureRecognizer(target: self, action: #selector(sortButtonTapped))
        sortStackView.addGestureRecognizer(sortGesture)
        toTopButton.addTarget(self, action: #selector(toTopButtonTapped), for: .touchUpInside)
    }
    
    private func setUI() {
        [sortLabel, sortImageView].forEach {
            sortStackView.addArrangedSubview($0)
        }
        
        [itemCountLabel, sortStackView].forEach {
            labelStackView.addArrangedSubview($0)
        }
        
        [labelStackView, collectionView, spinnerView, sortTextField, toTopButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            labelStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            labelStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            toTopButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            toTopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            toTopButton.heightAnchor.constraint(equalToConstant: 44),
            toTopButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
}