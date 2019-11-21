//
//  ColorSchemaSelectionTests.swift
//  MonitorizareVotTests
//
//  Created by Alex Ioja-Yang on 21/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import XCTest
@testable import MonitorizareVot

class ColorSchemaSelectionTests: XCTestCase {
    
    override func tearDown() {
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .dark
        }
        super.tearDown()
    }
    
    func testLightInterfaceStyle() {
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .light
            XCTAssertTrue(UIColor.colorSchema is StandardColorSchema.Type)
        } else {
            XCTFail("Run tests on latest iOS version to ensure compatibility")
        }
    }
    
    func testDarkInterfaceStyle() {
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .dark
            XCTAssertTrue(UIColor.colorSchema is DarkModeColorSchema.Type)
        } else {
            XCTFail("Run tests on latest iOS version to ensure compatibility")
        }
    }
    
    func testUnspecifiedInterfaceStyle() {
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .unspecified
            XCTAssertTrue(UIColor.colorSchema is StandardColorSchema.Type)
        } else {
            XCTFail("Run tests on latest iOS version to ensure compatibility")
        }
    }
    
}
