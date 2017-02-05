package X11::Xlib::XEvent;
use strict;
use warnings;

# ----------------------------------------------------------------------------
# BEGIN GENERATED X11_Xlib_XEvent


*get_window ||= *_get_window;
*set_window ||= *_set_window;
sub window { $_[0]->set_window($_[1]) if @_ > 1; $_[0]->get_window() }

*get_display ||= *_get_display;
*set_display ||= *_set_display;
sub display { $_[0]->set_display($_[1]) if @_ > 1; $_[0]->get_display() }

*get_serial ||= *_get_serial;
*set_serial ||= *_set_serial;
sub serial { $_[0]->set_serial($_[1]) if @_ > 1; $_[0]->get_serial() }

*get_type ||= *_get_type;
*set_type ||= *_set_type;
sub type { $_[0]->set_type($_[1]) if @_ > 1; $_[0]->get_type() }

*get_send_event ||= *_get_send_event;
*set_send_event ||= *_set_send_event;
sub send_event { $_[0]->set_send_event($_[1]) if @_ > 1; $_[0]->get_send_event() }
our %_type_to_class= {
  X11::Xlib::ButtonPress() => "X11::Xlib::XEvent::XButtonEvent",
  X11::Xlib::ButtonRelease() => "X11::Xlib::XEvent::XButtonEvent",
  X11::Xlib::CirculateNotify() => "X11::Xlib::XEvent::XCirculateEvent",
  X11::Xlib::ClientMessage() => "X11::Xlib::XEvent::XClientMessageEvent",
  X11::Xlib::ColormapNotify() => "X11::Xlib::XEvent::XColormapEvent",
  X11::Xlib::ConfigureNotify() => "X11::Xlib::XEvent::XConfigureEvent",
  X11::Xlib::CreateNotify() => "X11::Xlib::XEvent::XCreateWindowEvent",
  X11::Xlib::LeaveNotify() => "X11::Xlib::XEvent::XCrossingEvent",
  X11::Xlib::EnterNotify() => "X11::Xlib::XEvent::XCrossingEvent",
  X11::Xlib::DestroyNotify() => "X11::Xlib::XEvent::XDestroyWindowEvent",
  X11::Xlib::Expose() => "X11::Xlib::XEvent::XExposeEvent",
  X11::Xlib::FocusOut() => "X11::Xlib::XEvent::XFocusChangeEvent",
  X11::Xlib::FocusIn() => "X11::Xlib::XEvent::XFocusChangeEvent",
  X11::Xlib::GraphicsExpose() => "X11::Xlib::XEvent::XGraphicsExposeEvent",
  X11::Xlib::GravityNotify() => "X11::Xlib::XEvent::XGravityEvent",
  X11::Xlib::KeyRelease() => "X11::Xlib::XEvent::XKeyEvent",
  X11::Xlib::KeyPress() => "X11::Xlib::XEvent::XKeyEvent",
  X11::Xlib::KeymapNotify() => "X11::Xlib::XEvent::XKeymapEvent",
  X11::Xlib::MapNotify() => "X11::Xlib::XEvent::XMapEvent",
  X11::Xlib::MappingNotify() => "X11::Xlib::XEvent::XMappingEvent",
  X11::Xlib::MotionNotify() => "X11::Xlib::XEvent::XMotionEvent",
  X11::Xlib::NoExpose() => "X11::Xlib::XEvent::XNoExposeEvent",
  X11::Xlib::PropertyNotify() => "X11::Xlib::XEvent::XPropertyEvent",
  X11::Xlib::ReparentNotify() => "X11::Xlib::XEvent::XReparentEvent",
  X11::Xlib::ResizeRequest() => "X11::Xlib::XEvent::XResizeRequestEvent",
  X11::Xlib::SelectionClear() => "X11::Xlib::XEvent::XSelectionClearEvent",
  X11::Xlib::SelectionNotify() => "X11::Xlib::XEvent::XSelectionEvent",
  X11::Xlib::SelectionRequest() => "X11::Xlib::XEvent::XSelectionRequestEvent",
  X11::Xlib::UnmapNotify() => "X11::Xlib::XEvent::XUnmapEvent",
  X11::Xlib::VisibilityNotify() => "X11::Xlib::XEvent::XVisibilityEvent",
}

