//
//  ViewController.swift
//  com.awareframework.ios.sensor.timezone
//
//  Created by tetujin on 11/20/2018.
//  Copyright (c) 2018 tetujin. All rights reserved.
//

import UIKit
import com_awareframework_ios_sensor_timezone

class ViewController: UIViewController {

    var sensor:TimezoneSensor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sensor = TimezoneSensor.init(TimezoneSensor.Config().apply{config in
            config.debug = true
            config.sensorObserver = Observer()
        })
        sensor?.start()
    }

    class Observer:TimezoneObserver{
        func onTimezoneChanged(data: TimezoneData) {
            print(data)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

