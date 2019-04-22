//
//  DetailsViewController.swift
//  CVApp
//
//  Created by Umair Hasan on 21/04/2019.
//  Copyright © 2019 Umair Hasan. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DetailsViewController: UIViewController {

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

        view.backgroundColor = UIColor.white
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Avenir Next", size: 17.0)

        view.addSubview(label)
        label.text = dto.title
        label.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(30)
            make.top.equalTo(self.view).offset(-100)
            make.right.equalTo(self.view).offset(-30)
            make.bottom.equalTo(self.view)
        }
    }
}
