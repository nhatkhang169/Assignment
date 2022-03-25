//
//  ForecastCell.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import UIKit
import Kingfisher
import SwiftUI

class ForecastCell: UITableViewCell {
    static let identifier = "ForecastCell"
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pressureLabel.text = ""
        dateLabel.text = ""
        tempLabel.text = ""
        pressureLabel.text = ""
        humidityLabel.text = ""
        
        weatherIcon.image = nil
        weatherIcon.kf.cancelDownloadTask()
        
        loadingIndicatorView.isHidden = false
        loadingIndicatorView.startAnimating()
    }
    
    var viewModel: ForecastCellViewModelProtocol? = nil {
        didSet {
            fillData()
        }
    }
    
    private lazy var dateLabel: UILabel = {
        var view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tempLabel: UILabel = {
        var view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pressureLabel: UILabel = {
        var view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var humidityLabel: UILabel = {
        var view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var descLabel: UILabel = {
        var view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var weatherIcon: UIImageView = {
        var view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        var view = UIActivityIndicatorView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()
}

// MARK: - Private

extension ForecastCell {
    private func setupUI() {
        constraintDateLabel()
        constraintTempLabel()
        constraintPressureLabel()
        constraintHumidityLabel()
        constraintDescLabel()
        constraintWeatherIcon()
        constraintLoadingIndicator()
    }
    
    private func constraintDateLabel() {
        addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func constraintTempLabel() {
        addSubview(tempLabel)
        NSLayoutConstraint.activate([
            tempLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 0),
            tempLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            tempLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            tempLabel.heightAnchor.constraint(equalTo: dateLabel.heightAnchor)
        ])
    }
    
    private func constraintPressureLabel() {
        addSubview(pressureLabel)
        NSLayoutConstraint.activate([
            pressureLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 0),
            pressureLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            pressureLabel.heightAnchor.constraint(equalTo: dateLabel.heightAnchor)
        ])
    }
    
    private func constraintHumidityLabel() {
        addSubview(humidityLabel)
        NSLayoutConstraint.activate([
            humidityLabel.topAnchor.constraint(equalTo: pressureLabel.bottomAnchor, constant: 0),
            humidityLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            humidityLabel.trailingAnchor.constraint(equalTo: pressureLabel.trailingAnchor),
            humidityLabel.heightAnchor.constraint(equalTo: dateLabel.heightAnchor)
        ])
    }
    
    private func constraintDescLabel() {
        addSubview(descLabel)
        NSLayoutConstraint.activate([
            descLabel.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 0),
            descLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            descLabel.heightAnchor.constraint(equalTo: dateLabel.heightAnchor)
        ])
    }
    
    private func constraintWeatherIcon() {
        addSubview(weatherIcon)
        NSLayoutConstraint.activate([
            weatherIcon.centerYAnchor.constraint(equalTo: pressureLabel.centerYAnchor),
            weatherIcon.leadingAnchor.constraint(equalTo: pressureLabel.trailingAnchor),
            weatherIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            weatherIcon.heightAnchor.constraint(equalToConstant: 50),
            weatherIcon.widthAnchor.constraint(equalTo: weatherIcon.heightAnchor)
        ])
    }
    
    private func constraintLoadingIndicator() {
        addSubview(loadingIndicatorView)
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerYAnchor.constraint(equalTo: weatherIcon.centerYAnchor),
            loadingIndicatorView.centerXAnchor.constraint(equalTo: weatherIcon.centerXAnchor),
            loadingIndicatorView.widthAnchor.constraint(equalTo: weatherIcon.widthAnchor),
            loadingIndicatorView.heightAnchor.constraint(equalTo: weatherIcon.heightAnchor)
        ])
        bringSubviewToFront(weatherIcon)
    }
    
    private func fillData() {
        guard let model = viewModel else {
            return
        }
        
        dateLabel.text = model.dateText
        tempLabel.text = model.tempText
        pressureLabel.text = model.pressureText
        humidityLabel.text = model.humidityText
        descLabel.text = model.descText
        weatherIcon.kf.setImage(with: model.iconUrl) { [weak self] _ in
            self?.loadingIndicatorView.isHidden = true
        }
    }
    
    
}
