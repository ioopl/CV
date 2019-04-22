//
//  ViewController.swift
//  CVApp
//
//  Created by Umair Hasan on 21/04/2019.
//  Copyright © 2019 Umair Hasan. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct ResumeResult: Codable {
    let contents: [ResumeDto]
}

struct ResumeDto: Codable, Equatable {
    let title: String
}

enum ResumeRestClientError: Error {
    case error
}

enum Resume: String {
    case title
    case href
    case description
    case thumbnail
}

enum TableViewCell: String {
    case cell = "Cell"
}


class ResumeRestClient {
    func getCV() -> Observable<[ResumeDto]> {
        let urlComponents = URLComponents(url: URL(string: "https://api.myjson.com/bins/vsgac")!, resolvingAgainstBaseURL: true)!
        let request = URLRequest(url: urlComponents.url!)
        return RemoteServiceDispatcher().dispatch(request: request).flatMap({ (response: HTTPURLResponse, data: Data) -> Observable<[ResumeDto]> in

            if 200..<300 ~= response.statusCode {
                let decoder = JSONDecoder()
                let result = try! decoder.decode(ResumeResult.self, from: data)
                return Observable.just(result.contents)
            } else {
                return Observable.error(ResumeRestClientError.error)
            }
        })
    }
}

protocol RequestDispatcher {
    func dispatch(request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)>
}

class RemoteServiceDispatcher: RequestDispatcher {
    func dispatch(request: URLRequest) -> Observable<(response: HTTPURLResponse, data: Data)> {
        return URLSession.shared.rx.response(request: request)
    }
}

// MARK: - View Controller Coordinator
class ResumeViewCoordinator {
    let navigationController: UINavigationController?
    let resume: ResumeDto
    let disposeBag = DisposeBag()

    init(navigationController: UINavigationController?, resume: ResumeDto) {
        self.navigationController = navigationController
        self.resume = resume
    }

    func start() {
        let vc = DetailsViewController(dto: resume)
        navigationController?.pushViewController(vc, animated: true)
    }
}

class ViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private let errorLabel = UILabel()
    private let loading = UIActivityIndicatorView(style: .gray)
    private var coordinator: ResumeViewCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TableViewCell.cell.rawValue)
        view.addSubview(tableView)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

        Observable.just([ResumeDto(title: Resume.title.rawValue)]).flatMapLatest { _ in
                    ResumeRestClient().getCV()
                }.bind(to: tableView.rx.items(cellIdentifier: TableViewCell.cell.rawValue)) { (index: Int, dto: ResumeDto, cell: UITableViewCell) in
                    cell.textLabel?.text = dto.title
                }.disposed(by: disposeBag)

        tableView.rx.modelSelected(ResumeDto.self)
            .subscribe(onNext: { [weak self] (dto) in
                self?.coordinator = ResumeViewCoordinator(navigationController: self?.navigationController, resume: dto)
                self?.coordinator?.start()
            }).disposed(by: disposeBag)
    }
}

