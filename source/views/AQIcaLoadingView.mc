import Toybox.Graphics;
import Toybox.WatchUi;

class AQIcaLoadingView extends WatchUi.View {
  private var _aqiData as AqiData;
  // private var _viewLoop as ViewLoop;

  function initialize(aqiData as AqiData) {
    self._aqiData = aqiData;
    // self._viewLoop = new ViewLoop(new AQIcaViewLoopFactory(_aqiData), null);

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.InfoLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    if (_aqiData.getStatus().getCode() == Status.DONE) {
      var viewLoop = new ViewLoop(new AQIcaViewLoopFactory(_aqiData), null);
      WatchUi.switchToView(
        viewLoop,
        new ViewLoopDelegate(viewLoop),
        WatchUi.SLIDE_IMMEDIATE
      );
    } else {
      var title;
      if (_aqiData.getStatus().hasError()) {
        title = "ERROR";
      } else {
        title = "INFO";
      }

      // Set the info title
      var infoTitleLabel = View.findDrawableById("InfoTitle") as Text?;
      if (infoTitleLabel != null) {
        infoTitleLabel.setText(title);
      }

      // Set the info text area value
      var infoTextArea = View.findDrawableById("InfoMessageValue") as TextArea?;
      if (infoTextArea != null) {
        infoTextArea.setText(_aqiData.getStatus().getMessage());
      }

      // Call the parent onUpdate function to redraw the layout
      View.onUpdate(dc);
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
