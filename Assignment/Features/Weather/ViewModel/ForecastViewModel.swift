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
    
    func itemAt(index: Int) -> DayWeather?
    func fetch7DayForecast(for city: String) -> Void
}

class ForecastViewModel: BaseViewModel {
    
    private let interactor: WeatherInteractor!
    private let startFetching7DayForecastSubject = PublishSubject<String>()
    private let didFetchForecastSubject = PublishSubject<Void>()
    
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
        startFetching7DayForecastSubject
            .throttle(RxTimeInterval(0.3), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] query -> Observable<[DayWeather]> in
                return self.interactor.getWeather(of: query, for: 7)
                    .catchError { _ in
                        return Observable.empty()
                    }
            }
            .do(onNext: { [unowned self] items in
                self.forecastList = items
                self.didFetchForecastSubject.onNext(())
            })
            .map { _ in Void() }
            .subscribe().disposed(by: disposeBag)
    }
}
