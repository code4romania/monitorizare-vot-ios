//
//  ColorSchema.swift
//  MonitorizareVot
//
//  Created by Alex Ioja-Yang on 21/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

protocol ColorSchema {
    static var navigationBarBackground: UIColor { get }
    static var navigationBarTint: UIColor { get }

    static var appBackground: UIColor { get }
    static var headerBackground: UIColor { get }
    static var defaultText: UIColor { get }

    static var formNameText: UIColor { get }

    static var chooserButtonBorder: UIColor { get }
    static var chooserButtonBackground: UIColor { get }
    static var chooserButtonSelectedBackground: UIColor { get }

    static var actionButtonForeground: UIColor { get }
    static var actionButtonForegroundDisabled: UIColor { get }
    static var actionButtonBackground: UIColor { get }
    static var actionButtonBackgroundHighlighted: UIColor { get }
    static var actionButtonBackgroundDisabled: UIColor { get }

    static var attachButtonForeground: UIColor { get }
    static var attachButtonForegroundDisabled: UIColor { get }
    static var attachButtonBackground: UIColor { get }
    static var attachButtonBackgroundHighlighted: UIColor { get }

    static var cardBackground: UIColor { get }
    static var cardBackgroundSelected: UIColor { get }
    static var cardShadow: UIColor { get }
    static var cardDarkerShadow: UIColor { get }
    static var tableSectionHeaderBg: UIColor { get }

    static var textViewContainerBorder: UIColor { get }
    static var textViewContainerBg: UIColor { get }
}
