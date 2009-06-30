#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <X11/Xlib.h>

static Display *TheXDisplay = NULL;

MODULE = X11::Xlib		PACKAGE = X11::Xlib		

void
new(class, display = NULL)
    char * class
    char * display
    PREINIT:
    Display * dpy;
    PPCODE:
    dpy = XOpenDisplay(display);
    XPUSHs(sv_2mortal(sv_setref_pv(newSVpv("", 0), "X11::Xlib", dpy)));

int
DisplayWidth(dpy, screen)
    Display *dpy
    int screen
    CODE:
    RETVAL = DisplayWidth(dpy, screen);
    OUTPUT:
    RETVAL

int
DisplayHeight(dpy, screen)
    Display *dpy
    int screen
    CODE:
    RETVAL = DisplayHeight(dpy, screen);
    OUTPUT:
    RETVAL
