//
//  StepByStepViewController.swift
//  Recipee
//
//  Created by Alex on 02/01/2023.
//

import UIKit

class StepByStepViewController: UIViewController {
    
    private let instructions: [Instruction]
    private let ingredients: [Ingredient]
    private var pagesHorizontal = [UIView]()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = true
        return scroll
    }()
    
    private let stackViewContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
    
    private var sideMenu: SideMenuView?
    
    private var sideMenuLeadingConstraint: NSLayoutConstraint?
    private var sideMenuTrailingConstraint: NSLayoutConstraint?
    
    init(instructions: [Instruction], ingredients: [Ingredient]) {
        self.instructions = instructions
        self.ingredients = ingredients
        if instructions.count == 1 {
            pageControl.isHidden = true
        }
        pageControl.numberOfPages = instructions.count
        for instruction in instructions {
            let instructionView = InstructionView(steps: instruction.steps)
            
            pagesHorizontal.append(instructionView)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.shadowColor = .gray
            appearance.backgroundColor = .background
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        if !ingredients.isEmpty {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ingredients", style: .plain, target: self, action: #selector(ingredientsButtonTapped))
            navigationItem.rightBarButtonItem?.tintColor = .black
            sideMenu = SideMenuView(ingredients: ingredients)
            sideMenu?.delegate = self
        }
        scrollView.delegate = self
        pageControl.addTarget(self, action: #selector(pageDidChange), for: .valueChanged)
        layout()
    }
    
    @objc private func ingredientsButtonTapped() {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuLeadingConstraint?.constant = 0
            self.sideMenuTrailingConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func pageDidChange() {
        scrollView.setContentOffset(CGPoint(x: pageControl.currentPage * Int(view.frame.width), y: 0), animated: true)
    }
    
    private func layout() {
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        if let menu = sideMenu {
            view.addSubview(menu)
            NSLayoutConstraint.activate([
                menu.topAnchor.constraint(equalTo: view.topAnchor),
                menu.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            sideMenuTrailingConstraint = menu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIScreen.main.bounds.width)
            sideMenuLeadingConstraint = menu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIScreen.main.bounds.width)
            sideMenuLeadingConstraint?.isActive = true
            sideMenuTrailingConstraint?.isActive = true
        }
        scrollView.addSubview(stackViewContainer)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            stackViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            pageControl.heightAnchor.constraint(equalToConstant: 30),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 2)
        ])
        
        pagesHorizontal.forEach { [weak self] myView in
            guard let strongSelf = self else {
                return
            }
            strongSelf.stackViewContainer.addArrangedSubview(myView)
            NSLayoutConstraint.activate([
                myView.widthAnchor.constraint(equalTo: strongSelf.view.safeAreaLayoutGuide.widthAnchor),
                myView.heightAnchor.constraint(equalTo: strongSelf.view.safeAreaLayoutGuide.heightAnchor)
            ])
        }
    }
}

extension StepByStepViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for i in 0..<instructions.count {
            if scrollView.contentOffset.x == CGFloat(i) * view.frame.width {
                pageControl.currentPage = i
                title = instructions[i].name.isEmpty ? "Main Dish" : instructions[i].name
            }
        }
    }
}

extension StepByStepViewController: SideMenuDelegate {
    func hideMenu() {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuLeadingConstraint?.constant = UIScreen.main.bounds.width
            self.sideMenuTrailingConstraint?.constant = UIScreen.main.bounds.width
            self.view.layoutIfNeeded()
        }
    }
}
