//
//  CustomAnotation.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 2/9/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Cocoa
import MapKit



class CustomAnotation: MKAnnotationView {
    
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation:annotation, reuseIdentifier:reuseIdentifier)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder:aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    
 
}
