import XCTest
import RxSwift
import RxTest

@testable import AbemaTutorial

final class RepositoryListViewStreamTests: XCTestCase {
    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testViewWillAppear() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // viewWillAppearの後

        testTarget.input.accept((), for: \.viewWillAppear)

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])
    }

    func testRefreshControlValueChanged() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // リフレッシュ後

        testTarget.input.accept((), for: \.refreshControlValueChanged)

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])
    }

    func testFetchErrorAlertDismissed() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction
        let repositoryStore = dependency.repositoryStore

        let mockRepository = Repository.mock()

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // アラートを閉じた後

        testTarget.input.accept((), for: \.fetchErrorAlertDismissed)

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // データが返ってきた後

        repositoryAction._fetchResult.accept(.next(()))
        repositoryAction._fetchResult.accept(.completed)
        repositoryStore._repositories.accept([mockRepository])

        XCTAssertEqual(repositories.value, [mockRepository])
        XCTAssertEqual(reloadData.events, [.next(true)])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])
    }

    func testFetchError() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction

        let repositories = WatchStack(testTarget.output.repositories)
        let reloadData = WatchStack(testTarget.output.reloadData.map { true }) // Voidだと比較できないのでBool化
        let isRefreshControlRefreshing = WatchStack(testTarget.output.isRefreshControlRefreshing)
        let presentFetchErrorAlert = WatchStack(testTarget.output.presentFetchErrorAlert.map { true })

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // アラートを閉じた後

        testTarget.input.accept((), for: \.fetchErrorAlertDismissed)

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, true)
        XCTAssertEqual(presentFetchErrorAlert.events, [])

        // エラーが返ってきた後

        repositoryAction._fetchResult.accept(.error(APIError.internalServerError))

        XCTAssertEqual(repositories.value, [])
        XCTAssertEqual(reloadData.events, [])
        XCTAssertEqual(isRefreshControlRefreshing.value, false)
        XCTAssertEqual(presentFetchErrorAlert.events, [.next(true)])
    }

    func testDidSelectCell() {
        let testTarget = dependency.testTarget
        let repositoryStore = dependency.repositoryStore

        let repositories = WatchStack(testTarget.output.repositories)
        let presentBookmarkAlert = WatchStack(testTarget.output.presentBookmarkAlert)
        let presentAlreadyBookmarkedAlert = WatchStack(testTarget.output.presentAlreadyBookmarkedAlert)

        // 初期状態

        XCTAssertEqual(repositories.value, [])
        XCTAssertTrue(presentBookmarkAlert.events.isEmpty)
        XCTAssertTrue(presentAlreadyBookmarkedAlert.events.isEmpty)

        // セルの選択後

        let repository = Repository.mock()
        repositoryStore._repositories.accept([repository])

        let indexPath = IndexPath(row: 0, section: 0)
        testTarget.input.accept(indexPath, for: \.didSelectCell)

        XCTAssertEqual(repositories.value, [repository])
        XCTAssertEqual(presentBookmarkAlert.value?.0, indexPath)
        XCTAssertEqual(presentBookmarkAlert.value?.1, repository)
        XCTAssertEqual(presentBookmarkAlert.events.count, 1)
        XCTAssertTrue(presentAlreadyBookmarkedAlert.events.isEmpty)

        // お気に入り登録済みのセルの選択後

        repositoryStore._bookmarks.accept([repository])

        testTarget.input.accept(indexPath, for: \.didSelectCell)

        XCTAssertEqual(repositories.value, [repository])
        XCTAssertEqual(presentBookmarkAlert.value?.0, indexPath)
        XCTAssertEqual(presentBookmarkAlert.value?.1, repository)
        XCTAssertEqual(presentBookmarkAlert.events.count, 1)
        XCTAssertEqual(presentAlreadyBookmarkedAlert.value, indexPath)
        XCTAssertEqual(presentAlreadyBookmarkedAlert.events.count, 1)
    }

    func testDidBookmarkRepository() {
        let testTarget = dependency.testTarget
        let repositoryAction = dependency.repositoryAction

        // 初期状態

        XCTAssertNil(repositoryAction._bookmarkResult)

        // お気に入り登録後

        let repository = Repository.mock()

        testTarget.input.accept(repository, for: \.didBookmarkRepository)

        XCTAssertEqual(repositoryAction._bookmarkResult, repository)
    }
}

extension RepositoryListViewStreamTests {
    struct Dependency {
        let testTarget: RepositoryListViewStream

        let repositoryStore: MockRepositoryStore
        let repositoryAction: MockRepositoryAction

        init() {
            repositoryStore = MockRepositoryStore()
            repositoryAction = MockRepositoryAction()

            let flux = Flux(repositoryStore: repositoryStore,
                            repositoryAction: repositoryAction)

            testTarget = RepositoryListViewStream(flux: flux)
        }
    }
}
