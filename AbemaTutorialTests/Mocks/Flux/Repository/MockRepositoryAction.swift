import RxSwift
import RxRelay

@testable import AbemaTutorial

final class MockRepositoryAction: RepositoryActionType {
    let _fetchResult = PublishRelay<Event<Void>>()

    func fetchRepositories(limit: Int, offset: Int) -> Observable<Void> {
        return _fetchResult.dematerialize()
    }

    private(set) var _bookmarkResult: Repository?

    func bookmarkRepository(repository: Repository) {
        _bookmarkResult = repository
    }
}