package X11::Xlib::XEvent::XAnyEvent;
our @ISA= 'X11::Xlib::XEvent';

package X11::Xlib::XEvent::XButtonEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_button ||= *X11::Xlib::XEvent::_get_button;
*set_button ||= *X11::Xlib::XEvent::_set_button;
sub button { $_[0]->set_button($_[1]) if @_ > 1; $_[0]->get_button() }
*get_root ||= *X11::Xlib::XEvent::_get_root;
*set_root ||= *X11::Xlib::XEvent::_set_root;
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen ||= *X11::Xlib::XEvent::_get_same_screen;
*set_same_screen ||= *X11::Xlib::XEvent::_set_same_screen;
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state ||= *X11::Xlib::XEvent::_get_state;
*set_state ||= *X11::Xlib::XEvent::_set_state;
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow ||= *X11::Xlib::XEvent::_get_subwindow;
*set_subwindow ||= *X11::Xlib::XEvent::_set_subwindow;
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root ||= *X11::Xlib::XEvent::_get_x_root;
*set_x_root ||= *X11::Xlib::XEvent::_set_x_root;
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root ||= *X11::Xlib::XEvent::_get_y_root;
*set_y_root ||= *X11::Xlib::XEvent::_set_y_root;
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XCirculateEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_event ||= *X11::Xlib::XEvent::_get_event;
*set_event ||= *X11::Xlib::XEvent::_set_event;
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_place ||= *X11::Xlib::XEvent::_get_place;
*set_place ||= *X11::Xlib::XEvent::_set_place;
sub place { $_[0]->set_place($_[1]) if @_ > 1; $_[0]->get_place() }

package X11::Xlib::XEvent::XCirculateRequestEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_parent ||= *X11::Xlib::XEvent::_get_parent;
*set_parent ||= *X11::Xlib::XEvent::_set_parent;
sub parent { $_[0]->set_parent($_[1]) if @_ > 1; $_[0]->get_parent() }
*get_place ||= *X11::Xlib::XEvent::_get_place;
*set_place ||= *X11::Xlib::XEvent::_set_place;
sub place { $_[0]->set_place($_[1]) if @_ > 1; $_[0]->get_place() }

package X11::Xlib::XEvent::XClientMessageEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_b ||= *X11::Xlib::XEvent::_get_b;
*set_b ||= *X11::Xlib::XEvent::_set_b;
sub b { $_[0]->set_b($_[1]) if @_ > 1; $_[0]->get_b() }
*get_l ||= *X11::Xlib::XEvent::_get_l;
*set_l ||= *X11::Xlib::XEvent::_set_l;
sub l { $_[0]->set_l($_[1]) if @_ > 1; $_[0]->get_l() }
*get_s ||= *X11::Xlib::XEvent::_get_s;
*set_s ||= *X11::Xlib::XEvent::_set_s;
sub s { $_[0]->set_s($_[1]) if @_ > 1; $_[0]->get_s() }
*get_format ||= *X11::Xlib::XEvent::_get_format;
*set_format ||= *X11::Xlib::XEvent::_set_format;
sub format { $_[0]->set_format($_[1]) if @_ > 1; $_[0]->get_format() }
*get_message_type ||= *X11::Xlib::XEvent::_get_message_type;
*set_message_type ||= *X11::Xlib::XEvent::_set_message_type;
sub message_type { $_[0]->set_message_type($_[1]) if @_ > 1; $_[0]->get_message_type() }

package X11::Xlib::XEvent::XColormapEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_colormap ||= *X11::Xlib::XEvent::_get_colormap;
*set_colormap ||= *X11::Xlib::XEvent::_set_colormap;
sub colormap { $_[0]->set_colormap($_[1]) if @_ > 1; $_[0]->get_colormap() }
*get_new ||= *X11::Xlib::XEvent::_get_new;
*set_new ||= *X11::Xlib::XEvent::_set_new;
sub new { $_[0]->set_new($_[1]) if @_ > 1; $_[0]->get_new() }
*get_state ||= *X11::Xlib::XEvent::_get_state;
*set_state ||= *X11::Xlib::XEvent::_set_state;
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }

