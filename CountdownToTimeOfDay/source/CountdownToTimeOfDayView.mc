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
import Toybox.Math;

//! The main view for the timer application. This displays the
//! remaining time on the countdown timer
(:typecheck(disableBackgroundCheck))
class CountdownToTimeOfDayView extends WatchUi.View {
	
	var mainFont = null;
	var smallFont = null;
	var biggerFont = null;
	var biggestFont = null;
	var space = 2;
	
    private enum TimerKeys {
        TIMER_KEY_DURATION,
       
    }

    private const TIMER_DURATION_DEFAULT = (16 * 3600);

    private var _timerDuration as Number;
    
    private var _updateTimer as Timer.Timer;
    public var timeMode = 2;
    
    var modeIcon;

    //! Initialize variables for this view
    //! @param backgroundRan Contains background data if background ran
    public function initialize(backgroundRan as PersistableType?) {
    	
        View.initialize();
        
        for(var a = 0; a < Math.floor(Math.log(70,2)); a++) {
        	System.println(a);
        }
        
        modeIcon = WatchUi.loadResource(Rez.Drawables.ModeIcon);
        
		 var timerDuration = Storage.getValue(TIMER_KEY_DURATION);
            if (timerDuration instanceof Number) {
                _timerDuration = timerDuration;
            
            } else {
                _timerDuration = TIMER_DURATION_DEFAULT;
                
            }
		
        // Fetch the persisted values from storage
       
        // Create our timer object that is used to drive display updates
        _updateTimer = new Timer.Timer();
		
		_updateTimer.start(method(:requestUpdate), 1000, true);
		
        
    }
    
    function onLayout(dc) {
        System.println(dc.getHeight());
        if (dc.getHeight() > 260) {
       		mainFont = WatchUi.loadResource(Rez.Fonts.digital48Font);
       		biggerFont = WatchUi.loadResource(Rez.Fonts.digital70Font);
       		biggestFont = WatchUi.loadResource(Rez.Fonts.digital80Font);
       		smallFont = WatchUi.loadResource(Rez.Fonts.digital26Font);
       	} else if (dc.getHeight() > 240){
       		mainFont = WatchUi.loadResource(Rez.Fonts.digital54Font);
       		biggerFont = WatchUi.loadResource(Rez.Fonts.digital65Font);
       		biggestFont = WatchUi.loadResource(Rez.Fonts.digital70Font);
       		smallFont = WatchUi.loadResource(Rez.Fonts.digital22Font);
       	} else if (dc.getHeight() > 220){
       		mainFont = WatchUi.loadResource(Rez.Fonts.digital50Font);
       		smallFont = WatchUi.loadResource(Rez.Fonts.digital20Font);
       	} else if (dc.getHeight() > 210) {
       		mainFont = WatchUi.loadResource(Rez.Fonts.digital42Font);
       		smallFont = WatchUi.loadResource(Rez.Fonts.digital17Font);
       	} else {
       		mainFont = WatchUi.loadResource(Rez.Fonts.digital36Font);
       		biggerFont = WatchUi.loadResource(Rez.Fonts.digital60Font);
       		biggestFont = WatchUi.loadResource(Rez.Fonts.digital65Font);
       		smallFont = WatchUi.loadResource(Rez.Fonts.digital20Font);
      	}
    }
    
	public function onShow() as Void {
		
		
		var timerDuration = Storage.getValue(TIMER_KEY_DURATION);
        if (timerDuration instanceof Number) {
        	_timerDuration = timerDuration;
            
        } else {
            _timerDuration = TIMER_DURATION_DEFAULT;
           
        }
        
		
		
	}
	
	
    //! Draw the time remaining on the timer to the display
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
       
        var textColor = Graphics.COLOR_WHITE;
		var clockTime = System.getClockTime();
		var clockValue = clockTime.hour*3600 + clockTime.min*60 + clockTime.sec;
        
        

