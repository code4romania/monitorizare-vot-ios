//  Created by Code4Romania

import Foundation

protocol FormProvider {
    func getForm(named: String) -> Form?
}
