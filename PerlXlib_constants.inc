BOOT:
#define PerlXlib_CONSTi(name) newCONSTSUB(stash, #name, newSViv(name));
#define PerlXlib_CONSTu(name) newCONSTSUB(stash, #name, newSVuv(name));
#define PerlXlib_CONSTn(name) newCONSTSUB(stash, #name, newSVnv(name));
HV* stash= gv_stashpvn("X11::Xlib", 9, 1);
// BEGIN GENERATED X11_Xlib_XEvent
PerlXlib_CONSTi(ButtonPress)
PerlXlib_CONSTi(ButtonRelease)
PerlXlib_CONSTi(CirculateNotify)
PerlXlib_CONSTi(ClientMessage)
PerlXlib_CONSTi(ColormapNotify)
PerlXlib_CONSTi(ConfigureNotify)
PerlXlib_CONSTi(CreateNotify)
PerlXlib_CONSTi(DestroyNotify)
PerlXlib_CONSTi(EnterNotify)
PerlXlib_CONSTi(Expose)
PerlXlib_CONSTi(FocusIn)
PerlXlib_CONSTi(FocusOut)
PerlXlib_CONSTi(GraphicsExpose)
PerlXlib_CONSTi(GravityNotify)
PerlXlib_CONSTi(KeyPress)
PerlXlib_CONSTi(KeyRelease)
PerlXlib_CONSTi(KeymapNotify)
PerlXlib_CONSTi(LeaveNotify)
PerlXlib_CONSTi(MapNotify)
PerlXlib_CONSTi(MappingNotify)
PerlXlib_CONSTi(MotionNotify)
PerlXlib_CONSTi(NoExpose)
PerlXlib_CONSTi(PropertyNotify)
PerlXlib_CONSTi(ReparentNotify)
PerlXlib_CONSTi(ResizeRequest)
PerlXlib_CONSTi(SelectionClear)
PerlXlib_CONSTi(SelectionNotify)
PerlXlib_CONSTi(SelectionRequest)
PerlXlib_CONSTi(UnmapNotify)
PerlXlib_CONSTi(VisibilityNotify)
// END GENERATED X11_Xlib_XEvent

