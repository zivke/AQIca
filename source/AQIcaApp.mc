import Toybox.Application;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class AQIcaApp extends Application.AppBase {
  private var _aqiData as AqiData;
  private var _timer as Timer.Timer;

  private var _fancyScroll as Boolean?;

  function initialize() {
    AppBase.initialize();

    self._aqiData = new AqiData();
    self._timer = new Timer.Timer();
    self._fancyScroll =
      Application.Properties.getValue("FancyScroll") as Boolean?;
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    _aqiData.load();

    if (_fancyScroll != null && _fancyScroll) {
      _timer.start(method(:requestUpdateViews), 500, true);
    }
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    _aqiData.destroy();
    _timer.stop();
  }

  // Return the initial view of your application here
  function getInitialView() {
    return [new AQIcaLoadingView(_aqiData)];
  }

  function requestUpdateViews() as Void {
    WatchUi.requestUpdate();
  }
}

function getApp() as AQIcaApp {
  return Application.getApp() as AQIcaApp;
}
