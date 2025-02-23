import Toybox.Lang;
import Toybox.WatchUi;

class AQIcaViewLoop {
  private var _views as Array<View>;
  private var _index as Number = 0;
  private var _delegate as AQIcaBehaviorDelegate;

  function initialize(views as Array<View>) {
    self._views = views;
    self._delegate = new AQIcaBehaviorDelegate(self);
  }

  public function show() {
    WatchUi.switchToView(_views[_index], _delegate, WatchUi.SLIDE_IMMEDIATE);
  }

  public function nextView() {
    _index = (_index + 1) % _views.size();
    show();
  }

  public function previousView() {
    _index = (_index - 1 + _views.size()) % _views.size();
    show();
  }
}