package X11::Xlib::XEvent::XConfigureEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_above ||= *X11::Xlib::XEvent::_get_above;
*set_above ||= *X11::Xlib::XEvent::_set_above;
sub above { $_[0]->set_above($_[1]) if @_ > 1; $_[0]->get_above() }
*get_border_width ||= *X11::Xlib::XEvent::_get_border_width;
*set_border_width ||= *X11::Xlib::XEvent::_set_border_width;
sub border_width { $_[0]->set_border_width($_[1]) if @_ > 1; $_[0]->get_border_width() }
*get_event ||= *X11::Xlib::XEvent::_get_event;
*set_event ||= *X11::Xlib::XEvent::_set_event;
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_height ||= *X11::Xlib::XEvent::_get_height;
*set_height ||= *X11::Xlib::XEvent::_set_height;
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_override_redirect ||= *X11::Xlib::XEvent::_get_override_redirect;
*set_override_redirect ||= *X11::Xlib::XEvent::_set_override_redirect;
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }
*get_width ||= *X11::Xlib::XEvent::_get_width;
*set_width ||= *X11::Xlib::XEvent::_set_width;
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XConfigureRequestEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_above ||= *X11::Xlib::XEvent::_get_above;
*set_above ||= *X11::Xlib::XEvent::_set_above;
sub above { $_[0]->set_above($_[1]) if @_ > 1; $_[0]->get_above() }
*get_border_width ||= *X11::Xlib::XEvent::_get_border_width;
*set_border_width ||= *X11::Xlib::XEvent::_set_border_width;
sub border_width { $_[0]->set_border_width($_[1]) if @_ > 1; $_[0]->get_border_width() }
*get_detail ||= *X11::Xlib::XEvent::_get_detail;
*set_detail ||= *X11::Xlib::XEvent::_set_detail;
sub detail { $_[0]->set_detail($_[1]) if @_ > 1; $_[0]->get_detail() }
*get_height ||= *X11::Xlib::XEvent::_get_height;
*set_height ||= *X11::Xlib::XEvent::_set_height;
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_parent ||= *X11::Xlib::XEvent::_get_parent;
*set_parent ||= *X11::Xlib::XEvent::_set_parent;
sub parent { $_[0]->set_parent($_[1]) if @_ > 1; $_[0]->get_parent() }
*get_value_mask ||= *X11::Xlib::XEvent::_get_value_mask;
*set_value_mask ||= *X11::Xlib::XEvent::_set_value_mask;
sub value_mask { $_[0]->set_value_mask($_[1]) if @_ > 1; $_[0]->get_value_mask() }
*get_width ||= *X11::Xlib::XEvent::_get_width;
*set_width ||= *X11::Xlib::XEvent::_set_width;
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XCreateWindowEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_border_width ||= *X11::Xlib::XEvent::_get_border_width;
*set_border_width ||= *X11::Xlib::XEvent::_set_border_width;
sub border_width { $_[0]->set_border_width($_[1]) if @_ > 1; $_[0]->get_border_width() }
*get_height ||= *X11::Xlib::XEvent::_get_height;
*set_height ||= *X11::Xlib::XEvent::_set_height;
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_override_redirect ||= *X11::Xlib::XEvent::_get_override_redirect;
*set_override_redirect ||= *X11::Xlib::XEvent::_set_override_redirect;
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }
*get_parent ||= *X11::Xlib::XEvent::_get_parent;
*set_parent ||= *X11::Xlib::XEvent::_set_parent;
sub parent { $_[0]->set_parent($_[1]) if @_ > 1; $_[0]->get_parent() }
*get_width ||= *X11::Xlib::XEvent::_get_width;
*set_width ||= *X11::Xlib::XEvent::_set_width;
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XCrossingEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_detail ||= *X11::Xlib::XEvent::_get_detail;
*set_detail ||= *X11::Xlib::XEvent::_set_detail;
sub detail { $_[0]->set_detail($_[1]) if @_ > 1; $_[0]->get_detail() }
*get_focus ||= *X11::Xlib::XEvent::_get_focus;
*set_focus ||= *X11::Xlib::XEvent::_set_focus;
sub focus { $_[0]->set_focus($_[1]) if @_ > 1; $_[0]->get_focus() }
*get_mode ||= *X11::Xlib::XEvent::_get_mode;
*set_mode ||= *X11::Xlib::XEvent::_set_mode;
sub mode { $_[0]->set_mode($_[1]) if @_ > 1; $_[0]->get_mode() }
*get_root ||= *X11::Xlib::XEvent::_get_root;
*set_root ||= *X11::Xlib::XEvent::_set_root;
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen ||= *X11::Xlib::XEvent::_get_same_screen;
*set_same_screen ||= *X11::Xlib::XEvent::_set_same_screen;
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state ||= *X11::Xlib::XEvent::_get_state;
*set_state ||= *X11::Xlib::XEvent::_set_state;
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow ||= *X11::Xlib::XEvent::_get_subwindow;
*set_subwindow ||= *X11::Xlib::XEvent::_set_subwindow;
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root ||= *X11::Xlib::XEvent::_get_x_root;
*set_x_root ||= *X11::Xlib::XEvent::_set_x_root;
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root ||= *X11::Xlib::XEvent::_get_y_root;
*set_y_root ||= *X11::Xlib::XEvent::_set_y_root;
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XDestroyWindowEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_event ||= *X11::Xlib::XEvent::_get_event;
*set_event ||= *X11::Xlib::XEvent::_set_event;
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }

