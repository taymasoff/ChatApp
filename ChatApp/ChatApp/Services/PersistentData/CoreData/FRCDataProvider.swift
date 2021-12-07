//
//  FRCDataProvider.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 16.11.2021.
//

import CoreData

protocol FRCTableViewDataProviderProtocol {
    associatedtype Entity
    
    func numberOfSections() -> Int
    func numberOfObjectsInSection(_ section: Int) -> Int
    func nameOfSection(_ section: Int) -> String?
    func entity(atIndexPath indexPath: IndexPath) -> Entity
}

protocol FRCDataProviderProtocol: FRCTableViewDataProviderProtocol {
    var changes: Dynamic<[DataSourceChange]> { get }
    func startFetching() throws
}

final class FRCDataProvider<Entity: NSManagedObject>: NSObject,
                                                      FRCDataProviderProtocol,
                                                      NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    private let frc: NSFetchedResultsController<Entity>
    
    let changes: Dynamic<[DataSourceChange]> = Dynamic([])
    private var changesCache: [DataSourceChange] = []
    
    // MARK: - Init
    init(fetchRequest: NSFetchRequest<Entity>,
         coreDataStack: CoreDataStackProtocol,
         sectionKeyPath: String? = nil, cacheName: String? = nil) {
        
        self.frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.mainContext,
            sectionNameKeyPath: sectionKeyPath,
            cacheName: cacheName
        )
        
        super.init()
        
        frc.delegate = self
    }
    
    // MARK: - StartFetching
    func startFetching() throws {
        do {
            try frc.performFetch()
        } catch {
            throw CoreDataError.fetchingFailed
        }
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    // MARK: Will Change Content
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        changes.value.removeAll()
    }
    
    // MARK: Did Change Section Info
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        if type == .insert {
            changesCache.append(.section(.inserted(sectionIndex)))
        } else if type == .delete {
            changesCache.append(.section(.deleted(sectionIndex)))
        }
    }
    
    // MARK: Did Change Object
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            changesCache.append(.object(.inserted(at: newIndexPath!)))
        case .delete:
            changesCache.append(.object(.deleted(from: indexPath!)))
        case .move:
            changesCache.append(.object(.moved(from: indexPath!, to: newIndexPath!)))
        case .update:
            changesCache.append(.object(.updated(at: indexPath!)))
        default:
            break
        }
    }
    
    // MARK: Did Change Content
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        changes.value.append(contentsOf: changesCache)
        changesCache.removeAll()
    }
}

// MARK: - FRCTableViewDataProviderProtocol
extension FRCDataProvider {
    func numberOfSections() -> Int {
        return frc.sections?.count ?? 0
    }
    
    func numberOfObjectsInSection(_ section: Int) -> Int {
        guard let sections = frc.sections, sections.endIndex > section else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func nameOfSection(_ section: Int) -> String? {
        return frc.sections?[section].name
    }
    
    func entity(atIndexPath indexPath: IndexPath) -> Entity {
        return frc.object(at: indexPath)
    }
}
