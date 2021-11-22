//
//  GridImagesCollectionViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 21.11.2021.
//

import UIKit
import Rswift

protocol GridImagesCollectionDelegate: AnyObject {
    func didPickImage(image: UIImage)
}

final class GridImagesCollectionViewModel {
    static let searchDebounceInterval: TimeInterval = 0.6
    
    enum DataSourceUpdateType { case rewrite, append(Int) }
    enum ErrorType { case failedInitialFetch(Error),
                          failedToFetchQuery(String, Error),
                          failedToFetchNextPage(Error),
                          failedToFetchFullImage(Error) }
    
    // MARK: - Properties
    weak var delegate: GridImagesCollectionDelegate?
    
    private let imageFetcher: GridImagesFetcherProtocol
    private let imageIfFailed: UIImage
    private lazy var debouncer: Debouncer = Debouncer(
        timeInterval: Self.searchDebounceInterval
    )
    private let isPaginationEnabled = false
    private var lastSelectedIndex: IndexPath?
    private var fetchedList: [GridPresentableImage] = []
    
    // MARK: Init
    init(imageFetcher: GridImagesFetcherProtocol,
         imageIfFailed: UIImage? = nil,
         delegate: GridImagesCollectionDelegate? = nil) {
        self.imageFetcher = imageFetcher
        self.imageIfFailed = imageIfFailed ?? R.image.failedToLoad()!
        self.delegate = delegate
    }
    
    // MARK: Generate Error Notification
    private func generateErrorNotification(for errorType: ErrorType) -> InAppNotificationViewModel {
        switch errorType {
        case .failedInitialFetch(let error):
            return InAppNotificationViewModel(
                notificationType: .error,
                headerText: "Initial fetch failed",
                bodyText: "Failed to perform initial fetch with error: \(error.localizedDescription)",
                buttonOneText: "Ok"
            )
        case .failedToFetchQuery(let query, let error):
            return InAppNotificationViewModel(
                notificationType: .error,
                headerText: "Query search failed",
                bodyText: "Failed to search images by: \(query).\nError: \(error.localizedDescription)",
                buttonOneText: "Ok"
            )
        case .failedToFetchNextPage(let error):
            return InAppNotificationViewModel(
                notificationType: .error,
                headerText: "Can't fetch more data",
                bodyText: "Failed to fetch more images. \nError: \(error.localizedDescription)",
                buttonOneText: "Ok"
            )
        case .failedToFetchFullImage(let error):
            return InAppNotificationViewModel(
                notificationType: .error,
                headerText: "Can't fetch full image",
                bodyText: "Failed to fetch full image. \nError: \(error.localizedDescription)",
                buttonOneText: "Ok",
                buttonTwoText: "Try again"
            )
        }
    }
}

// MARK: - ViewControllerInput
extension GridImagesCollectionViewModel {
    typealias PresentationStateCallback = (GridImagesCollectionViewController.PresentationState) -> Void
    
    // MARK: View did Load - First fetch
    func viewDidLoad(initial: PresentationStateCallback?,
                     completion: PresentationStateCallback?) {
        initial?(.loading)
        imageFetcher.fetchImagesList(query: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.fetchedList = images
                completion?(.presenting(.rewrite))
            case .failure(let error):
                completion?(
                    .showingError(
                        self.generateErrorNotification(for: .failedInitialFetch(error))
                    )
                )
            }
        }
    }

    // MARK: Did scroll to bottom
    func didScrollToBottom(initial: PresentationStateCallback?,
                           completion: PresentationStateCallback?) {
        // TODO: Хотел пагинацию, но пока не работает
        guard isPaginationEnabled else { return }
        imageFetcher.fetchMoreImages { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.fetchedList.append(contentsOf: images)
                completion?(
                    .presenting(
                        .append(images.count)
                    )
                )
            case .failure(let error):
                completion?(
                    .showingError(
                        self.generateErrorNotification(for: .failedInitialFetch(error))
                    )
                )
            }
        }
    }
    
    // MARK: Did Change Search Query
    func didChangeSearchQuery(withText text: String,
                              initial: PresentationStateCallback?,
                              completion: PresentationStateCallback?) {
        initial?(.loading)
        debouncer.renewInterval()
        debouncer.handler = { [weak self] in
            self?.imageFetcher.fetchImagesList(query: text,
                                               completion: { result in
                guard let self = self else { return }
                switch result {
                case .success(let images):
                    self.fetchedList = images
                    completion?(.presenting(.rewrite))
                case .failure(let error):
                    completion?(
                        .showingError(
                            self.generateErrorNotification(
                                for: .failedToFetchQuery(text, error)
                            )
                        )
                    )
                }
            })
        }
    }
    
    // MARK: Did select cell
    func didSelectCell(atIndexPath indexPath: IndexPath,
                       initial: PresentationStateCallback?,
                       completion: PresentationStateCallback?) {
        lastSelectedIndex = indexPath
        initial?(.loading)
        imageFetcher.fetchFullImage(
            byURL: fetchedList[indexPath.item].fullImageURL
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.delegate?.didPickImage(image: image)
                completion?(.finishing)
            case .failure(let error):
                completion?(
                    .showingError(
                        self.generateErrorNotification(
                            for: .failedToFetchFullImage(error)
                        )
                    )
                )
            }
        }
    }
    
    // MARK: PerformLastRequest
    func performLastRequest(initial: PresentationStateCallback?,
                            completion: PresentationStateCallback?) {
        initial?(.loading)
        guard let lastSelectedIndex = lastSelectedIndex else {
            fatalError("Perform last request called but no requests was performed")
        }
        imageFetcher.fetchFullImage(
            byURL: fetchedList[lastSelectedIndex.item].fullImageURL
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.delegate?.didPickImage(image: image)
                completion?(.finishing)
            case .failure(let error):
                completion?(
                    .showingError(
                        self.generateErrorNotification(
                            for: .failedToFetchFullImage(error)
                        )
                    )
                )
            }
        }
    }
}

// MARK: - CollectionViewControllerDataSource
extension GridImagesCollectionViewModel {
    typealias CellPresentationStateCallback = (GridImagesCollectionCell.PresentationState) -> Void
    
    func numberOfItems(in section: Int) -> Int {
        return fetchedList.count
    }
    
    func statusForCell(atIndexPath indexPath: IndexPath,
                       initial: CellPresentationStateCallback,
                       completion: @escaping CellPresentationStateCallback) {
        initial(.loading)
        imageFetcher.fetchPreviewImage(byURL: fetchedList[indexPath.item].previewImageURL) { [imageIfFailed] result in
            switch result {
            case .success(let image):
                completion(.presenting(image: image))
            case .failure:
                completion(.failed(failImage: imageIfFailed))
            }
        }
    }
}

// MARK: - CollectionViewController PinterestLayoutDelegate
extension GridImagesCollectionViewModel {
    func heightForItem(atIndexPath indexPath: IndexPath) -> CGFloat {
        return fetchedList[indexPath.item].imageHeight
    }
    
    func widthForItem(atIndexPath indexPath: IndexPath) -> CGFloat {
        return fetchedList[indexPath.item].imageWidth
    }
}