package X11::Xlib::XEvent::XExposeEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_count ||= *X11::Xlib::XEvent::_get_count;
*set_count ||= *X11::Xlib::XEvent::_set_count;
sub count { $_[0]->set_count($_[1]) if @_ > 1; $_[0]->get_count() }
*get_height ||= *X11::Xlib::XEvent::_get_height;
*set_height ||= *X11::Xlib::XEvent::_set_height;
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_width ||= *X11::Xlib::XEvent::_get_width;
*set_width ||= *X11::Xlib::XEvent::_set_width;
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XFocusChangeEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_detail ||= *X11::Xlib::XEvent::_get_detail;
*set_detail ||= *X11::Xlib::XEvent::_set_detail;
sub detail { $_[0]->set_detail($_[1]) if @_ > 1; $_[0]->get_detail() }
*get_mode ||= *X11::Xlib::XEvent::_get_mode;
*set_mode ||= *X11::Xlib::XEvent::_set_mode;
sub mode { $_[0]->set_mode($_[1]) if @_ > 1; $_[0]->get_mode() }

package X11::Xlib::XEvent::XGenericEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_evtype ||= *X11::Xlib::XEvent::_get_evtype;
*set_evtype ||= *X11::Xlib::XEvent::_set_evtype;
sub evtype { $_[0]->set_evtype($_[1]) if @_ > 1; $_[0]->get_evtype() }
*get_extension ||= *X11::Xlib::XEvent::_get_extension;
*set_extension ||= *X11::Xlib::XEvent::_set_extension;
sub extension { $_[0]->set_extension($_[1]) if @_ > 1; $_[0]->get_extension() }

package X11::Xlib::XEvent::XGenericEventCookie;
our @ISA= 'X11::Xlib::XEvent';
*get_cookie ||= *X11::Xlib::XEvent::_get_cookie;
*set_cookie ||= *X11::Xlib::XEvent::_set_cookie;
sub cookie { $_[0]->set_cookie($_[1]) if @_ > 1; $_[0]->get_cookie() }
*get_evtype ||= *X11::Xlib::XEvent::_get_evtype;
*set_evtype ||= *X11::Xlib::XEvent::_set_evtype;
sub evtype { $_[0]->set_evtype($_[1]) if @_ > 1; $_[0]->get_evtype() }
*get_extension ||= *X11::Xlib::XEvent::_get_extension;
*set_extension ||= *X11::Xlib::XEvent::_set_extension;
sub extension { $_[0]->set_extension($_[1]) if @_ > 1; $_[0]->get_extension() }

