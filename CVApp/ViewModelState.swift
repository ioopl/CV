import RxSwift
import RxCocoa

enum ViewModelState<T>: ViewModelStateDefinition {
    var loading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var error: Bool {
        if case .error(_) = self {
            return true
        }
        return false
    }

    var isSuccess: Bool {
        if case .success(_) = self {
            return true
        }
        return false
    }

    var content: T? {
        if case .success(let content) = self {
            return content
        }
        return nil
    }

    var errorMessage: String? {
        return "No results"
    }

    typealias E = T
    case loading
    case error(_: Error)
    case success(content: T)
}

protocol ViewModelStateDefinition {
    associatedtype E
    var loading: Bool {get}
    var error: Bool {get}
    var isSuccess: Bool {get}
    var content: E? {get}
    var errorMessage: String? {get}
}

extension SharedSequence where E: ViewModelStateDefinition {

    var loading: RxCocoa.SharedSequence<S, Bool> {
        return map { $0.loading }
    }

    var error: RxCocoa.SharedSequence<S, Bool> {
        return map { $0.error }
    }

    var isSuccess: RxCocoa.SharedSequence<S, Bool> {
        return map { $0.isSuccess }
    }

    var content: RxCocoa.SharedSequence<S, Element.E> {
        return flatMap {
            if let content = $0.content {
                return SharedSequence<S, Element.E>.just(content)
            } else {
                return SharedSequence<S, Element.E>.empty()
            }
        }
    }

    var errorMessage: RxCocoa.SharedSequence<S, String> {
        return flatMap {
            if let errorMessage = $0.errorMessage {
                return SharedSequence<S, String>.just(errorMessage)
            } else {
                return SharedSequence<S, String>.empty()
            }
        }
    }

}
