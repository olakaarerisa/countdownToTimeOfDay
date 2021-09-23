//
// Copyright 2017-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Attention;
import Toybox.Background;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

//! The main view for the timer application. This displays the
//! remaining time on the countdown timer
(:typecheck(disableBackgroundCheck))
class CountdownToTimeOfDayView extends WatchUi.View {

    private enum TimerKeys {
        TIMER_KEY_DURATION,
        TIMER_KEY_START_TIME,
        TIMER_KEY_PAUSE_TIME
    }

    private const TIMER_DURATION_DEFAULT = (16 * 3600);    // 5 minutes

    private var _timerDuration as Number;
    private var _timerStartTime as Number?;
    private var _timerPauseTime as Number?;
    private var _updateTimer as Timer.Timer;
    public var timeMode = true;

    //! Initialize variables for this view
    //! @param backgroundRan Contains background data if background ran
    public function initialize(backgroundRan as PersistableType?) {
    	
        View.initialize();
        

        // Fetch the persisted values from storage
        if (backgroundRan == null) {
        	
            var timerDuration = Storage.getValue(TIMER_KEY_DURATION);
            if (timerDuration instanceof Number) {
                _timerDuration = timerDuration;
            
            } else {
                _timerDuration = TIMER_DURATION_DEFAULT;
                
            }
            _timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
            _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
        } else {
            // If we got an expiration event from the background process
            // when we started up, reset the timer back to the default value.
            _timerDuration = TIMER_DURATION_DEFAULT;
            _timerStartTime = null;
            _timerPauseTime = null;
        }

        // Create our timer object that is used to drive display updates
        _updateTimer = new Timer.Timer();

        // If the timer is running, we need to start the timer up now.
        if ((_timerStartTime != null) && (_timerPauseTime == null)) {
            // Update the display each second.
            _updateTimer.start(method(:requestUpdate), 1000, true);
        }
    }
    
	public function onShow() as Void {
		
		
		var timerDuration = Storage.getValue(TIMER_KEY_DURATION);
        if (timerDuration instanceof Number) {
        	_timerDuration = timerDuration;
            
        } else {
            _timerDuration = TIMER_DURATION_DEFAULT;
           
        }
        
		_timerStartTime = Storage.getValue(TIMER_KEY_START_TIME);
        _timerPauseTime = Storage.getValue(TIMER_KEY_PAUSE_TIME);
		

        // Create our timer object that is used to drive display updates
        _updateTimer = new Timer.Timer();

        // If the timer is running, we need to start the timer up now.
        if ((_timerStartTime != null) && (_timerPauseTime == null)) {
            // Update the display each second.
            _updateTimer.start(method(:requestUpdate), 1000, true);
        }
		
	}
	
	
    //! Draw the time remaining on the timer to the display
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        var textColor = Graphics.COLOR_WHITE;
		var clockTime = System.getClockTime();
		var clockValue = clockTime.hour*3600 + clockTime.min*60 + clockTime.sec;
        
        var timerStartTime = _timerStartTime;
        if (timerStartTime != null) {
            var timerPauseTime = _timerPauseTime;
            if (timerPauseTime != null) {
                // Draw the time in yellow if the timer is paused
                textColor = Graphics.COLOR_YELLOW;
              
            }

            if (clockValue == _timerDuration) {
                
                // Draw the time in red if the timer has expired
                textColor = Graphics.COLOR_RED;
                _timerPauseTime = Time.now().value();
                _updateTimer.stop();
                if (Attention has :ToneProfile) {
    				var toneProfile =
    				[
        				new Attention.ToneProfile( 2500, 250),
        				new Attention.ToneProfile( 5000, 250),
        				new Attention.ToneProfile(10000, 250),
        				new Attention.ToneProfile( 5000, 250),
        				new Attention.ToneProfile( 2500, 250),
    				];
    				Attention.playTone({:toneProfile=>toneProfile});
				}
				
				if (Attention has :vibrate) {
                var vibrateData = [
                        new Attention.VibeProfile(25, 100),
                        new Attention.VibeProfile(50, 100),
                        new Attention.VibeProfile(75, 100),
                        new Attention.VibeProfile(100, 100),
                        new Attention.VibeProfile(75, 100),
                        new Attention.VibeProfile(50, 100),
                        new Attention.VibeProfile(25, 100)
                      ] as Array<VibeProfile>;

                Attention.vibrate(vibrateData);
                
                }
            }
        }
		
		
     
		
		
		var timerValue;
		
		if (_timerDuration - clockValue < 0) {
			timerValue = _timerDuration - clockValue + 86400;
		} else {
			timerValue = _timerDuration - clockValue;
		}
		 
		
        var seconds = timerValue % 60;
        var minutes = timerValue / 60 % 60;
        var hours = timerValue / 3600;
        
        var formatArray = ["","",""];
        var formatLength = [5,6,6];
        
        
        // make formats for hour, minute and seconds
        for(var a = 0; a < formatArray.size(); a++) {
        	for(var b = 0; b<formatLength[a]; b++) {
        		formatArray[a] += "$";
        		formatArray[a] += b+1;
        		formatArray[a] += "$";
        	} 
        }
        
        
 
        var hourFormat = "";
        
        for(var y = 0; y < 5; y ++) {
        	hourFormat += "$";
        	hourFormat += y+1;
        	hourFormat += "$";
        }
        
    

        var hourString = Lang.format(formatArray[0],
        	[
        	hours / 16 % 2,
        	hours / 8 % 2,
        	hours / 4 % 2,
        	hours / 2 % 2,
        	hours /1 % 2
        	]
        ); 
        


