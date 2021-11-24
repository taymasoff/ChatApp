//
//  GridImagesCollectionViewController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 20.11.2021.
//

import UIKit

final class GridImagesCollectionViewController: PopupViewController, ViewModelBased {
    
    enum PresentationState {
        case loading
        case presenting(GridImagesCollectionViewModel.DataSourceUpdateType)
        case showingError(InAppNotificationViewModel)
        case finishing
    }
    
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let collectionView: UICollectionView
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for images"
        searchBar.tintColor = ThemeManager.currentTheme.settings.tintColor
        searchBar.barTintColor = ThemeManager.currentTheme.settings.mainColor
        searchBar.barStyle = ThemeManager.currentTheme.settings.barStyle
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.forceTextFieldAppearance(
            textColor: ThemeManager.currentTheme.settings.titleTextColor,
            placeholderColor: ThemeManager.currentTheme.settings.subtitleTextColor
        )
        return searchBar
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.backgroundColor = .clear
        activity.color = ThemeManager.currentTheme.settings.tintColor
        return activity
    }()
    
    private lazy var inAppNotification = InAppNotificationBanner()
    
    private let isSearchBarEnabled: Bool
    private var viewState: GridImagesCollectionViewController.PresentationState = .loading {
        didSet {
            DispatchQueue.main.async {
                self.handleViewStateChange(viewState: self.viewState)
            }
        }
    }
    
    var viewModel: GridImagesCollectionViewModel?
    
    // MARK: - Inits
    init(layout: UICollectionViewLayout = PinterestLayout(numberOfColumns: 3, spacing: 4),
         popupSize: PopupSize = .normal,
         enableSearchBar: Bool) {
        self.collectionView = UICollectionView(frame: CGRect.zero,
                                               collectionViewLayout: layout)
        self.isSearchBarEnabled = enableSearchBar
        super.init(popupView: containerStackView, popupSize: popupSize, shapeCorners: false)
    }
    
    convenience init(viewModel: GridImagesCollectionViewModel,
                     layout: UICollectionViewLayout = PinterestLayout(numberOfColumns: 3, spacing: 4),
                     enableSearchBar: Bool) {
        self.init(layout: layout, enableSearchBar: enableSearchBar)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSubviewsLayout()
        
        viewModel?.viewDidLoad(
            initial: { [weak self] initialState in
                self?.viewState = initialState
            }, completion: { [weak self] state in
                self?.viewState = state
            }
        )
    }
    
    // MARK: - Config
    private func setupCollectionView() {
        collectionView.register(GridImagesCollectionCell.self,
                                forCellWithReuseIdentifier: GridImagesCollectionCell.reuseID)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
    }
    
    private func setupSubviewsLayout() {
        view.addSubview(containerStackView)
        if isSearchBarEnabled {
            searchBar.delegate = self
            containerStackView.addArrangedSubview(searchBar)
        }
        containerStackView.addArrangedSubview(collectionView)
        collectionView.addSubview(activityIndicator)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
                .priority(800)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
    }
}

// MARK: - ViewState Updates
private extension GridImagesCollectionViewController {
    func handleViewStateChange(viewState: GridImagesCollectionViewController.PresentationState) {
        switch viewState {
        case .loading:
            activityIndicator.startAnimating()
            collectionView.isUserInteractionEnabled = false
        case .presenting(let dataSourceChange):
            handleDataSourceUpdate(change: dataSourceChange)
            activityIndicator.stopAnimating()
            collectionView.isUserInteractionEnabled = true
        case .showingError(let notificationModel):
            presentErrorNotification(notificationModel: notificationModel)
            activityIndicator.stopAnimating()
            collectionView.isUserInteractionEnabled = true
        case .finishing:
            activityIndicator.stopAnimating()
            collectionView.isUserInteractionEnabled = true
            self.dismissPopup { }
        }
    }
    
    func handleDataSourceUpdate(change: GridImagesCollectionViewModel.DataSourceUpdateType) {
        switch change {
        case .rewrite:
            collectionView.setContentOffset(CGPoint(x: 0, y: 0),
                                            animated: true)
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        case .append:
            break // Тут должен быть insertRows, но чет пока не получается
        }
    }
    
    func calculateIndexPathsForNewItems(amount: Int) -> [IndexPath] {
        let startIndex = collectionView.numberOfItems(inSection: 0)
        let endIndex = startIndex + amount
        return Array(startIndex...endIndex)
            .map { IndexPath(item: $0, section: 0) }
    }
    
    func presentErrorNotification(notificationModel: InAppNotificationViewModel) {
        inAppNotification.configure(with: notificationModel)
        inAppNotification.show()
        inAppNotification.onButtonOnePress = { [weak self] in
            self?.inAppNotification.dismiss()
        }
        inAppNotification.onButtonTwoPress = { [weak self] in
            self?.inAppNotification.dismiss()
            self?.viewModel?.performLastRequest(
                initial: { [weak self] initialState in
                    self?.viewState = initialState
                }, completion: { [weak self] state in
                    self?.viewState = state
                }
            )
        }
    }
}

// MARK: - UICollectionViewDataSource
extension GridImagesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItems(in: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GridImagesCollectionCell.reuseID,
            for: indexPath) as? GridImagesCollectionCell else {
                fatalError("Couldn't deque cell with id \(GridImagesCollectionCell.reuseID)")
            }
        
        viewModel?.statusForCell(
            atIndexPath: indexPath,
            initial: { [weak cell] initialState in
                cell?.configure(with: initialState)
            }, completion: { [weak cell] state in
                cell?.configure(with: state)
            }
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GridImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
}

// MARK: - PinterestLayoutDelegate
extension GridImagesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        guard let viewModel = viewModel else { return 0 }
        return viewModel.heightForItem(atIndexPath: indexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension GridImagesCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard let itemsCount = viewModel?.numberOfItems(in: indexPath.section),
              itemsCount > 0,
              indexPath.row == itemsCount - 1 else { return }
        
        viewModel?.didScrollToBottom(
            initial: { [weak self] initialState in
                self?.viewState = initialState
            }, completion: { [weak self] state in
                self?.viewState = state
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectCell(
            atIndexPath: indexPath,
            initial: { [weak self] initialState in
                self?.viewState = initialState
            }, completion: { [weak self] state in
                self?.viewState = state
            }
        )
    }
}

// MARK: - SearchBarDelegate
extension GridImagesCollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.didChangeSearchQuery(
            withText: searchText,
            initial: { [weak self] initialState in
                self?.viewState = initialState
            },
            completion: { [weak self] state in
                self?.viewState = state
            }
        )
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.didPressSearchButton(
            text: searchBar.text ?? "",
            initial: { [weak self] initialState in
                self?.viewState = initialState
            },
            completion: { [weak self] state in
                self?.viewState = state
            }
        )
    }
}
