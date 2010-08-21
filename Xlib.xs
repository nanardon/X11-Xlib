#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <X11/Xlib.h>
#include <X11/Xutil.h>

static Display *TheXDisplay = NULL;

MODULE = X11::Xlib                PACKAGE = X11::Xlib

void
new(class, display = NULL)
    char * class
    char * display
    PREINIT:
        Display * dpy;
    PPCODE:
        dpy = XOpenDisplay(display);
        XPUSHs(sv_2mortal(sv_setref_pv(newSVpv("", 0), "X11::Xlib", dpy)));

void
DESTROY(dpy)
    Display *dpy
    PPCODE:
        (void) XCloseDisplay(dpy);

int
DisplayWidth(dpy, screen=0)
    Display *dpy
    int screen
    CODE:
        RETVAL = DisplayWidth(dpy, screen);
    OUTPUT:
        RETVAL

int
DisplayHeight(dpy, screen=0)
    Display *dpy
    int screen
    CODE:
        RETVAL = DisplayHeight(dpy, screen);
    OUTPUT:
        RETVAL


# /* Windows */

void
RootWindow(dpy, screen)
    Display * dpy
    int screen
    PREINIT:
        Window window;
    PPCODE:
        window = RootWindow(dpy, screen);
        XPUSHs(sv_2mortal(sv_setref_uv(newSVpv("", 0), "X11::Xlib::Window", window)));

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
    
MODULE = X11::Xlib                PACKAGE = X11::Xlib::Window

unsigned int
id(window)
    Window window
    CODE:
        RETVAL = window;
    OUTPUT:
        RETVAL
