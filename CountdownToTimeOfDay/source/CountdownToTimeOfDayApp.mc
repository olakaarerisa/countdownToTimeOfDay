import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;


class CountdownToTimeOfDayApp extends Application.AppBase {

    private var _timerView as CountdownToTimeOfDayView?;
    private var _backgroundData as Boolean?;

    //! Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
        var timerView = _timerView;
        if (timerView != null) {
            timerView.saveProperties();
            timerView.setBackgroundEvent();
        }
    }

    //! Handle data passed from a background service delegate to the app
    //! @param data The data passed from the background process
    public function onBackgroundData(data as Boolean?) as Void {
        var timerView = _timerView;
        if (timerView != null) {
            timerView.backgroundEvent();
        } else {
            _backgroundData = data;
        }
    }

    //! Return the initial view for the app
    //! @return Array Pair [View, Delegate]
    public function getInitialView() as Array<Views or InputDelegates>? {
        _timerView = new $.CountdownToTimeOfDayView(_backgroundData);
        var timerView = _timerView;
        if (timerView != null) {
            timerView.deleteBackgroundEvent();
            return [timerView, new $.CountdownToTimeOfDayDelegate(timerView)] as Array<Views or InputDelegates>?;
        }
        return null;
    }
//! Get service delegates to run background tasks for the app
    //! @return An array of service delegates to run background tasks
    public function getServiceDelegate() as Array<ServiceDelegate> {
        return [new $.CountdownToTimeOfDayServiceDelegate()] as Array<ServiceDelegate>;
    }

    //! Handle a storage update
    public function onStorageChanged() as Void {
        if (_timerView != null) {
            $.handleStorageUpdate();
        }
    }
}

(:typecheck(disableBackgroundCheck))
function handleStorageUpdate() as Void {
    WatchUi.pushView(new $.CountdownToTimeOfDayStorageChangedAlertView(), null, WatchUi.SLIDE_IMMEDIATE);
}