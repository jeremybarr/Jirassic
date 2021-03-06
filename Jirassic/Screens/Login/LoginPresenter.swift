//
//  LoginPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol LoginPresenterInput {
    
    func loginWithCredentials (credentials: UserCredentials)
    func cancelScreen()
}

protocol LoginPresenterOutput {
    
    func showLoadingIndicator (show: Bool)
}

class LoginPresenter {
    
    var userInterface: LoginPresenterOutput?
    var appWireframe: AppWireframe?
}

extension LoginPresenter: LoginPresenterInput {
    
    func loginWithCredentials (credentials: UserCredentials) {
        
        userInterface?.showLoadingIndicator(true)
        
        if let repository = remoteRepository {
            let login = UserInteractor(data: repository)
            login.onLoginSuccess = {
                self.userInterface?.showLoadingIndicator(false)
                self.appWireframe?.presentTasksController()
            }
            login.onLoginFailure = {
                self.userInterface?.showLoadingIndicator(false)
            }
            login.loginWithCredentials(credentials)
        }
    }
    
    func cancelScreen() {
        appWireframe?.presentTasksController()
    }
}