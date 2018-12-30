--
--  AppDelegate.applescript
--  nastask3
--
--  Created by Jonathan H Burgos S on 12/29/18.
--  Copyright © 2018 test. All rights reserved.
--

script AppDelegate
    
    property theWindow : missing value
	property parent : class "NSObject"
    property myTask : missing value
    
    property NSNotificationCenter : class "NSNotificationCenter"
    property NSPipe : class "NSPipe"
    property NSTask : class "NSTask"
    property NSString : class "NSString"
    property outputField : missing value
    property previousOutput : missing value
    
    
    on runCommand_(sender)
        
        set myTask to current application's NSTask's alloc()'s init()
        set outputPipe to current application's NSPipe's pipe()
        myTask's setStandardOutput_(outputPipe)
        myTask's setStandardError_(outputPipe)
        myTask's setLaunchPath_("/sbin/ping")
        myTask's setArguments_({"-c", "3", "www.icloud.com"})
        
        current application's NSNotificationCenter's defaultCenter()'s addObserver_selector_name_object_(me, "readPipe:", "NSFileHandleReadCompletionNotification", myTask's standardOutput()'s fileHandleForReading())
        
        current application's NSNotificationCenter's defaultCenter()'s addObserver_selector_name_object_(me, "endPipe:", "NSTaskDidTerminateNotification", myTask)
        myTask's standardOutput()'s fileHandleForReading()'s readInBackgroundAndNotify()
        myTask's |launch|()
        
    end runCommand_
    
    
    on readPipe_(aNotification)
        
        try
        set previousOutput to outputField's stringValue
        end try
        
        log "Pipe started"
        
        set dataString to aNotification's userInfo's objectForKey_("NSFileHandleNotificationDataItem")
        
        set newString to ((current application's NSString's alloc()'s initWithData_encoding_(dataString, current application's NSUTF8StringEncoding)))
        
        outputField's setStringValue:previousOutput  as string & newString as string

        aNotification's object()'s readInBackgroundAndNotify()
        
        log newString as string

    end readPipe_
    
    
    on endPipe_(aNotification)
        
        current application's NSNotificationCenter's defaultCenter()'s removeObserver_name_object_(me, "NSTaskDidTerminateNotification", myTask)
        current application's NSNotificationCenter's defaultCenter()'s removeObserver_name_object_(me, "NSFileHandleReadCompletionNotification", myTask's standardOutput()'s fileHandleForReading())
        log "Pipe finished"
        
    end endPipe_
    
    
    on applicationWillFinishLaunching_(aNotification)
        my runCommand_(me)
    end applicationWillFinishLaunching_
    
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_

end script