        var minuteString = Lang.format(formatArray[1],
        	[
        	minutes / 32 % 2,
        	minutes / 16 % 2,
        	minutes / 8 % 2,
        	minutes / 4 % 2,
        	minutes / 2 % 2,
        	minutes /1 % 2
        	]
        ); 
        


        var secondsString = Lang.format(formatArray[2],
        	[
        	seconds / 32 % 2,
        	seconds / 16 % 2,
        	seconds / 8 % 2,
        	seconds / 4 % 2,
        	seconds / 2 % 2,
        	seconds /1 % 2
        	]
        ); 
        
        var timeString = clockTime.hour + ":" + clockTime.min.format("%02d") + ":" + clockTime.sec.format("%02d");
        var countToString = _timerDuration / 3600 + ":" + (_timerDuration / 60 % 60).format("%02d") + ":" + (_timerDuration % 60).format("%02d");
        var timerString = hours + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
		
		var timerFont = Graphics.FONT_NUMBER_MEDIUM;
		
		var stringArrayBinary = [timeString,hourString,minuteString,secondsString,countToString];
		var yPlacement = [dc.getHeight()*0.10, dc.getHeight()*0.28, dc.getHeight()*0.5, dc.getHeight()*0.72, dc.getHeight()*0.90];
		var fontArray = [Graphics.FONT_TINY, timerFont, timerFont, timerFont, Graphics.FONT_TINY];
		
        dc.setColor(textColor, Graphics.COLOR_BLACK);
        dc.clear();
        
        if (timeMode == true) {
        	for(var y=0; y<stringArrayBinary.size(); y++) {
        		dc.drawText(
            		dc.getWidth() / 2,
           			yPlacement[y],
            		fontArray[y],
            		stringArrayBinary[y],
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        		);
        	}	
        } else {
        	dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()*0.10,
            		Graphics.FONT_TINY,
            		timeString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        	);
        	
        	dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()/2,
            		timerFont,
            		timerString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        	);
        	
        	dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()*0.90,
            		Graphics.FONT_TINY,
            		countToString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        	);
        
        }
        
        
     
    }
	
	public function binaryMode(timeMode) {
		if (timeMode == true) {
			timeMode = false;
			System.println("binmode off");
		} else {
			timeMode = true;
			System.println("binmode on");
		}
		
		return timeMode;
	}
	
	
    //! If the timer is running, pause it. Otherwise, start it up.
    public function startStopTimer() as Void {
        var now = Time.now().value();

        var timerStartTime = _timerStartTime;
        if (timerStartTime == null) {
            _timerStartTime = now;
            _updateTimer.start(method(:requestUpdate), 1000, true);
        } else {
            var timerPauseTime = _timerPauseTime;
            if (timerPauseTime == null) {
                _timerPauseTime = now;
                _updateTimer.stop();
                WatchUi.requestUpdate();
            } else {
                if ((timerPauseTime - timerStartTime) < _timerDuration) {
                    _timerStartTime = timerStartTime + (now - timerPauseTime);
                    _timerPauseTime = null;
                    _updateTimer.start(method(:requestUpdate), 1000, true);
                }
            }
        }
    }
    
    public function stopTimer() as Void {
	    _updateTimer.stop();
	    WatchUi.requestUpdate();
        
    }
    

    //! If the timer is paused, then go ahead and reset it back to the default time.
    //! @return true if timer is reset, false otherwise
    public function resetTimer() as Boolean {
        if (_timerPauseTime != null) {
            _timerStartTime = null;
            _timerPauseTime = null;
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    //! Save all the persisted values into the object store. This gets
    //! called by the Application base before the application shuts down.
    public function saveProperties() as Void {
        Storage.setValue(TIMER_KEY_DURATION, _timerDuration);
        Storage.setValue(TIMER_KEY_START_TIME, _timerStartTime);
        Storage.setValue(TIMER_KEY_PAUSE_TIME, _timerPauseTime);
    }

    //! Set up a background event to occur when the timer expires. This
    //! will alert the user that the timer has expired even if the
    //! application does not remain open.
    public function setBackgroundEvent() as Void {
        var timerStartTime = _timerStartTime;
        if ((timerStartTime != null) && (_timerPauseTime == null)) {
            var time = new Time.Moment(timerStartTime);
            time = time.add(new Time.Duration(_timerDuration));
            try {
                var info = Time.Gregorian.info(time, Time.FORMAT_SHORT);
                Background.registerForTemporalEvent(time);
            } catch (e instanceof Background.InvalidBackgroundTimeException) {
                // We shouldn't get here because our timer is 5 minutes, which
                // matches the minimum background time. If we do get here,
                // then it is not possible to set an event at the time when
                // the timer is going to expire because we ran too recently.
            }
        }
    }

    //! Delete the background event. We can get rid of this event when the
    //! application opens because now we can see exactly when the timer
    //! is going to expire. We will set it again when the application closes.
    public function deleteBackgroundEvent() as Void {
        Background.deleteTemporalEvent();
    }

    //! If we do receive a background event while the application is open,
    //! go ahead and reset to the default timer.
    public function backgroundEvent() as Void {
        _timerDuration = TIMER_DURATION_DEFAULT;
        _timerStartTime = null;
        _timerPauseTime = null;
        WatchUi.requestUpdate();
    }

    //! This is the callback method we use for our timer. It is
    //! only needed to request display updates as the timer counts
    //! down so we see the updated time on the display.
    public function requestUpdate() as Void {
        WatchUi.requestUpdate();
    }
}
