//
//  InstructionView.swift
//  Recipee
//
//  Created by Alex on 02/01/2023.
//

import UIKit

class InstructionView: UIView {
    
    private let steps: [Step]
    private var pagesVertical = [UIView]()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.isPagingEnabled = true
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let stackViewContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let holderPageControl: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 0
        pageControl.backgroundStyle = .prominent
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.allowsContinuousInteraction = true
        return pageControl
    }()
    
    init(steps: [Step]) {
        self.steps = steps
        if steps.count == 1 {
            pageControl.isHidden = true
        }
        pageControl.numberOfPages = steps.count
        pageControl.transform = CGAffineTransform(rotationAngle: .pi / 2)
        for step in steps {
            let stepView = StepView(model: StepViewModel(description: step.step, numberOfStep: step.number, ingredients: step.ingredients.filter({ ingr in
                guard let image = ingr.image, !image.isEmpty else {
                    return false
                }
                return true
            }), equipment: step.equipment, allStepsNumber: steps.count))
            pagesVertical.append(stepView)
        }
        super.init(frame: .zero)
        layout()
        scrollView.delegate = self
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func pageChanged() {
        scrollView.setContentOffset(CGPoint(x: 0, y: pageControl.currentPage * Int(frame.height)), animated: true)
    }
    
    private func layout() {
        addSubview(scrollView)
        holderPageControl.addSubview(pageControl)
        addSubview(holderPageControl)
        
        scrollView.addSubview(stackViewContainer)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            pageControl.centerYAnchor.constraint(equalTo: holderPageControl.centerYAnchor),
            pageControl.centerXAnchor.constraint(equalTo: holderPageControl.centerXAnchor),
            
            holderPageControl.heightAnchor.constraint(equalTo: pageControl.widthAnchor),
            holderPageControl.widthAnchor.constraint(equalTo: pageControl.heightAnchor),
            
            holderPageControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: holderPageControl.trailingAnchor, multiplier: 1)
        ])
        
        pagesVertical.forEach { [weak self] myView in
            guard let strongSelf = self else {
                return
            }
            strongSelf.stackViewContainer.addArrangedSubview(myView)
            NSLayoutConstraint.activate([
                myView.widthAnchor.constraint(equalTo: strongSelf.safeAreaLayoutGuide.widthAnchor),
                myView.heightAnchor.constraint(equalTo: strongSelf.safeAreaLayoutGuide.heightAnchor)
            ])
        }
    }
}

extension InstructionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for i in 0..<steps.count {
            if scrollView.contentOffset.y == CGFloat(i) * frame.height {
                pageControl.currentPage = i
            }
        }
    }
}
