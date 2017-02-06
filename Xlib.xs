#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/XTest.h>

#include "PerlXlib.c"

MODULE = X11::Xlib                PACKAGE = X11::Xlib

Display *
XOpenDisplay(connection_string = NULL)
    char * connection_string
    CODE:
        if (SvTRUE(get_sv("X11::Xlib::_error_fatal_trapped", GV_ADD)))
            croak("Cannot call further Xlib functions after fatal Xlib error");
        RETVAL = XOpenDisplay(connection_string);
    OUTPUT:
        RETVAL

void
_pointer_value(dpy)
    Display *dpy
    PPCODE:
        PUSHs(sv_2mortal(newSVpvn((void*) &dpy, sizeof(dpy))));

void
XSetCloseDownMode(dpy, close_mode)
    Display *dpy
    int close_mode
    CODE:
        XSetCloseDownMode(dpy, close_mode);

void
XCloseDisplay(dpy)
    Display *dpy
    CODE:
        XCloseDisplay(dpy);

int
DisplayWidth(dpy, screen=-1)
    Display *dpy
    int screen
    CODE:
        RETVAL = DisplayWidth(dpy, screen >= 0? screen : DefaultScreen(dpy));
    OUTPUT:
        RETVAL

int
DisplayHeight(dpy, screen=-1)
    Display *dpy
    int screen
    CODE:
        RETVAL = DisplayHeight(dpy, screen >= 0? screen : DefaultScreen(dpy));
    OUTPUT:
        RETVAL

# /* Windows */

Window
RootWindow(dpy, screen=-1)
    Display * dpy
    int screen
    CODE:
        RETVAL = RootWindow(dpy, screen >= 0? screen : DefaultScreen(dpy));
    OUTPUT:
        RETVAL

# /* Event */

int
XTestFakeMotionEvent(dpy, screen, x, y, EventSendDelay = 10)
    Display * dpy
    int screen
    int x
    int y
    int EventSendDelay

int
XTestFakeButtonEvent(dpy, button, pressed, EventSendDelay = 10);
    Display * dpy
    int button
    int pressed
    int EventSendDelay

int
XTestFakeKeyEvent(dpy, kc, pressed, EventSendDelay = 10)
    Display * dpy
    unsigned char kc
    int pressed
    int EventSendDelay

void
XBell(dpy, percent)
    Display * dpy
    int percent

void
XQueryKeymap(dpy)
    Display * dpy
    PREINIT:
        char keys_return[32];
        int i, j;
    PPCODE:
        XQueryKeymap(dpy, keys_return);
        for(i=0; i<32; i++) {
            for (j=0; j<8;j++) {
                if (keys_return[i] & (1 << j))
                    XPUSHs(sv_2mortal(newSViv(i * 8 + j)));
            }
        }

unsigned long
keyboard_leds(dpy)
    Display * dpy;
    PREINIT:
        XKeyboardState state;
    CODE:
        XGetKeyboardControl(dpy, &state);
        RETVAL = state.led_mask;
    OUTPUT:
        RETVAL

void
_auto_repeat(dpy)
    Display * dpy;
    PREINIT:
        XKeyboardState state;
        int i, j;
    CODE:
        XGetKeyboardControl(dpy, &state);
        for(i=0; i<32; i++) {
            for (j=0; j<8; j++) {
                if (state.auto_repeats[i] & (1 << j))
                    XPUSHs(sv_2mortal(newSViv(i * 8 + j)));
            }
        }

void
XFlush(dpy)
    Display *dpy

void
XSync(dpy, flush=0)
    Display * dpy
    int flush

# /* keyboard functions */

char *
XKeysymToString(keysym)
    unsigned long keysym
    CODE:
        RETVAL = XKeysymToString(keysym);
    OUTPUT:
        RETVAL

unsigned long
XStringToKeysym(string)
    char * string
    CODE:
        RETVAL = XStringToKeysym(string);
    OUTPUT:
        RETVAL

int
IsKeypadKey(keysym)
    unsigned long keysym

int
IsPrivateKeypadKey(keysym)
    unsigned long keysym

int
IsPFKey(keysym)
    unsigned long keysym

int
IsFunctionKey(keysym)
    unsigned long keysym

int
IsMiscFunctionKey(keysym)
    unsigned long keysym

int
IsModifierKey(keysym)
    unsigned long keysym

