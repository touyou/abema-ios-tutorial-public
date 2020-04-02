import Action
import RxRelay
import RxSwift
import Unio

protocol RepositoryListViewStreamType: AnyObject {
    var input: InputWrapper<RepositoryListViewStream.Input> { get }
    var output: OutputWrapper<RepositoryListViewStream.Output> { get }
}

final class RepositoryListViewStream: UnioStream<RepositoryListViewStream>, RepositoryListViewStreamType {

    convenience init(flux: Flux = .shared) {
        self.init(input: Input(),
                  state: State(),
                  extra: Extra(flux: flux))
    }
}

extension RepositoryListViewStream {
    struct Input: InputType {
        let viewWillAppear = PublishRelay<Void>()
        let refreshControlValueChanged = PublishRelay<Void>()
        let fetchErrorAlertDismissed = PublishRelay<Void>()
        let didSelectCell = PublishRelay<IndexPath>()
        let didBookmarkRepository = PublishRelay<Repository>()
    }

    struct Output: OutputType {
        let repositories: BehaviorRelay<[Repository]>
        let reloadData: PublishRelay<Void>
        let isRefreshControlRefreshing: BehaviorRelay<Bool>
        let presentFetchErrorAlert: PublishRelay<Void>
        let presentBookmarkAlert: PublishRelay<(IndexPath, Repository)>
        let presentAlreadyBookmarkedAlert: PublishRelay<IndexPath>
    }

    struct State: StateType {
        let repositories = BehaviorRelay<[Repository]>(value: [])
        let bookmarks = BehaviorRelay<[Repository]>(value: [])
        let isRefreshControlRefreshing = BehaviorRelay<Bool>(value: false)
    }

    struct Extra: ExtraType {
        let flux: Flux

        let fetchRepositoriesAction: Action<(limit: Int, offset: Int), Void>
    }
}

extension RepositoryListViewStream {
    static func bind(from dependency: Dependency<Input, State, Extra>, disposeBag: DisposeBag) -> Output {
        let state = dependency.state
        let extra = dependency.extra

        let flux = extra.flux
        let fetchRepositoriesAction = extra.fetchRepositoriesAction

        let viewWillAppear = dependency.inputObservables.viewWillAppear
        let refreshControlValueChanged = dependency.inputObservables.refreshControlValueChanged
        let fetchErrorAlertDismissed = dependency.inputObservables.fetchErrorAlertDismissed
        let didSelectCell = dependency.inputObservables.didSelectCell
        let didBookmarkRepository = dependency.inputObservables.didBookmarkRepository

        let fetchRepositories = Observable
            .merge(viewWillAppear,
                   refreshControlValueChanged,
                   fetchErrorAlertDismissed)

        fetchRepositories
            .map { (limit: Const.count, offset: 0) }
            .bind(to: fetchRepositoriesAction.inputs)
            .disposed(by: disposeBag)

        flux.repositoryStore.repositories.asObservable()
            .bind(to: state.repositories)
            .disposed(by: disposeBag)

        flux.repositoryStore.bookmarks.asObservable()
            .bind(to: state.bookmarks)
            .disposed(by: disposeBag)

        fetchRepositoriesAction.executing
            .bind(to: state.isRefreshControlRefreshing)
            .disposed(by: disposeBag)

        let presentFetchErrorAlert = PublishRelay<Void>()

        fetchRepositoriesAction.errors
            .map(void)
            .bind(to: presentFetchErrorAlert)
            .disposed(by: disposeBag)

        let reloadData = PublishRelay<Void>()

        state.repositories
            .map(void)
            .bind(to: reloadData)
            .disposed(by: disposeBag)

        let presentBookmarkAlert = PublishRelay<(IndexPath, Repository)>()
        let presentAlreadyBookmarkedAlert = PublishRelay<IndexPath>()

        didSelectCell
            .subscribe(onNext: { indexPath in
                guard let repository = state.repositories.value[safe: indexPath.row] else {
                    return
                }

                if state.bookmarks.value.contains(repository) {
                    presentAlreadyBookmarkedAlert.accept(indexPath)
                } else {
                    presentBookmarkAlert.accept((indexPath, repository))
                }
            })
            .disposed(by: disposeBag)

        didBookmarkRepository
            .subscribe(onNext: {
                flux.repositoryAction.bookmarkRepository(repository: $0)
            })
            .disposed(by: disposeBag)

        return Output(repositories: state.repositories,
                      reloadData: reloadData,
                      isRefreshControlRefreshing: state.isRefreshControlRefreshing,
                      presentFetchErrorAlert: presentFetchErrorAlert,
                      presentBookmarkAlert: presentBookmarkAlert,
                      presentAlreadyBookmarkedAlert: presentAlreadyBookmarkedAlert)
    }
}

extension RepositoryListViewStream.Extra {
    init(flux: Flux) {
        self.flux = flux

        let repositoryAction = flux.repositoryAction

        self.fetchRepositoriesAction = Action { limit, offset in
            repositoryAction.fetchRepositories(limit: limit, offset: offset)
        }
    }
}

extension RepositoryListViewStream {
    enum Const {
        static let count: Int = 20
    }
}
