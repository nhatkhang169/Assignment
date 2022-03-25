//
//  ForecastViewModel.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import RxSwift

protocol ForecastViewModelProtocol {
    var onDidFetchForecast: Observable<Void> { get }
    var numberOfItems: Int { get }
    var onError: Observable<ApiError> { get }
    
    func itemAt(index: Int) -> DayWeather?
    func fetch7DayForecast(for city: String) -> Void
}

class ForecastViewModel: BaseViewModel {
    
    private let interactor: WeatherInteractor!
    private let startFetching7DayForecastSubject = PublishSubject<String>()
    private let didFetchForecastSubject = PublishSubject<Void>()
    private let didFetchErrorForecastSubject = PublishSubject<ApiError>()
    
    private var forecastList = [DayWeather]()
    
    init(interactor: WeatherInteractor) {
        self.interactor = interactor
        super.init()
        setupRx()
    }
}

// MARK - ForecastViewModelProtocol

extension ForecastViewModel: ForecastViewModelProtocol {
    
    var numberOfItems: Int {
        return forecastList.count
    }
    
    var onDidFetchForecast: Observable<Void> {
        return didFetchForecastSubject.asObservable()
    }
    
    var onError: Observable<ApiError> {
        return didFetchErrorForecastSubject.asObservable()
    }
    
    func itemAt(index: Int) -> DayWeather? {
        guard index < forecastList.count else {
            return nil
        }
        
        return forecastList[index]
    }
    
    func fetch7DayForecast(for city: String) -> Void {
        startFetching7DayForecastSubject.onNext(city)
    }
}

// MARK - Private

extension ForecastViewModel {
    
    private func setupRx() {
        disposeBag.addDisposables([
            startFetching7DayForecastSubject
                .throttle(RxTimeInterval(0.3), scheduler: MainScheduler.instance)
                .flatMapLatest { [unowned self] query -> Observable<[DayWeather]> in
                    return self.interactor.getWeather(of: query, for: 7)
                }
                .do(onNext: { [unowned self] items in
                    self.forecastList = items
                    self.didFetchForecastSubject.onNext(())
                })
                .map { _ in Void() }
                .subscribe(),
            
            interactor.onError
                .do(onNext: { [weak self] error in
                    self?.didFetchErrorForecastSubject.onNext(error)
                })
                .subscribe()
        ])
    }
}
