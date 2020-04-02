import Foundation
import RxSwift
import RxRelay

protocol RepositoryStoreType {
    var repositories: Property<[Repository]> { get }
    var bookmarks: Property<[Repository]> { get }
}

final class RepositoryStore: RepositoryStoreType {
    static let shared = RepositoryStore()

    @BehaviorWrapper(value: [])
    private(set) var repositories: Property<[Repository]>

    @BehaviorWrapper(value: [])
    private(set) var bookmarks: Property<[Repository]>

    private let disposeBag = DisposeBag()

    init(dispatcher: RepositoryDispatcher = .shared,
         userDefaults: UserDefaultsType = UserDefaults.standard) {

        dispatcher.updateRepositories
            .bind(to: _repositories)
            .disposed(by: disposeBag)

        if let bookmarks = try? userDefaults.get(key: .bookmarks, of: [Repository].self) {
            _bookmarks.accept(bookmarks)
        }

        dispatcher.updateBookmarks
            .bind(to: _bookmarks)
            .disposed(by: disposeBag)
    }
}
