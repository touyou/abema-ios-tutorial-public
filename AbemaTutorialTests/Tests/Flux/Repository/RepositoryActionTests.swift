import XCTest
import RxSwift
import RxTest

@testable import AbemaTutorial

final class RepositoryActionTests: XCTestCase {
    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
    }

    func testFetchRepositories() {
        let testTarget = dependency.testTarget
        let apiClient = dependency.apiClient

        let mockRepository = Repository.mock()

        let fetchRepositories = WatchStack(
            testTarget
                .fetchRepositories(limit: 123, offset: 123)
                .map { true } // Voidだと比較できないのでBool化
        )

        // 初期状態
        XCTAssertEqual(fetchRepositories.events, [])

        // APIClientから結果返却後
        apiClient._fetchRepositories.accept(.next([mockRepository]))
        apiClient._fetchRepositories.accept(.completed)

        XCTAssertEqual(fetchRepositories.events, [.next(true), .completed])
    }

    func testBookmarkRepository() {
        let testTarget = dependency.testTarget
        let userDefaults = dependency.userDefaults
        let repositoryDispatcher = dependency.repositoryDispatcher
        let repositoryStore = dependency.repositoryStore

        let mockRepository1 = Repository.mock(id: 1)
        let mockRepository2 = Repository.mock(id: 2)

        let mockRepositories = [mockRepository1, mockRepository2]

        let updateBookmarks = WatchStack(repositoryDispatcher.updateBookmarks)

        // 初期状態
        XCTAssertEqual(updateBookmarks.events, [])
        XCTAssertThrowsError(try userDefaults.get(key: .bookmarks, of: [Repository].self))

        repositoryStore._bookmarks.accept([mockRepository1])

        // お気に入り登録後
        testTarget.bookmarkRepository(repository: mockRepository2)

        XCTAssertEqual(updateBookmarks.events, [.next(mockRepositories)])
        XCTAssertNoThrow(try userDefaults.get(key: .bookmarks, of: [Repository].self))

        // すでに登録されているものをお気に入り登録
        repositoryStore._bookmarks.accept([mockRepository1, mockRepository2])
        testTarget.bookmarkRepository(repository: mockRepository2)

        XCTAssertEqual(updateBookmarks.events, [.next(mockRepositories)])
        XCTAssertNoThrow(try userDefaults.get(key: .bookmarks, of: [Repository].self))
    }
}

extension RepositoryActionTests {
    struct Dependency {
        let testTarget: RepositoryAction

        let apiClient: MockAPIClient
        let userDefaults: MockUserDefaults
        let repositoryDispatcher: RepositoryDispatcher
        let repositoryStore: MockRepositoryStore

        init() {
            apiClient = MockAPIClient()
            userDefaults = MockUserDefaults()
            repositoryDispatcher = RepositoryDispatcher()
            repositoryStore = MockRepositoryStore()

            testTarget = RepositoryAction(apiClient: apiClient,
                                          userDefaults: userDefaults,
                                          dispatcher: repositoryDispatcher,
                                          store: repositoryStore)
        }
    }
}
