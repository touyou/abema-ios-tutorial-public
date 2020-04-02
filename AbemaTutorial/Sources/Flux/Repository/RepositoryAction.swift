import Foundation
import RxSwift

protocol RepositoryActionType {
    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void>
    func bookmarkRepository(repository: Repository)
}

final class RepositoryAction: RepositoryActionType {
    static let shared = RepositoryAction()

    private let apiClient: APIClientType
    private let userDefaults: UserDefaultsType
    private let dispatcher: RepositoryDispatcher
    private let store: RepositoryStoreType

    init(apiClient: APIClientType = APIClient.shared,
         userDefaults: UserDefaultsType = UserDefaults.standard,
         dispatcher: RepositoryDispatcher = .shared,
         store: RepositoryStoreType = RepositoryStore.shared) {
        self.apiClient = apiClient
        self.userDefaults = userDefaults
        self.dispatcher = dispatcher
        self.store = store
    }

    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void> {
        return apiClient
            .fetchRepositories(limit: limit, offset: offset)
            .do(onNext: { [dispatcher] repositories in
                dispatcher.updateRepositories.dispatch(repositories)
            })
            .map(void)
    }

    func bookmarkRepository(repository: Repository) {
        let currentBookmarks = store.bookmarks.value

        guard !currentBookmarks.contains(repository) else {
            return
        }

        let repositories = currentBookmarks + [repository]

        userDefaults.set(key: .bookmarks, newValue: repositories)
        dispatcher.updateBookmarks.dispatch(repositories)
    }
}
