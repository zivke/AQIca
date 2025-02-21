import Toybox.WatchUi;

class AQIcaBehaviorDelegate extends WatchUi.BehaviorDelegate {
  private var _viewLoop as AQIcaViewLoop;

  function initialize(viewLoop as AQIcaViewLoop) {
    _viewLoop = viewLoop;

    BehaviorDelegate.initialize();
  }

  function onNextPage() {
    _viewLoop.nextView();
    return true;
  }

  function onPreviousPage() {
    _viewLoop.previousView();
    return true;
  }
}
