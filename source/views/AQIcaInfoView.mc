import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class AQIcaInfoView extends WatchUi.View {
  private var _title as String?;
  private var _message as String;

  function initialize(title as String?, message as String) {
    self._title = title;
    self._message = message;

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
    // Set the info title
    var infoTitleLabel = View.findDrawableById("InfoTitle") as Text?;
    if (infoTitleLabel != null && _title != null) {
      infoTitleLabel.setText(_title);
    }

    // Set the info text area value
    var infoTextArea = View.findDrawableById("InfoMessageValue") as TextArea?;
    if (infoTextArea != null) {
      infoTextArea.setText(_message);
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}
}