package X11::Xlib::XEvent::XGraphicsExposeEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_count ||= *X11::Xlib::XEvent::_get_count;
*set_count ||= *X11::Xlib::XEvent::_set_count;
sub count { $_[0]->set_count($_[1]) if @_ > 1; $_[0]->get_count() }
*get_drawable ||= *X11::Xlib::XEvent::_get_drawable;
*set_drawable ||= *X11::Xlib::XEvent::_set_drawable;
sub drawable { $_[0]->set_drawable($_[1]) if @_ > 1; $_[0]->get_drawable() }
*get_height ||= *X11::Xlib::XEvent::_get_height;
*set_height ||= *X11::Xlib::XEvent::_set_height;
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_major_code ||= *X11::Xlib::XEvent::_get_major_code;
*set_major_code ||= *X11::Xlib::XEvent::_set_major_code;
sub major_code { $_[0]->set_major_code($_[1]) if @_ > 1; $_[0]->get_major_code() }
*get_minor_code ||= *X11::Xlib::XEvent::_get_minor_code;
*set_minor_code ||= *X11::Xlib::XEvent::_set_minor_code;
sub minor_code { $_[0]->set_minor_code($_[1]) if @_ > 1; $_[0]->get_minor_code() }
*get_width ||= *X11::Xlib::XEvent::_get_width;
*set_width ||= *X11::Xlib::XEvent::_set_width;
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XGravityEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_event ||= *X11::Xlib::XEvent::_get_event;
*set_event ||= *X11::Xlib::XEvent::_set_event;
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XKeyEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_keycode ||= *X11::Xlib::XEvent::_get_keycode;
*set_keycode ||= *X11::Xlib::XEvent::_set_keycode;
sub keycode { $_[0]->set_keycode($_[1]) if @_ > 1; $_[0]->get_keycode() }
*get_root ||= *X11::Xlib::XEvent::_get_root;
*set_root ||= *X11::Xlib::XEvent::_set_root;
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen ||= *X11::Xlib::XEvent::_get_same_screen;
*set_same_screen ||= *X11::Xlib::XEvent::_set_same_screen;
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state ||= *X11::Xlib::XEvent::_get_state;
*set_state ||= *X11::Xlib::XEvent::_set_state;
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow ||= *X11::Xlib::XEvent::_get_subwindow;
*set_subwindow ||= *X11::Xlib::XEvent::_set_subwindow;
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root ||= *X11::Xlib::XEvent::_get_x_root;
*set_x_root ||= *X11::Xlib::XEvent::_set_x_root;
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root ||= *X11::Xlib::XEvent::_get_y_root;
*set_y_root ||= *X11::Xlib::XEvent::_set_y_root;
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XKeymapEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_key_vector ||= *X11::Xlib::XEvent::_get_key_vector;
*set_key_vector ||= *X11::Xlib::XEvent::_set_key_vector;
sub key_vector { $_[0]->set_key_vector($_[1]) if @_ > 1; $_[0]->get_key_vector() }

package X11::Xlib::XEvent::XMapEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_event ||= *X11::Xlib::XEvent::_get_event;
*set_event ||= *X11::Xlib::XEvent::_set_event;
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_override_redirect ||= *X11::Xlib::XEvent::_get_override_redirect;
*set_override_redirect ||= *X11::Xlib::XEvent::_set_override_redirect;
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }

package X11::Xlib::XEvent::XMapRequestEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_parent ||= *X11::Xlib::XEvent::_get_parent;
*set_parent ||= *X11::Xlib::XEvent::_set_parent;
sub parent { $_[0]->set_parent($_[1]) if @_ > 1; $_[0]->get_parent() }

package X11::Xlib::XEvent::XMappingEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_count ||= *X11::Xlib::XEvent::_get_count;
*set_count ||= *X11::Xlib::XEvent::_set_count;
sub count { $_[0]->set_count($_[1]) if @_ > 1; $_[0]->get_count() }
*get_first_keycode ||= *X11::Xlib::XEvent::_get_first_keycode;
*set_first_keycode ||= *X11::Xlib::XEvent::_set_first_keycode;
sub first_keycode { $_[0]->set_first_keycode($_[1]) if @_ > 1; $_[0]->get_first_keycode() }
*get_request ||= *X11::Xlib::XEvent::_get_request;
*set_request ||= *X11::Xlib::XEvent::_set_request;
sub request { $_[0]->set_request($_[1]) if @_ > 1; $_[0]->get_request() }

