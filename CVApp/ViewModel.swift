import RxSwift
import RxCocoa

class ViewModel {
    
    let restClient: ResumeRestClientServiceProtocol
    init(restClient: ResumeRestClientServiceProtocol = ResumeRestClient()) {
        self.restClient = restClient
    }
    typealias ResumeContent = [ResumeDto]
    private let disposeBag = DisposeBag()
    
    var state: Driver<ViewModelState<ResumeContent>> {
        return stateRelay.asDriver()
    }
    
    private let stateRelay = BehaviorRelay<ViewModelState<ResumeContent>>(value: .loading)
    
    func queryResume(query: Observable<String>) {
        query.flatMapLatest { [stateRelay] (query) -> Observable<[ResumeDto]> in
            stateRelay.accept(.loading)
            return ResumeRestClient().getCV()
                .catchError({ [stateRelay] (error) -> Observable<[ResumeDto]> in
                    stateRelay.accept(.error(error))
                    return Observable.just([])
                })
            }
            .subscribe(onNext: { [stateRelay] (resume) in
                if !resume.isEmpty {
                    stateRelay.accept(.success(content: resume))
                }
            }).disposed(by: disposeBag)
    }
}