unsigned int
XKeysymToKeycode(dpy, keysym)
    Display *dpy
    unsigned long keysym
    CODE:
        RETVAL = XKeysymToKeycode(dpy, keysym);
    OUTPUT:
        RETVAL

void
XGetKeyboardMapping(dpy, fkeycode, count = 1)
    Display *dpy
    unsigned int fkeycode
    int count
    PREINIT:
    int creturn;
    KeySym * keysym;
    int i = 0;
    PPCODE:
    keysym = XGetKeyboardMapping(dpy, fkeycode, count, &creturn);
    EXTEND(SP, creturn -1);
    for (i=0; i < creturn; i++)
        XPUSHs(sv_2mortal(newSVuv(keysym[i])));

void
_error_names()
    INIT:
        HV* codes;
        char intbuf[sizeof(long)*3+2];
    PPCODE:
        codes= get_hv("X11::Xlib::_error_names", 0);
        if (!codes) {
            codes= get_hv("X11::Xlib::_error_names", GV_ADD);
#define E(name) hv_store(codes, intbuf, snprintf(intbuf, sizeof(intbuf), "%d", name), newSVpv(#name,0), 0) || die("hash-store");
            E(BadAccess)
            E(BadAlloc)
            E(BadAtom)
            E(BadColor)
            E(BadCursor)
            E(BadDrawable)
            E(BadFont)
            E(BadGC)
            E(BadIDChoice)
            E(BadImplementation)
            E(BadLength)
            E(BadMatch)
            E(BadName)
            E(BadPixmap)
            E(BadRequest)
            E(BadValue)
            E(BadWindow)
#undef E
        }
        PUSHs(sv_2mortal((SV*)newRV((SV*)codes)));

void
install_error_handlers(nonfatal,fatal)
    Bool nonfatal
    Bool fatal
    CODE:
        PerlXlib_install_error_handlers(nonfatal, fatal);

MODULE = X11::Xlib                PACKAGE = X11::Xlib::XEvent

void
_pack(e, fields)
  XEvent *e
  HV* fields
  PPCODE:
    PerlXlib_XEvent_pack(e, fields);

void
_unpack(e, HV* fields)
  XEvent* e
  PPCODE:
    PerlXlib_XEvent_unpack(e, fields);

# ----------------------------------------------------------------------------
# BEGIN GENERATED X11_Xlib_XEvent