package X11::Xlib::XEvent::XMotionEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_is_hint ||= *X11::Xlib::XEvent::_get_is_hint;
*set_is_hint ||= *X11::Xlib::XEvent::_set_is_hint;
sub is_hint { $_[0]->set_is_hint($_[1]) if @_ > 1; $_[0]->get_is_hint() }
*get_root ||= *X11::Xlib::XEvent::_get_root;
*set_root ||= *X11::Xlib::XEvent::_set_root;
sub root { $_[0]->set_root($_[1]) if @_ > 1; $_[0]->get_root() }
*get_same_screen ||= *X11::Xlib::XEvent::_get_same_screen;
*set_same_screen ||= *X11::Xlib::XEvent::_set_same_screen;
sub same_screen { $_[0]->set_same_screen($_[1]) if @_ > 1; $_[0]->get_same_screen() }
*get_state ||= *X11::Xlib::XEvent::_get_state;
*set_state ||= *X11::Xlib::XEvent::_set_state;
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_subwindow ||= *X11::Xlib::XEvent::_get_subwindow;
*set_subwindow ||= *X11::Xlib::XEvent::_set_subwindow;
sub subwindow { $_[0]->set_subwindow($_[1]) if @_ > 1; $_[0]->get_subwindow() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_x_root ||= *X11::Xlib::XEvent::_get_x_root;
*set_x_root ||= *X11::Xlib::XEvent::_set_x_root;
sub x_root { $_[0]->set_x_root($_[1]) if @_ > 1; $_[0]->get_x_root() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }
*get_y_root ||= *X11::Xlib::XEvent::_get_y_root;
*set_y_root ||= *X11::Xlib::XEvent::_set_y_root;
sub y_root { $_[0]->set_y_root($_[1]) if @_ > 1; $_[0]->get_y_root() }

package X11::Xlib::XEvent::XNoExposeEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_drawable ||= *X11::Xlib::XEvent::_get_drawable;
*set_drawable ||= *X11::Xlib::XEvent::_set_drawable;
sub drawable { $_[0]->set_drawable($_[1]) if @_ > 1; $_[0]->get_drawable() }
*get_major_code ||= *X11::Xlib::XEvent::_get_major_code;
*set_major_code ||= *X11::Xlib::XEvent::_set_major_code;
sub major_code { $_[0]->set_major_code($_[1]) if @_ > 1; $_[0]->get_major_code() }
*get_minor_code ||= *X11::Xlib::XEvent::_get_minor_code;
*set_minor_code ||= *X11::Xlib::XEvent::_set_minor_code;
sub minor_code { $_[0]->set_minor_code($_[1]) if @_ > 1; $_[0]->get_minor_code() }

package X11::Xlib::XEvent::XPropertyEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_atom ||= *X11::Xlib::XEvent::_get_atom;
*set_atom ||= *X11::Xlib::XEvent::_set_atom;
sub atom { $_[0]->set_atom($_[1]) if @_ > 1; $_[0]->get_atom() }
*get_state ||= *X11::Xlib::XEvent::_get_state;
*set_state ||= *X11::Xlib::XEvent::_set_state;
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XReparentEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_event ||= *X11::Xlib::XEvent::_get_event;
*set_event ||= *X11::Xlib::XEvent::_set_event;
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_override_redirect ||= *X11::Xlib::XEvent::_get_override_redirect;
*set_override_redirect ||= *X11::Xlib::XEvent::_set_override_redirect;
sub override_redirect { $_[0]->set_override_redirect($_[1]) if @_ > 1; $_[0]->get_override_redirect() }
*get_parent ||= *X11::Xlib::XEvent::_get_parent;
*set_parent ||= *X11::Xlib::XEvent::_set_parent;
sub parent { $_[0]->set_parent($_[1]) if @_ > 1; $_[0]->get_parent() }
*get_x ||= *X11::Xlib::XEvent::_get_x;
*set_x ||= *X11::Xlib::XEvent::_set_x;
sub x { $_[0]->set_x($_[1]) if @_ > 1; $_[0]->get_x() }
*get_y ||= *X11::Xlib::XEvent::_get_y;
*set_y ||= *X11::Xlib::XEvent::_set_y;
sub y { $_[0]->set_y($_[1]) if @_ > 1; $_[0]->get_y() }

package X11::Xlib::XEvent::XResizeRequestEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_height ||= *X11::Xlib::XEvent::_get_height;
*set_height ||= *X11::Xlib::XEvent::_set_height;
sub height { $_[0]->set_height($_[1]) if @_ > 1; $_[0]->get_height() }
*get_width ||= *X11::Xlib::XEvent::_get_width;
*set_width ||= *X11::Xlib::XEvent::_set_width;
sub width { $_[0]->set_width($_[1]) if @_ > 1; $_[0]->get_width() }

package X11::Xlib::XEvent::XSelectionClearEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_selection ||= *X11::Xlib::XEvent::_get_selection;
*set_selection ||= *X11::Xlib::XEvent::_set_selection;
sub selection { $_[0]->set_selection($_[1]) if @_ > 1; $_[0]->get_selection() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XSelectionEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_property ||= *X11::Xlib::XEvent::_get_property;
*set_property ||= *X11::Xlib::XEvent::_set_property;
sub property { $_[0]->set_property($_[1]) if @_ > 1; $_[0]->get_property() }
*get_requestor ||= *X11::Xlib::XEvent::_get_requestor;
*set_requestor ||= *X11::Xlib::XEvent::_set_requestor;
sub requestor { $_[0]->set_requestor($_[1]) if @_ > 1; $_[0]->get_requestor() }
*get_selection ||= *X11::Xlib::XEvent::_get_selection;
*set_selection ||= *X11::Xlib::XEvent::_set_selection;
sub selection { $_[0]->set_selection($_[1]) if @_ > 1; $_[0]->get_selection() }
*get_target ||= *X11::Xlib::XEvent::_get_target;
*set_target ||= *X11::Xlib::XEvent::_set_target;
sub target { $_[0]->set_target($_[1]) if @_ > 1; $_[0]->get_target() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XSelectionRequestEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_owner ||= *X11::Xlib::XEvent::_get_owner;
*set_owner ||= *X11::Xlib::XEvent::_set_owner;
sub owner { $_[0]->set_owner($_[1]) if @_ > 1; $_[0]->get_owner() }
*get_property ||= *X11::Xlib::XEvent::_get_property;
*set_property ||= *X11::Xlib::XEvent::_set_property;
sub property { $_[0]->set_property($_[1]) if @_ > 1; $_[0]->get_property() }
*get_requestor ||= *X11::Xlib::XEvent::_get_requestor;
*set_requestor ||= *X11::Xlib::XEvent::_set_requestor;
sub requestor { $_[0]->set_requestor($_[1]) if @_ > 1; $_[0]->get_requestor() }
*get_selection ||= *X11::Xlib::XEvent::_get_selection;
*set_selection ||= *X11::Xlib::XEvent::_set_selection;
sub selection { $_[0]->set_selection($_[1]) if @_ > 1; $_[0]->get_selection() }
*get_target ||= *X11::Xlib::XEvent::_get_target;
*set_target ||= *X11::Xlib::XEvent::_set_target;
sub target { $_[0]->set_target($_[1]) if @_ > 1; $_[0]->get_target() }
*get_time ||= *X11::Xlib::XEvent::_get_time;
*set_time ||= *X11::Xlib::XEvent::_set_time;
sub time { $_[0]->set_time($_[1]) if @_ > 1; $_[0]->get_time() }

package X11::Xlib::XEvent::XUnmapEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_event ||= *X11::Xlib::XEvent::_get_event;
*set_event ||= *X11::Xlib::XEvent::_set_event;
sub event { $_[0]->set_event($_[1]) if @_ > 1; $_[0]->get_event() }
*get_from_configure ||= *X11::Xlib::XEvent::_get_from_configure;
*set_from_configure ||= *X11::Xlib::XEvent::_set_from_configure;
sub from_configure { $_[0]->set_from_configure($_[1]) if @_ > 1; $_[0]->get_from_configure() }

package X11::Xlib::XEvent::XVisibilityEvent;
our @ISA= 'X11::Xlib::XEvent';
*get_state ||= *X11::Xlib::XEvent::_get_state;
*set_state ||= *X11::Xlib::XEvent::_set_state;
sub state { $_[0]->set_state($_[1]) if @_ > 1; $_[0]->get_state() }
# END GENERATED X11_Xlib_XEvent
# ----------------------------------------------------------------------------


1;
