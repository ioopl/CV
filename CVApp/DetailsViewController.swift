import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DetailsViewController: UIViewController {

    let disposeBag = DisposeBag()
    let dto: ResumeDto
    init(dto: ResumeDto) {
        self.dto = dto
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        view.backgroundColor = UIColor.white

        let labelTitle = UILabel()
        labelTitle.font = UIFont(name: "Avenir Next Bold", size: 15.0)
        labelTitle.text = dto.title

        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Avenir Next", size: 17.0)
        label.text = dto.details

        view.addSubview(labelTitle)
        view.addSubview(label)

        labelTitle.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(8)
            make.left.equalTo(self.view).offset(8)
            make.right.equalTo(self.view).offset(-8)
            make.height.equalTo(100)
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(8)
            make.right.equalTo(self.view).offset(-8)
            make.bottom.equalTo(self.view)
            make.top.equalTo(labelTitle.snp.bottom).offset(-8)
        }
    }
}