        if (clockValue == _timerDuration) {
                
                // Draw the time in red if the timer has expired
        	textColor = Graphics.COLOR_RED;
           
            
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
                var vibrateData =
                	[
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
 		var minuteFormat = "";
 		var secondFormat = "";
 		
       	if (hours < 2) {
	      	hourFormat = "$6$"; 
      	} else if (hours < 4) {
	  		hourFormat = "$5$$6$";
		} else if (hours < 8) {
	 		hourFormat = "$4$$5$$6$";
     	} else if (hours < 16) {
	 		hourFormat = "$3$$4$$5$$6$";
     	} else if (hours < 32) {
	 		hourFormat = "$2$$3$$4$$5$$6$";
       	} else {
	    	hourFormat = "$1$$2$$3$$4$$5$$6$";
       	}
    
    	var hourString = Lang.format(hourFormat,
        	[
        	hours / 32 % 2,
        	hours / 16 % 2,
        	hours / 8 % 2,
        	hours / 4 % 2,
        	hours / 2 % 2,
        	hours /1 % 2
        	]
        );
    	
		
		
        if (minutes < 2) {
	      	minuteFormat = "$6$"; 
      	} else if (minutes < 4) {
	  		minuteFormat = "$5$$6$";
		} else if (minutes < 8) {
	 		minuteFormat = "$4$$5$$6$";
     	} else if (minutes < 16) {
	 		minuteFormat = "$3$$4$$5$$6$";
     	} else if (minutes < 32) {
	 		minuteFormat = "$2$$3$$4$$5$$6$";
       	} else {
	    	minuteFormat = "$1$$2$$3$$4$$5$$6$";
       	}
        
		
        var minuteString = Lang.format(minuteFormat,
        	[
        	minutes / 32 % 2,
        	minutes / 16 % 2,
        	minutes / 8 % 2,
        	minutes / 4 % 2,
        	minutes / 2 % 2,
        	minutes /1 % 2
        	]
        ); 
        
		if (seconds < 2) {
	      	secondFormat = "$6$"; 
      	} else if (seconds < 4) {
	  		secondFormat = "$5$$6$";
		} else if (seconds < 8) {
	 		secondFormat = "$4$$5$$6$";
     	} else if (seconds < 16) {
	 		secondFormat = "$3$$4$$5$$6$";
     	} else if (seconds < 32) {
	 		secondFormat = "$2$$3$$4$$5$$6$";
       	} else {
	    	secondFormat = "$1$$2$$3$$4$$5$$6$";
       	}

        var secondsString = Lang.format(secondFormat,
        	[
        	seconds / 32 % 2,
        	seconds / 16 % 2,
        	seconds / 8 % 2,
        	seconds / 4 % 2,
        	seconds / 2 % 2,
        	seconds /1 % 2
        	]
        ); 
        
        var stats = System.getSystemStats();
        var pwr = (stats.battery + 0.5).toLong();
        var pwrString = pwr;
        
        var timeString = clockTime.hour + ":" + clockTime.min.format("%02d") + ":" + clockTime.sec.format("%02d");
        var countToString = _timerDuration / 3600 + ":" + (_timerDuration / 60 % 60).format("%02d") + ":" + (_timerDuration % 60).format("%02d");
        var timerString;
        
        if (timerValue < 60) {
        	timerString = seconds;
        } else if (timerValue < 3600) {
        	timerString = minutes + ":" + seconds.format("%02d");
        } else {
        	timerString = hours + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        }
        
		
		var timerFont = Graphics.FONT_NUMBER_MEDIUM;
		
		/*
		var min_x = dc.getWidth()/2;
       	var hour_x = min_x;
       	var sec_x = min_x;
       	var day_x = min_x;
       	var battery_x = min_x;
       	var min_y = dc.getHeight()/2 - dc.getFontHeight(mainFont)/2;
       	var hour_y = min_y - dc.getFontHeight(mainFont)-space;
       	var day_y = min_y + dc.getFontHeight(mainFont)+space;
       	var sec_y = day_y + dc.getFontHeight(mainFont)+space;
       	var battery_y = hour_y - dc.getFontHeight(smallFont)-space;
		*/
		
		
		
		var minY = dc.getHeight()/2;
        var secY = minY + dc.getFontHeight(mainFont)+space;
        var hourY = minY - dc.getFontHeight(mainFont)-space;
        var timeSetY = secY + dc.getFontHeight(mainFont)-dc.getFontHeight(smallFont)+space*4;
        var clockY = hourY - dc.getFontHeight(smallFont)*2;
        var finishedY = minY + dc.getFontHeight(mainFont) + dc.getFontHeight(smallFont);
        var pwrY = clockY - dc.getFontHeight(smallFont)-space;
		
		var stringArrayBinary = [timeString,hourString,minuteString,secondsString,countToString];
		var yPlacement = [clockY, hourY, minY, secY, timeSetY];
		var fontArray = [smallFont, mainFont, mainFont, mainFont, smallFont];
		var rest_width;
        var rest_height;
        var rectangle_width;
        var rectangle_height;
		
        dc.setColor(textColor, Graphics.COLOR_BLACK);
        dc.clear();
        
        
        
        if (timeMode == 0) {
        	for(var y=0; y<stringArrayBinary.size(); y++) {
        		dc.drawText(
            		dc.getWidth() / 2,
           			yPlacement[y],
            		fontArray[y],
            		stringArrayBinary[y],
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        		);
        	}	
        } else if (timeMode == 2) {
        	dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()*0.20,
            		smallFont,
            		timeString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        	);
        	
        	if (timerValue < 60) {
        		dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()/2,
            		biggestFont,
            		timerString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        		);
        	} else if (timerValue < 3600) {
        		dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()/2,
            		biggerFont,
            		timerString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        		);
        	} else {
        		dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()/2,
            		mainFont,
            		timerString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        		);
        	}
        	
        	
        	
        	dc.drawText(
            		dc.getWidth() / 2,
           			dc.getHeight()*0.80,
            		smallFont,
            		countToString,
            		Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        	);
        
        } else {
        	rest_width = (dc.getWidth() - 2) % 3;
       		if ((dc.getHeight() - 5) % 6 > 4) {
       			rest_height = 3;
       		} else if ((dc.getHeight() - 5) % 6 > 2) {
       			rest_height = 2;
       		} else {
       			rest_height = 1;
       		}
       		rectangle_width = (dc.getWidth()-2)/3 + rest_width;
       		rectangle_height = (dc.getHeight()-5)/6 + rest_height;
			
			
			
       		dc.setColor(textColor, Graphics.COLOR_BLACK);
       		//draw hourrectangles
    		for(var x = 0; x < 1; x ++) {
    			for(var y = 0; y < 6; y ++)	{
					dc.drawRectangle(x*(rectangle_width+1)-rest_width, y*(rectangle_height+1) - rest_height, rectangle_width, rectangle_height);
  				}
    		}
       		
       		//show hours
    		for(var i = 0; i < 5; i ++) {
    			if ( hours / (Math.pow(2,4-i).toLong()) % 2 == 1) {
    				dc.fillRectangle(-rest_width, (i+1)*(rectangle_height+1)-rest_height, rectangle_width, rectangle_height-1);
    			}
	    	}
    		
    		//draw minuterectangles
    		for(var x = 1; x < 2; x ++) {
    			for(var y = 0; y < 6; y ++)	{
					dc.drawRectangle(x*(rectangle_width+1)-rest_width, y*(rectangle_height+1) - rest_height, rectangle_width, rectangle_height);
  				}
    		}
    		//show minute
    		for(var i = 0; i < 6; i ++) {
    			if ( minutes / (Math.pow(2,5-i).toLong()) % 2 == 1) {
       				dc.fillRectangle(rectangle_width+1-rest_width, (i)*(rectangle_height+1)-rest_height, rectangle_width, rectangle_height-1);
    			}
    		}
    		
    		
    		//draw daterectangles
    		for(var x = 2; x < 3; x ++) {
    			for(var y = 0; y < 6; y ++)	{
					dc.drawRectangle(x*(rectangle_width+1)-rest_width, y*(rectangle_height+1) - rest_height, rectangle_width, rectangle_height);
  				}
    		}
    		
    		//show day
    		for(var i = 0; i < 6; i ++)	{
    			if ( seconds / (Math.pow(2,5-i).toLong()) % 2 == 1)	{
    				dc.fillRectangle(2*(rectangle_width+1)-rest_width, (i)*(rectangle_height+1)-rest_height, rectangle_width, rectangle_height-1);
    			}
    		}
        }
        
        
      //dc.drawBitmap(10, 165, modeIcon);
      
      	// draw battery
      	dc.setPenWidth(1);
        var rectangleWidth = dc.getWidth()*0.14;
        var batteryWidth = rectangleWidth * pwr / 100;
        var rectangleHeight = rectangleWidth*13/42;
        var rectangle_x = dc.getWidth()/2 - rectangleWidth/2;
        var rectangle_y = dc.getHeight()*0.02;
        var line_x1 = rectangle_x + rectangleWidth;
        var line_y1 = rectangle_y + rectangleHeight * 0.5; 
        var line_x2 = rectangle_x + rectangleWidth;
        var line_y2 = rectangle_y + rectangleHeight * 0.6;
        
        dc.drawRectangle(rectangle_x, rectangle_y, rectangleWidth, rectangleHeight);
       	dc.fillRectangle(rectangle_x + 2, rectangle_y + 2, batteryWidth - 4, rectangleHeight - 4);
       	dc.setPenWidth(4);
       	dc.drawLine(line_x1, line_y1, line_x2, line_y2);
    }
	
	public function binaryMode(timeMode) {
		if (timeMode < 2) {
			timeMode += 1;
		} else {
			timeMode = 0;
		}
		WatchUi.requestUpdate();
		return timeMode;
	}
	
	 public function resetTimer() as Boolean {
        
    }
    //! If the timer is running, pause it. Otherwise, start it up.
    public function startStopTimer() as Void {
        _updateTimer.start(method(:requestUpdate), 1000, true);
        
    }
    
    public function stopTimer() as Void {
	    _updateTimer.stop();
	    WatchUi.requestUpdate();
        
    }
    

    //! If the timer is paused, then go ahead and reset it back to the default time.
    //! @return true if timer is reset, false otherwise
    

    //! Save all the persisted values into the object store. This gets
    //! called by the Application base before the application shuts down.
    public function saveProperties() as Void {
        Storage.setValue(TIMER_KEY_DURATION, _timerDuration);
        
    }

    //! Set up a background event to occur when the timer expires. This
    //! will alert the user that the timer has expired even if the
    //! application does not remain open.
    public function setBackgroundEvent() as Void {
        
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
        
    }

    //! This is the callback method we use for our timer. It is
    //! only needed to request display updates as the timer counts
    //! down so we see the updated time on the display.
    public function requestUpdate() as Void {
        WatchUi.requestUpdate();
    }
}