Window
_get_above(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      RETVAL = event->xconfigure.above; break;
    default: croak("Can't access XEvent.above for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_above(event, value)
  XEvent *event
  Window value
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      event->xconfigure.above= value; break;
    default: croak("Can't access XEvent.above for type=%d", event->type);
    }

Atom
_get_atom(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case PropertyNotify:
      RETVAL = event->xproperty.atom; break;
    default: croak("Can't access XEvent.atom for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_atom(event, value)
  XEvent *event
  Atom value
  CODE:
    switch( event->type ) {
    case PropertyNotify:
      event->xproperty.atom= value; break;
    default: croak("Can't access XEvent.atom for type=%d", event->type);
    }

void
_get_b(event)
  XEvent *event
  PPCODE:
    switch( event->type ) {
    case ClientMessage:
      PUSHs(sv_2mortal(newSVpvn((void*)event->xclient.data.b, sizeof(char)*20))); break;
    default: croak("Can't access XEvent.b for type=%d", event->type);
    }


void
_set_b(event, value)
  XEvent *event
  SV* value
  CODE:
    switch( event->type ) {
    case ClientMessage:
      { if (!SvPOK(value) || SvLEN(value) != sizeof(char)*20)  croak("Expected scalar of length %d but got %d", sizeof(char)*20, SvLEN(value)); memcpy(event->xclient.data.b, SvPVX(value), sizeof(char)*20);} break;
    default: croak("Can't access XEvent.b for type=%d", event->type);
    }

int
_get_border_width(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      RETVAL = event->xconfigure.border_width; break;
    case CreateNotify:
      RETVAL = event->xcreatewindow.border_width; break;
    default: croak("Can't access XEvent.border_width for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_border_width(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      event->xconfigure.border_width= value; break;
    case CreateNotify:
      event->xcreatewindow.border_width= value; break;
    default: croak("Can't access XEvent.border_width for type=%d", event->type);
    }

unsigned int
_get_button(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.button; break;
    default: croak("Can't access XEvent.button for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_button(event, value)
  XEvent *event
  unsigned int value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.button= value; break;
    default: croak("Can't access XEvent.button for type=%d", event->type);
    }

Colormap
_get_colormap(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ColormapNotify:
      RETVAL = event->xcolormap.colormap; break;
    default: croak("Can't access XEvent.colormap for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_colormap(event, value)
  XEvent *event
  Colormap value
  CODE:
    switch( event->type ) {
    case ColormapNotify:
      event->xcolormap.colormap= value; break;
    default: croak("Can't access XEvent.colormap for type=%d", event->type);
    }

unsigned int
_get_cookie(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.cookie for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_cookie(event, value)
  XEvent *event
  unsigned int value
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.cookie for type=%d", event->type);
    }

int
_get_count(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case Expose:
      RETVAL = event->xexpose.count; break;
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.count; break;
    case MappingNotify:
      RETVAL = event->xmapping.count; break;
    default: croak("Can't access XEvent.count for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_count(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case Expose:
      event->xexpose.count= value; break;
    case GraphicsExpose:
      event->xgraphicsexpose.count= value; break;
    case MappingNotify:
      event->xmapping.count= value; break;
    default: croak("Can't access XEvent.count for type=%d", event->type);
    }

int
_get_detail(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.detail; break;
    case FocusOut:
    case FocusIn:
      RETVAL = event->xfocus.detail; break;
    default: croak("Can't access XEvent.detail for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_detail(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.detail= value; break;
    case FocusOut:
    case FocusIn:
      event->xfocus.detail= value; break;
    default: croak("Can't access XEvent.detail for type=%d", event->type);
    }

Display *
_get_display(event)
  XEvent *event
  CODE:
    RETVAL = event->xany.display;
  OUTPUT:
    RETVAL


void
_set_display(event, value)
  XEvent *event
  Display * value
  CODE:
    event->xany.display= value;


Drawable
_get_drawable(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.drawable; break;
    case NoExpose:
      RETVAL = event->xnoexpose.drawable; break;
    default: croak("Can't access XEvent.drawable for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_drawable(event, value)
  XEvent *event
  Drawable value
  CODE:
    switch( event->type ) {
    case GraphicsExpose:
      event->xgraphicsexpose.drawable= value; break;
    case NoExpose:
      event->xnoexpose.drawable= value; break;
    default: croak("Can't access XEvent.drawable for type=%d", event->type);
    }

Window
_get_event(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case CirculateNotify:
      RETVAL = event->xcirculate.event; break;
    case ConfigureNotify:
      RETVAL = event->xconfigure.event; break;
    case DestroyNotify:
      RETVAL = event->xdestroywindow.event; break;
    case GravityNotify:
      RETVAL = event->xgravity.event; break;
    case MapNotify:
      RETVAL = event->xmap.event; break;
    case ReparentNotify:
      RETVAL = event->xreparent.event; break;
    case UnmapNotify:
      RETVAL = event->xunmap.event; break;
    default: croak("Can't access XEvent.event for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_event(event, value)
  XEvent *event
  Window value
  CODE:
    switch( event->type ) {
    case CirculateNotify:
      event->xcirculate.event= value; break;
    case ConfigureNotify:
      event->xconfigure.event= value; break;
    case DestroyNotify:
      event->xdestroywindow.event= value; break;
    case GravityNotify:
      event->xgravity.event= value; break;
    case MapNotify:
      event->xmap.event= value; break;
    case ReparentNotify:
      event->xreparent.event= value; break;
    case UnmapNotify:
      event->xunmap.event= value; break;
    default: croak("Can't access XEvent.event for type=%d", event->type);
    }

int
_get_evtype(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.evtype for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_evtype(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.evtype for type=%d", event->type);
    }

int
_get_extension(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.extension for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_extension(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.extension for type=%d", event->type);
    }

int
_get_first_keycode(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case MappingNotify:
      RETVAL = event->xmapping.first_keycode; break;
    default: croak("Can't access XEvent.first_keycode for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_first_keycode(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case MappingNotify:
      event->xmapping.first_keycode= value; break;
    default: croak("Can't access XEvent.first_keycode for type=%d", event->type);
    }

Bool
_get_focus(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.focus; break;
    default: croak("Can't access XEvent.focus for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_focus(event, value)
  XEvent *event
  Bool value
  CODE:
    switch( event->type ) {
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.focus= value; break;
    default: croak("Can't access XEvent.focus for type=%d", event->type);
    }

int
_get_format(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ClientMessage:
      RETVAL = event->xclient.format; break;
    default: croak("Can't access XEvent.format for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_format(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ClientMessage:
      event->xclient.format= value; break;
    default: croak("Can't access XEvent.format for type=%d", event->type);
    }

Bool
_get_from_configure(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case UnmapNotify:
      RETVAL = event->xunmap.from_configure; break;
    default: croak("Can't access XEvent.from_configure for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_from_configure(event, value)
  XEvent *event
  Bool value
  CODE:
    switch( event->type ) {
    case UnmapNotify:
      event->xunmap.from_configure= value; break;
    default: croak("Can't access XEvent.from_configure for type=%d", event->type);
    }

int
_get_height(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      RETVAL = event->xconfigure.height; break;
    case CreateNotify:
      RETVAL = event->xcreatewindow.height; break;
    case Expose:
      RETVAL = event->xexpose.height; break;
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.height; break;
    case ResizeRequest:
      RETVAL = event->xresizerequest.height; break;
    default: croak("Can't access XEvent.height for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_height(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      event->xconfigure.height= value; break;
    case CreateNotify:
      event->xcreatewindow.height= value; break;
    case Expose:
      event->xexpose.height= value; break;
    case GraphicsExpose:
      event->xgraphicsexpose.height= value; break;
    case ResizeRequest:
      event->xresizerequest.height= value; break;
    default: croak("Can't access XEvent.height for type=%d", event->type);
    }

char
_get_is_hint(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case MotionNotify:
      RETVAL = event->xmotion.is_hint; break;
    default: croak("Can't access XEvent.is_hint for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_is_hint(event, value)
  XEvent *event
  char value
  CODE:
    switch( event->type ) {
    case MotionNotify:
      event->xmotion.is_hint= value; break;
    default: croak("Can't access XEvent.is_hint for type=%d", event->type);
    }

void
_get_key_vector(event)
  XEvent *event
  PPCODE:
    switch( event->type ) {
    case KeymapNotify:
      PUSHs(sv_2mortal(newSVpvn((void*)event->xkeymap.key_vector, sizeof(char)*32))); break;
    default: croak("Can't access XEvent.key_vector for type=%d", event->type);
    }


void
_set_key_vector(event, value)
  XEvent *event
  SV* value
  CODE:
    switch( event->type ) {
    case KeymapNotify:
      { if (!SvPOK(value) || SvLEN(value) != sizeof(char)*32)  croak("Expected scalar of length %d but got %d", sizeof(char)*32, SvLEN(value)); memcpy(event->xkeymap.key_vector, SvPVX(value), sizeof(char)*32);} break;
    default: croak("Can't access XEvent.key_vector for type=%d", event->type);
    }

unsigned int
_get_keycode(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.keycode; break;
    default: croak("Can't access XEvent.keycode for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_keycode(event, value)
  XEvent *event
  unsigned int value
  CODE:
    switch( event->type ) {
    case KeyPress:
    case KeyRelease:
      event->xkey.keycode= value; break;
    default: croak("Can't access XEvent.keycode for type=%d", event->type);
    }

void
_get_l(event)
  XEvent *event
  PPCODE:
    switch( event->type ) {
    case ClientMessage:
      PUSHs(sv_2mortal(newSVpvn((void*)event->xclient.data.l, sizeof(long)*5))); break;
    default: croak("Can't access XEvent.l for type=%d", event->type);
    }


void
_set_l(event, value)
  XEvent *event
  SV* value
  CODE:
    switch( event->type ) {
    case ClientMessage:
      { if (!SvPOK(value) || SvLEN(value) != sizeof(long)*5)  croak("Expected scalar of length %d but got %d", sizeof(long)*5, SvLEN(value)); memcpy(event->xclient.data.l, SvPVX(value), sizeof(long)*5);} break;
    default: croak("Can't access XEvent.l for type=%d", event->type);
    }

int
_get_major_code(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.major_code; break;
    case NoExpose:
      RETVAL = event->xnoexpose.major_code; break;
    default: croak("Can't access XEvent.major_code for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_major_code(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case GraphicsExpose:
      event->xgraphicsexpose.major_code= value; break;
    case NoExpose:
      event->xnoexpose.major_code= value; break;
    default: croak("Can't access XEvent.major_code for type=%d", event->type);
    }

Atom
_get_message_type(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ClientMessage:
      RETVAL = event->xclient.message_type; break;
    default: croak("Can't access XEvent.message_type for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_message_type(event, value)
  XEvent *event
  Atom value
  CODE:
    switch( event->type ) {
    case ClientMessage:
      event->xclient.message_type= value; break;
    default: croak("Can't access XEvent.message_type for type=%d", event->type);
    }

int
_get_minor_code(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.minor_code; break;
    case NoExpose:
      RETVAL = event->xnoexpose.minor_code; break;
    default: croak("Can't access XEvent.minor_code for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_minor_code(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case GraphicsExpose:
      event->xgraphicsexpose.minor_code= value; break;
    case NoExpose:
      event->xnoexpose.minor_code= value; break;
    default: croak("Can't access XEvent.minor_code for type=%d", event->type);
    }

int
_get_mode(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.mode; break;
    case FocusOut:
    case FocusIn:
      RETVAL = event->xfocus.mode; break;
    default: croak("Can't access XEvent.mode for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_mode(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.mode= value; break;
    case FocusOut:
    case FocusIn:
      event->xfocus.mode= value; break;
    default: croak("Can't access XEvent.mode for type=%d", event->type);
    }

Bool
_get_new(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ColormapNotify:
      RETVAL = event->xcolormap.new; break;
    default: croak("Can't access XEvent.new for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_new(event, value)
  XEvent *event
  Bool value
  CODE:
    switch( event->type ) {
    case ColormapNotify:
      event->xcolormap.new= value; break;
    default: croak("Can't access XEvent.new for type=%d", event->type);
    }

Bool
_get_override_redirect(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      RETVAL = event->xconfigure.override_redirect; break;
    case CreateNotify:
      RETVAL = event->xcreatewindow.override_redirect; break;
    case MapNotify:
      RETVAL = event->xmap.override_redirect; break;
    case ReparentNotify:
      RETVAL = event->xreparent.override_redirect; break;
    default: croak("Can't access XEvent.override_redirect for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_override_redirect(event, value)
  XEvent *event
  Bool value
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      event->xconfigure.override_redirect= value; break;
    case CreateNotify:
      event->xcreatewindow.override_redirect= value; break;
    case MapNotify:
      event->xmap.override_redirect= value; break;
    case ReparentNotify:
      event->xreparent.override_redirect= value; break;
    default: croak("Can't access XEvent.override_redirect for type=%d", event->type);
    }

Window
_get_owner(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case SelectionRequest:
      RETVAL = event->xselectionrequest.owner; break;
    default: croak("Can't access XEvent.owner for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_owner(event, value)
  XEvent *event
  Window value
  CODE:
    switch( event->type ) {
    case SelectionRequest:
      event->xselectionrequest.owner= value; break;
    default: croak("Can't access XEvent.owner for type=%d", event->type);
    }

void
_get_pad(event)
  XEvent *event
  PPCODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.pad for type=%d", event->type);
    }


void
_set_pad(event, value)
  XEvent *event
  SV* value
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.pad for type=%d", event->type);
    }

Window
_get_parent(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case CreateNotify:
      RETVAL = event->xcreatewindow.parent; break;
    case ReparentNotify:
      RETVAL = event->xreparent.parent; break;
    default: croak("Can't access XEvent.parent for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_parent(event, value)
  XEvent *event
  Window value
  CODE:
    switch( event->type ) {
    case CreateNotify:
      event->xcreatewindow.parent= value; break;
    case ReparentNotify:
      event->xreparent.parent= value; break;
    default: croak("Can't access XEvent.parent for type=%d", event->type);
    }

int
_get_place(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case CirculateNotify:
      RETVAL = event->xcirculate.place; break;
    default: croak("Can't access XEvent.place for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_place(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case CirculateNotify:
      event->xcirculate.place= value; break;
    default: croak("Can't access XEvent.place for type=%d", event->type);
    }

Atom
_get_property(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      RETVAL = event->xselection.property; break;
    case SelectionRequest:
      RETVAL = event->xselectionrequest.property; break;
    default: croak("Can't access XEvent.property for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_property(event, value)
  XEvent *event
  Atom value
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      event->xselection.property= value; break;
    case SelectionRequest:
      event->xselectionrequest.property= value; break;
    default: croak("Can't access XEvent.property for type=%d", event->type);
    }

int
_get_request(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case MappingNotify:
      RETVAL = event->xmapping.request; break;
    default: croak("Can't access XEvent.request for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_request(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case MappingNotify:
      event->xmapping.request= value; break;
    default: croak("Can't access XEvent.request for type=%d", event->type);
    }

Window
_get_requestor(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      RETVAL = event->xselection.requestor; break;
    case SelectionRequest:
      RETVAL = event->xselectionrequest.requestor; break;
    default: croak("Can't access XEvent.requestor for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_requestor(event, value)
  XEvent *event
  Window value
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      event->xselection.requestor= value; break;
    case SelectionRequest:
      event->xselectionrequest.requestor= value; break;
    default: croak("Can't access XEvent.requestor for type=%d", event->type);
    }

Window
_get_root(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.root; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.root; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.root; break;
    case MotionNotify:
      RETVAL = event->xmotion.root; break;
    default: croak("Can't access XEvent.root for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_root(event, value)
  XEvent *event
  Window value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.root= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.root= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.root= value; break;
    case MotionNotify:
      event->xmotion.root= value; break;
    default: croak("Can't access XEvent.root for type=%d", event->type);
    }

void
_get_s(event)
  XEvent *event
  PPCODE:
    switch( event->type ) {
    case ClientMessage:
      PUSHs(sv_2mortal(newSVpvn((void*)event->xclient.data.s, sizeof(short)*10))); break;
    default: croak("Can't access XEvent.s for type=%d", event->type);
    }


void
_set_s(event, value)
  XEvent *event
  SV* value
  CODE:
    switch( event->type ) {
    case ClientMessage:
      { if (!SvPOK(value) || SvLEN(value) != sizeof(short)*10)  croak("Expected scalar of length %d but got %d", sizeof(short)*10, SvLEN(value)); memcpy(event->xclient.data.s, SvPVX(value), sizeof(short)*10);} break;
    default: croak("Can't access XEvent.s for type=%d", event->type);
    }

Bool
_get_same_screen(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.same_screen; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.same_screen; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.same_screen; break;
    case MotionNotify:
      RETVAL = event->xmotion.same_screen; break;
    default: croak("Can't access XEvent.same_screen for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_same_screen(event, value)
  XEvent *event
  Bool value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.same_screen= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.same_screen= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.same_screen= value; break;
    case MotionNotify:
      event->xmotion.same_screen= value; break;
    default: croak("Can't access XEvent.same_screen for type=%d", event->type);
    }

Atom
_get_selection(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      RETVAL = event->xselection.selection; break;
    case SelectionClear:
      RETVAL = event->xselectionclear.selection; break;
    case SelectionRequest:
      RETVAL = event->xselectionrequest.selection; break;
    default: croak("Can't access XEvent.selection for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_selection(event, value)
  XEvent *event
  Atom value
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      event->xselection.selection= value; break;
    case SelectionClear:
      event->xselectionclear.selection= value; break;
    case SelectionRequest:
      event->xselectionrequest.selection= value; break;
    default: croak("Can't access XEvent.selection for type=%d", event->type);
    }

Bool
_get_send_event(event)
  XEvent *event
  CODE:
    RETVAL = event->xany.send_event;
  OUTPUT:
    RETVAL


void
_set_send_event(event, value)
  XEvent *event
  Bool value
  CODE:
    event->xany.send_event= value;


unsigned long
_get_serial(event)
  XEvent *event
  CODE:
    RETVAL = event->xany.serial;
  OUTPUT:
    RETVAL


void
_set_serial(event, value)
  XEvent *event
  unsigned long value
  CODE:
    event->xany.serial= value;


void
_get_state(event)
  XEvent *event
  PPCODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      PUSHs(sv_2mortal(newSVuv(event->xbutton.state))); break;
    case ColormapNotify:
      PUSHs(sv_2mortal(newSViv(event->xcolormap.state))); break;
    case LeaveNotify:
    case EnterNotify:
      PUSHs(sv_2mortal(newSVuv(event->xcrossing.state))); break;
    case KeyPress:
    case KeyRelease:
      PUSHs(sv_2mortal(newSVuv(event->xkey.state))); break;
    case MotionNotify:
      PUSHs(sv_2mortal(newSVuv(event->xmotion.state))); break;
    case PropertyNotify:
      PUSHs(sv_2mortal(newSViv(event->xproperty.state))); break;
    case VisibilityNotify:
      PUSHs(sv_2mortal(newSViv(event->xvisibility.state))); break;
    default: croak("Can't access XEvent.state for type=%d", event->type);
    }


void
_set_state(event, value)
  XEvent *event
  SV* value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.state= SvUV(value); break;
    case ColormapNotify:
      event->xcolormap.state= SvIV(value); break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.state= SvUV(value); break;
    case KeyPress:
    case KeyRelease:
      event->xkey.state= SvUV(value); break;
    case MotionNotify:
      event->xmotion.state= SvUV(value); break;
    case PropertyNotify:
      event->xproperty.state= SvIV(value); break;
    case VisibilityNotify:
      event->xvisibility.state= SvIV(value); break;
    default: croak("Can't access XEvent.state for type=%d", event->type);
    }

Window
_get_subwindow(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.subwindow; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.subwindow; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.subwindow; break;
    case MotionNotify:
      RETVAL = event->xmotion.subwindow; break;
    default: croak("Can't access XEvent.subwindow for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_subwindow(event, value)
  XEvent *event
  Window value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.subwindow= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.subwindow= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.subwindow= value; break;
    case MotionNotify:
      event->xmotion.subwindow= value; break;
    default: croak("Can't access XEvent.subwindow for type=%d", event->type);
    }

Atom
_get_target(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      RETVAL = event->xselection.target; break;
    case SelectionRequest:
      RETVAL = event->xselectionrequest.target; break;
    default: croak("Can't access XEvent.target for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_target(event, value)
  XEvent *event
  Atom value
  CODE:
    switch( event->type ) {
    case SelectionNotify:
      event->xselection.target= value; break;
    case SelectionRequest:
      event->xselectionrequest.target= value; break;
    default: croak("Can't access XEvent.target for type=%d", event->type);
    }

Time
_get_time(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.time; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.time; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.time; break;
    case MotionNotify:
      RETVAL = event->xmotion.time; break;
    case PropertyNotify:
      RETVAL = event->xproperty.time; break;
    case SelectionNotify:
      RETVAL = event->xselection.time; break;
    case SelectionClear:
      RETVAL = event->xselectionclear.time; break;
    case SelectionRequest:
      RETVAL = event->xselectionrequest.time; break;
    default: croak("Can't access XEvent.time for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_time(event, value)
  XEvent *event
  Time value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.time= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.time= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.time= value; break;
    case MotionNotify:
      event->xmotion.time= value; break;
    case PropertyNotify:
      event->xproperty.time= value; break;
    case SelectionNotify:
      event->xselection.time= value; break;
    case SelectionClear:
      event->xselectionclear.time= value; break;
    case SelectionRequest:
      event->xselectionrequest.time= value; break;
    default: croak("Can't access XEvent.time for type=%d", event->type);
    }

int
_get_type(event)
  XEvent *event
  CODE:
    RETVAL = event->xany.type;
  OUTPUT:
    RETVAL


void
_set_type(event, value)
  XEvent *event
  int value
  CODE:
    event->xany.type= value;


unsigned long
_get_value_mask(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.value_mask for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_value_mask(event, value)
  XEvent *event
  unsigned long value
  CODE:
    switch( event->type ) {
    default: croak("Can't access XEvent.value_mask for type=%d", event->type);
    }

int
_get_width(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      RETVAL = event->xconfigure.width; break;
    case CreateNotify:
      RETVAL = event->xcreatewindow.width; break;
    case Expose:
      RETVAL = event->xexpose.width; break;
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.width; break;
    case ResizeRequest:
      RETVAL = event->xresizerequest.width; break;
    default: croak("Can't access XEvent.width for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_width(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ConfigureNotify:
      event->xconfigure.width= value; break;
    case CreateNotify:
      event->xcreatewindow.width= value; break;
    case Expose:
      event->xexpose.width= value; break;
    case GraphicsExpose:
      event->xgraphicsexpose.width= value; break;
    case ResizeRequest:
      event->xresizerequest.width= value; break;
    default: croak("Can't access XEvent.width for type=%d", event->type);
    }

Window
_get_window(event)
  XEvent *event
  CODE:
    RETVAL = event->xany.window;
  OUTPUT:
    RETVAL


void
_set_window(event, value)
  XEvent *event
  Window value
  CODE:
    event->xany.window= value;


int
_get_x(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.x; break;
    case ConfigureNotify:
      RETVAL = event->xconfigure.x; break;
    case CreateNotify:
      RETVAL = event->xcreatewindow.x; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.x; break;
    case Expose:
      RETVAL = event->xexpose.x; break;
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.x; break;
    case GravityNotify:
      RETVAL = event->xgravity.x; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.x; break;
    case MotionNotify:
      RETVAL = event->xmotion.x; break;
    case ReparentNotify:
      RETVAL = event->xreparent.x; break;
    default: croak("Can't access XEvent.x for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_x(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.x= value; break;
    case ConfigureNotify:
      event->xconfigure.x= value; break;
    case CreateNotify:
      event->xcreatewindow.x= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.x= value; break;
    case Expose:
      event->xexpose.x= value; break;
    case GraphicsExpose:
      event->xgraphicsexpose.x= value; break;
    case GravityNotify:
      event->xgravity.x= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.x= value; break;
    case MotionNotify:
      event->xmotion.x= value; break;
    case ReparentNotify:
      event->xreparent.x= value; break;
    default: croak("Can't access XEvent.x for type=%d", event->type);
    }

int
_get_x_root(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.x_root; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.x_root; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.x_root; break;
    case MotionNotify:
      RETVAL = event->xmotion.x_root; break;
    default: croak("Can't access XEvent.x_root for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_x_root(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.x_root= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.x_root= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.x_root= value; break;
    case MotionNotify:
      event->xmotion.x_root= value; break;
    default: croak("Can't access XEvent.x_root for type=%d", event->type);
    }

int
_get_y(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.y; break;
    case ConfigureNotify:
      RETVAL = event->xconfigure.y; break;
    case CreateNotify:
      RETVAL = event->xcreatewindow.y; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.y; break;
    case Expose:
      RETVAL = event->xexpose.y; break;
    case GraphicsExpose:
      RETVAL = event->xgraphicsexpose.y; break;
    case GravityNotify:
      RETVAL = event->xgravity.y; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.y; break;
    case MotionNotify:
      RETVAL = event->xmotion.y; break;
    case ReparentNotify:
      RETVAL = event->xreparent.y; break;
    default: croak("Can't access XEvent.y for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_y(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.y= value; break;
    case ConfigureNotify:
      event->xconfigure.y= value; break;
    case CreateNotify:
      event->xcreatewindow.y= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.y= value; break;
    case Expose:
      event->xexpose.y= value; break;
    case GraphicsExpose:
      event->xgraphicsexpose.y= value; break;
    case GravityNotify:
      event->xgravity.y= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.y= value; break;
    case MotionNotify:
      event->xmotion.y= value; break;
    case ReparentNotify:
      event->xreparent.y= value; break;
    default: croak("Can't access XEvent.y for type=%d", event->type);
    }

int
_get_y_root(event)
  XEvent *event
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      RETVAL = event->xbutton.y_root; break;
    case LeaveNotify:
    case EnterNotify:
      RETVAL = event->xcrossing.y_root; break;
    case KeyPress:
    case KeyRelease:
      RETVAL = event->xkey.y_root; break;
    case MotionNotify:
      RETVAL = event->xmotion.y_root; break;
    default: croak("Can't access XEvent.y_root for type=%d", event->type);
    }
  OUTPUT:
    RETVAL


void
_set_y_root(event, value)
  XEvent *event
  int value
  CODE:
    switch( event->type ) {
    case ButtonRelease:
    case ButtonPress:
      event->xbutton.y_root= value; break;
    case LeaveNotify:
    case EnterNotify:
      event->xcrossing.y_root= value; break;
    case KeyPress:
    case KeyRelease:
      event->xkey.y_root= value; break;
    case MotionNotify:
      event->xmotion.y_root= value; break;
    default: croak("Can't access XEvent.y_root for type=%d", event->type);
    }

# END GENERATED X11_Xlib_XEvent
# ----------------------------------------------------------------------------

INCLUDE: PerlXlib_constants.inc
