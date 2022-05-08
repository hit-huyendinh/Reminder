//
//  Poppins.swift
//  FontProvider
//
//  Created by Linh Nguyen Duc on 24/02/2022.
//

import UIKit

public final class Poppins {
    public static func boldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Bold", size: size)!
    }

    public static func mediumFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Medium", size: size)!
    }

    public static func regularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Regular", size: size)!
    }

    public static func semiboldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size)!
    }
}
