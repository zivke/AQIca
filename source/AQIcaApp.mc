import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class AQIcaApp extends Application.AppBase {
  private var _aqiData as AqiData?;
  private var _exception as AqiException?;

  function initialize() {
    AppBase.initialize();

    try {
      var apiToken = Properties.getValue("ApiKey") as String?;
      if (apiToken == null || apiToken.equals("")) {
        throw new FatalErrorException("API key is missing");
      }

      self._aqiData = new AqiData();
    } catch (exception) {
      System.println("Exception thrown: " + exception.getErrorMessage());
      self._aqiData = null;
      _exception = exception as AqiException;
    }
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    if (_aqiData != null) {
      try {
        _aqiData.load();
      } catch (exception) {
        System.println("Exception thrown: " + exception.getErrorMessage());
        _aqiData.destroy();
        _aqiData = null;
        _exception = exception as AqiException;
      }
    }
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    if (_aqiData != null) {
      _aqiData.destroy();
    }
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    if (_aqiData == null) {
      if (_exception != null) {
        return (
          [new AQIcaErrorView(_exception.getErrorMessage())] as
          Array<Views or InputDelegates>
        );
      } else {
        return (
          [new AQIcaErrorView("Unknown fatal error")] as
          Array<Views or InputDelegates>
        );
      }
    } else {
      return [new AQIcaView(_aqiData)] as Array<Views or InputDelegates>;
    }
  }
}

function getApp() as AQIcaApp {
  return Application.getApp() as AQIcaApp;
}
