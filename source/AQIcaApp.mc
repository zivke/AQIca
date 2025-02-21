import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class AQIcaApp extends Application.AppBase {
  private var _aqiData as AqiData;

  function initialize() {
    AppBase.initialize();

    self._aqiData = new AqiData();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    _aqiData.load();
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    _aqiData.destroy();
  }

  // Return the initial view of your application here
  function getInitialView() {
    return [new AQIcaLoadingView(_aqiData)];
  }
}

function getApp() as AQIcaApp {
  return Application.getApp() as AQIcaApp;
}
