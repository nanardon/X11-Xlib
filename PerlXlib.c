// This file is included directly by Xlib.xs and is not intended to be
// externally usable.  I mostly separated it for the syntax hilighting :-)

// Allow either instance of X11::Xlib, or instance of X11::Xlib::Display
Display* PerlXlib_sv_to_display(SV *sv) {
    SV **fp;
    Display *dpy= NULL;

    if (sv_isobject(sv)) {
        if (SvTYPE(SvRV(sv)) == SVt_PVMG)
            dpy= (Display*) SvIV((SV*)SvRV( sv ));
        else if (SvTYPE(SvRV(sv)) == SVt_PVHV) {
            fp= hv_fetch((HV*)SvRV(sv), "connection", 10, 0);
            if (fp && *fp && sv_isobject(*fp) && SvTYPE(SvRV(*fp)) == SVt_PVMG)
                dpy= (Display*) SvIV((SV*)SvRV(*fp));
        }
    }
    if (!dpy)
        croak("Invalid Display handle; must be a X11::Xlib instance or X11::Xlib::Display instance");

    return dpy;
}

// Allow unsigned integer, or hashref with field ->{xid}
XID PerlXlib_sv_to_xid(SV *sv) {
    SV **xid_field;

    if (SvUOK(sv))
        return (XID) SvUV(sv);

    if (!SvROK(sv) || !(SvTYPE(SvRV(sv)) == SVt_PVHV)
        || !(xid_field= hv_fetch((HV*)SvRV(sv), "xid", 3, 0))
        || !*xid_field || !SvUOK(*xid_field))
        croak("Invalid XID (Window, etc); must be an unsigned int, or an instance of X11::Xlib::XID");

    return (XID) SvUV(*xid_field);
}

XEvent *PerlXlib_sv_to_xevent(SV *sv) {
    SV **event_field;

	// Initialize the buffer if needed.
	if (!SvOK(sv)) {
		sv_setpvn(sv, NULL, 0);
        SvGROW(sv, sizeof(XEvent)+1);
		memset(SvGROW(sv, sizeof(XEvent)), 0, sizeof(XEvent));
		return (XEvent*) SvPVX(sv);
	}
    // Otherwise we require the caller to have the right size
    
    // Also accept a scalar ref
    if (SvROK(sv)) {
        if (SvTYPE(SvRV(sv)) == SVt_PVMG)
            sv= SvRV(sv);
        // Also accept a hashref with 'xevent' parameter
        else if (SvTYPE(SvRV(sv)) == SVt_PVHV
            && (event_field= hv_fetch((HV*)SvRV(sv), "xevent", 6, 0))
            && *event_field)
            sv= *event_field;
    }

    if (!SvPOK(sv))
        croak("XEvent paramters must be a scalar, scalar ref, hash with { xevent => scalar }, or undefined");
    if (SvLEN(sv) < sizeof(XEvent))
        croak("Scalars used for XEvent must be at least %d bytes long (got %d)", sizeof(XEvent), SvLEN(sv));
    return (XEvent*) SvPVX(sv);
}

//----------------------------------------------------------------------------
// BEGIN GENERATED X11_Xlib_XEvent

void PerlXlib_XEvent_pack(XEvent *s, HV *fields) {
    SV **fp;

    memset(s, 0, sizeof(*s)); // wipe the struct
      fp= hv_fetch(fields, "window", 6, 0);
      if (fp && *fp) { s->xany.window= SvUV(*fp); }
      else { carp("'%s' uninitialized", "window"); }

      fp= hv_fetch(fields, "display", 7, 0);
      if (fp && *fp) { s->xany.display= PerlXlib_sv_to_display(*fp); }
      else { carp("'%s' uninitialized", "display"); }

      fp= hv_fetch(fields, "serial", 6, 0);
      if (fp && *fp) { s->xany.serial= SvUV(*fp); }
      else { carp("'%s' uninitialized", "serial"); }

      fp= hv_fetch(fields, "type", 4, 0);
      if (fp && *fp) { s->xany.type= SvIV(*fp); }
      else { carp("'%s' uninitialized", "type"); }

      fp= hv_fetch(fields, "send_event", 10, 0);
      if (fp && *fp) { s->xany.send_event= SvIV(*fp); }
      else { carp("'%s' uninitialized", "send_event"); }

    switch( s->type ) {
    case ButtonPress:
    case ButtonRelease:
      fp= hv_fetch(fields, "button", 6, 0);
      if (fp && *fp) { s->xbutton.button= SvUV(*fp); } else carp("'%s' uninitialized", "button");
      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xbutton.root= SvUV(*fp); } else carp("'%s' uninitialized", "root");
      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xbutton.same_screen= SvIV(*fp); } else carp("'%s' uninitialized", "same_screen");
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xbutton.state= SvUV(*fp); } else carp("'%s' uninitialized", "state");
      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xbutton.subwindow= SvUV(*fp); } else carp("'%s' uninitialized", "subwindow");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xbutton.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xbutton.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xbutton.x_root= SvIV(*fp); } else carp("'%s' uninitialized", "x_root");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xbutton.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xbutton.y_root= SvIV(*fp); } else carp("'%s' uninitialized", "y_root");
      break;
    case CirculateNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xcirculate.event= SvUV(*fp); } else carp("'%s' uninitialized", "event");
      fp= hv_fetch(fields, "place", 5, 0);
      if (fp && *fp) { s->xcirculate.place= SvIV(*fp); } else carp("'%s' uninitialized", "place");
      break;
    case ClientMessage:
      fp= hv_fetch(fields, "b", 1, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvLEN(*fp) != sizeof(char)*20)  croak("Expected scalar of length %d but got %d", sizeof(char)*20); memcpy(s->xclient.data.b, SvPVX(*fp), sizeof(char)*20);} } else carp("'%s' uninitialized", "b");
      fp= hv_fetch(fields, "l", 1, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvLEN(*fp) != sizeof(long)*5)  croak("Expected scalar of length %d but got %d", sizeof(long)*5); memcpy(s->xclient.data.l, SvPVX(*fp), sizeof(long)*5);} } else carp("'%s' uninitialized", "l");
      fp= hv_fetch(fields, "s", 1, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvLEN(*fp) != sizeof(short)*10)  croak("Expected scalar of length %d but got %d", sizeof(short)*10); memcpy(s->xclient.data.s, SvPVX(*fp), sizeof(short)*10);} } else carp("'%s' uninitialized", "s");
      fp= hv_fetch(fields, "format", 6, 0);
      if (fp && *fp) { s->xclient.format= SvIV(*fp); } else carp("'%s' uninitialized", "format");
      fp= hv_fetch(fields, "message_type", 12, 0);
      if (fp && *fp) { s->xclient.message_type= SvUV(*fp); } else carp("'%s' uninitialized", "message_type");
      break;
    case ColormapNotify:
      fp= hv_fetch(fields, "colormap", 8, 0);
      if (fp && *fp) { s->xcolormap.colormap= SvUV(*fp); } else carp("'%s' uninitialized", "colormap");
      fp= hv_fetch(fields, "new", 3, 0);
      if (fp && *fp) { s->xcolormap.new= SvIV(*fp); } else carp("'%s' uninitialized", "new");
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xcolormap.state= SvIV(*fp); } else carp("'%s' uninitialized", "state");
      break;
    case ConfigureNotify:
      fp= hv_fetch(fields, "above", 5, 0);
      if (fp && *fp) { s->xconfigure.above= SvUV(*fp); } else carp("'%s' uninitialized", "above");
      fp= hv_fetch(fields, "border_width", 12, 0);
      if (fp && *fp) { s->xconfigure.border_width= SvIV(*fp); } else carp("'%s' uninitialized", "border_width");
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xconfigure.event= SvUV(*fp); } else carp("'%s' uninitialized", "event");
      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xconfigure.height= SvIV(*fp); } else carp("'%s' uninitialized", "height");
      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xconfigure.override_redirect= SvIV(*fp); } else carp("'%s' uninitialized", "override_redirect");
      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xconfigure.width= SvIV(*fp); } else carp("'%s' uninitialized", "width");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xconfigure.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xconfigure.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      break;
    case CreateNotify:
      fp= hv_fetch(fields, "border_width", 12, 0);
      if (fp && *fp) { s->xcreatewindow.border_width= SvIV(*fp); } else carp("'%s' uninitialized", "border_width");
      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xcreatewindow.height= SvIV(*fp); } else carp("'%s' uninitialized", "height");
      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xcreatewindow.override_redirect= SvIV(*fp); } else carp("'%s' uninitialized", "override_redirect");
      fp= hv_fetch(fields, "parent", 6, 0);
      if (fp && *fp) { s->xcreatewindow.parent= SvUV(*fp); } else carp("'%s' uninitialized", "parent");
      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xcreatewindow.width= SvIV(*fp); } else carp("'%s' uninitialized", "width");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xcreatewindow.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xcreatewindow.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      break;
    case LeaveNotify:
    case EnterNotify:
      fp= hv_fetch(fields, "detail", 6, 0);
      if (fp && *fp) { s->xcrossing.detail= SvIV(*fp); } else carp("'%s' uninitialized", "detail");
      fp= hv_fetch(fields, "focus", 5, 0);
      if (fp && *fp) { s->xcrossing.focus= SvIV(*fp); } else carp("'%s' uninitialized", "focus");
      fp= hv_fetch(fields, "mode", 4, 0);
      if (fp && *fp) { s->xcrossing.mode= SvIV(*fp); } else carp("'%s' uninitialized", "mode");
      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xcrossing.root= SvUV(*fp); } else carp("'%s' uninitialized", "root");
      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xcrossing.same_screen= SvIV(*fp); } else carp("'%s' uninitialized", "same_screen");
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xcrossing.state= SvUV(*fp); } else carp("'%s' uninitialized", "state");
      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xcrossing.subwindow= SvUV(*fp); } else carp("'%s' uninitialized", "subwindow");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xcrossing.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xcrossing.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xcrossing.x_root= SvIV(*fp); } else carp("'%s' uninitialized", "x_root");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xcrossing.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xcrossing.y_root= SvIV(*fp); } else carp("'%s' uninitialized", "y_root");
      break;
    case DestroyNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xdestroywindow.event= SvUV(*fp); } else carp("'%s' uninitialized", "event");
      break;
    case Expose:
      fp= hv_fetch(fields, "count", 5, 0);
      if (fp && *fp) { s->xexpose.count= SvIV(*fp); } else carp("'%s' uninitialized", "count");
      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xexpose.height= SvIV(*fp); } else carp("'%s' uninitialized", "height");
      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xexpose.width= SvIV(*fp); } else carp("'%s' uninitialized", "width");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xexpose.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xexpose.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      break;
    case FocusOut:
    case FocusIn:
      fp= hv_fetch(fields, "detail", 6, 0);
      if (fp && *fp) { s->xfocus.detail= SvIV(*fp); } else carp("'%s' uninitialized", "detail");
      fp= hv_fetch(fields, "mode", 4, 0);
      if (fp && *fp) { s->xfocus.mode= SvIV(*fp); } else carp("'%s' uninitialized", "mode");
      break;
    case GraphicsExpose:
      fp= hv_fetch(fields, "count", 5, 0);
      if (fp && *fp) { s->xgraphicsexpose.count= SvIV(*fp); } else carp("'%s' uninitialized", "count");
      fp= hv_fetch(fields, "drawable", 8, 0);
      if (fp && *fp) { s->xgraphicsexpose.drawable= SvUV(*fp); } else carp("'%s' uninitialized", "drawable");
      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xgraphicsexpose.height= SvIV(*fp); } else carp("'%s' uninitialized", "height");
      fp= hv_fetch(fields, "major_code", 10, 0);
      if (fp && *fp) { s->xgraphicsexpose.major_code= SvIV(*fp); } else carp("'%s' uninitialized", "major_code");
      fp= hv_fetch(fields, "minor_code", 10, 0);
      if (fp && *fp) { s->xgraphicsexpose.minor_code= SvIV(*fp); } else carp("'%s' uninitialized", "minor_code");
      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xgraphicsexpose.width= SvIV(*fp); } else carp("'%s' uninitialized", "width");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xgraphicsexpose.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xgraphicsexpose.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      break;
    case GravityNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xgravity.event= SvUV(*fp); } else carp("'%s' uninitialized", "event");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xgravity.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xgravity.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      break;
    case KeyRelease:
    case KeyPress:
      fp= hv_fetch(fields, "keycode", 7, 0);
      if (fp && *fp) { s->xkey.keycode= SvUV(*fp); } else carp("'%s' uninitialized", "keycode");
      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xkey.root= SvUV(*fp); } else carp("'%s' uninitialized", "root");
      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xkey.same_screen= SvIV(*fp); } else carp("'%s' uninitialized", "same_screen");
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xkey.state= SvUV(*fp); } else carp("'%s' uninitialized", "state");
      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xkey.subwindow= SvUV(*fp); } else carp("'%s' uninitialized", "subwindow");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xkey.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xkey.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xkey.x_root= SvIV(*fp); } else carp("'%s' uninitialized", "x_root");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xkey.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xkey.y_root= SvIV(*fp); } else carp("'%s' uninitialized", "y_root");
      break;
    case KeymapNotify:
      fp= hv_fetch(fields, "key_vector", 10, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvLEN(*fp) != sizeof(char)*32)  croak("Expected scalar of length %d but got %d", sizeof(char)*32); memcpy(s->xkeymap.key_vector, SvPVX(*fp), sizeof(char)*32);} } else carp("'%s' uninitialized", "key_vector");
      break;
    case MapNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xmap.event= SvUV(*fp); } else carp("'%s' uninitialized", "event");
      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xmap.override_redirect= SvIV(*fp); } else carp("'%s' uninitialized", "override_redirect");
      break;
    case MappingNotify:
      fp= hv_fetch(fields, "count", 5, 0);
      if (fp && *fp) { s->xmapping.count= SvIV(*fp); } else carp("'%s' uninitialized", "count");
      fp= hv_fetch(fields, "first_keycode", 13, 0);
      if (fp && *fp) { s->xmapping.first_keycode= SvIV(*fp); } else carp("'%s' uninitialized", "first_keycode");
      fp= hv_fetch(fields, "request", 7, 0);
      if (fp && *fp) { s->xmapping.request= SvIV(*fp); } else carp("'%s' uninitialized", "request");
      break;
    case MotionNotify:
      fp= hv_fetch(fields, "is_hint", 7, 0);
      if (fp && *fp) { s->xmotion.is_hint= SvIV(*fp); } else carp("'%s' uninitialized", "is_hint");
      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xmotion.root= SvUV(*fp); } else carp("'%s' uninitialized", "root");
      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xmotion.same_screen= SvIV(*fp); } else carp("'%s' uninitialized", "same_screen");
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xmotion.state= SvUV(*fp); } else carp("'%s' uninitialized", "state");
      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xmotion.subwindow= SvUV(*fp); } else carp("'%s' uninitialized", "subwindow");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xmotion.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xmotion.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xmotion.x_root= SvIV(*fp); } else carp("'%s' uninitialized", "x_root");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xmotion.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xmotion.y_root= SvIV(*fp); } else carp("'%s' uninitialized", "y_root");
      break;
    case NoExpose:
      fp= hv_fetch(fields, "drawable", 8, 0);
      if (fp && *fp) { s->xnoexpose.drawable= SvUV(*fp); } else carp("'%s' uninitialized", "drawable");
      fp= hv_fetch(fields, "major_code", 10, 0);
      if (fp && *fp) { s->xnoexpose.major_code= SvIV(*fp); } else carp("'%s' uninitialized", "major_code");
      fp= hv_fetch(fields, "minor_code", 10, 0);
      if (fp && *fp) { s->xnoexpose.minor_code= SvIV(*fp); } else carp("'%s' uninitialized", "minor_code");
      break;
    case PropertyNotify:
      fp= hv_fetch(fields, "atom", 4, 0);
      if (fp && *fp) { s->xproperty.atom= SvUV(*fp); } else carp("'%s' uninitialized", "atom");
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xproperty.state= SvIV(*fp); } else carp("'%s' uninitialized", "state");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xproperty.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      break;
    case ReparentNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xreparent.event= SvUV(*fp); } else carp("'%s' uninitialized", "event");
      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xreparent.override_redirect= SvIV(*fp); } else carp("'%s' uninitialized", "override_redirect");
      fp= hv_fetch(fields, "parent", 6, 0);
      if (fp && *fp) { s->xreparent.parent= SvUV(*fp); } else carp("'%s' uninitialized", "parent");
      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xreparent.x= SvIV(*fp); } else carp("'%s' uninitialized", "x");
      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xreparent.y= SvIV(*fp); } else carp("'%s' uninitialized", "y");
      break;
    case ResizeRequest:
      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xresizerequest.height= SvIV(*fp); } else carp("'%s' uninitialized", "height");
      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xresizerequest.width= SvIV(*fp); } else carp("'%s' uninitialized", "width");
      break;
    case SelectionNotify:
      fp= hv_fetch(fields, "property", 8, 0);
      if (fp && *fp) { s->xselection.property= SvUV(*fp); } else carp("'%s' uninitialized", "property");
      fp= hv_fetch(fields, "requestor", 9, 0);
      if (fp && *fp) { s->xselection.requestor= SvUV(*fp); } else carp("'%s' uninitialized", "requestor");
      fp= hv_fetch(fields, "selection", 9, 0);
      if (fp && *fp) { s->xselection.selection= SvUV(*fp); } else carp("'%s' uninitialized", "selection");
      fp= hv_fetch(fields, "target", 6, 0);
      if (fp && *fp) { s->xselection.target= SvUV(*fp); } else carp("'%s' uninitialized", "target");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xselection.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      break;
    case SelectionClear:
      fp= hv_fetch(fields, "selection", 9, 0);
      if (fp && *fp) { s->xselectionclear.selection= SvUV(*fp); } else carp("'%s' uninitialized", "selection");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xselectionclear.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      break;
    case SelectionRequest:
      fp= hv_fetch(fields, "owner", 5, 0);
      if (fp && *fp) { s->xselectionrequest.owner= SvUV(*fp); } else carp("'%s' uninitialized", "owner");
      fp= hv_fetch(fields, "property", 8, 0);
      if (fp && *fp) { s->xselectionrequest.property= SvUV(*fp); } else carp("'%s' uninitialized", "property");
      fp= hv_fetch(fields, "requestor", 9, 0);
      if (fp && *fp) { s->xselectionrequest.requestor= SvUV(*fp); } else carp("'%s' uninitialized", "requestor");
      fp= hv_fetch(fields, "selection", 9, 0);
      if (fp && *fp) { s->xselectionrequest.selection= SvUV(*fp); } else carp("'%s' uninitialized", "selection");
      fp= hv_fetch(fields, "target", 6, 0);
      if (fp && *fp) { s->xselectionrequest.target= SvUV(*fp); } else carp("'%s' uninitialized", "target");
      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xselectionrequest.time= SvUV(*fp); } else carp("'%s' uninitialized", "time");
      break;
    case UnmapNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xunmap.event= SvUV(*fp); } else carp("'%s' uninitialized", "event");
      fp= hv_fetch(fields, "from_configure", 14, 0);
      if (fp && *fp) { s->xunmap.from_configure= SvIV(*fp); } else carp("'%s' uninitialized", "from_configure");
      break;
    case VisibilityNotify:
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xvisibility.state= SvIV(*fp); } else carp("'%s' uninitialized", "state");
      break;
    default:
      croak("Unknown XEvent type %d", s->type);
    }
}

void PerlXlib_XEvent_unpack(XEvent *s, HV *fields) {
    hv_store(fields, "type", 4, newSViv(s->type), 0);
    hv_store(fields, "window"    ,  6, newSVuv(s->xany.window), 0);
    hv_store(fields, "display"   ,  7, sv_setref_pv(newSV(0), "X11::Xlib", (void*)s->xany.display), 0);
    hv_store(fields, "serial"    ,  6, newSVuv(s->xany.serial), 0);
    hv_store(fields, "type"      ,  4, newSViv(s->xany.type), 0);
    hv_store(fields, "send_event", 10, newSViv(s->xany.send_event), 0);
    switch( s->type ) {
    case ButtonPress:
    case ButtonRelease:
      hv_store(fields, "button"     ,  6, newSVuv(s->xbutton.button), 0);
      hv_store(fields, "root"       ,  4, newSVuv(s->xbutton.root), 0);
      hv_store(fields, "same_screen", 11, newSViv(s->xbutton.same_screen), 0);
      hv_store(fields, "state"      ,  5, newSVuv(s->xbutton.state), 0);
      hv_store(fields, "subwindow"  ,  9, newSVuv(s->xbutton.subwindow), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xbutton.time), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xbutton.x), 0);
      hv_store(fields, "x_root"     ,  6, newSViv(s->xbutton.x_root), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xbutton.y), 0);
      hv_store(fields, "y_root"     ,  6, newSViv(s->xbutton.y_root), 0);
      break;
    case CirculateNotify:
      hv_store(fields, "event"      ,  5, newSVuv(s->xcirculate.event), 0);
      hv_store(fields, "place"      ,  5, newSViv(s->xcirculate.place), 0);
      break;
    case ClientMessage:
      hv_store(fields, "b"          ,  1, newSVpvn((void*)s->xclient.data.b, sizeof(char)*20), 0);
      hv_store(fields, "l"          ,  1, newSVpvn((void*)s->xclient.data.l, sizeof(long)*5), 0);
      hv_store(fields, "s"          ,  1, newSVpvn((void*)s->xclient.data.s, sizeof(short)*10), 0);
      hv_store(fields, "format"     ,  6, newSViv(s->xclient.format), 0);
      hv_store(fields, "message_type", 12, newSVuv(s->xclient.message_type), 0);
      break;
    case ColormapNotify:
      hv_store(fields, "colormap"   ,  8, newSVuv(s->xcolormap.colormap), 0);
      hv_store(fields, "new"        ,  3, newSViv(s->xcolormap.new), 0);
      hv_store(fields, "state"      ,  5, newSViv(s->xcolormap.state), 0);
      break;
    case ConfigureNotify:
      hv_store(fields, "above"      ,  5, newSVuv(s->xconfigure.above), 0);
      hv_store(fields, "border_width", 12, newSViv(s->xconfigure.border_width), 0);
      hv_store(fields, "event"      ,  5, newSVuv(s->xconfigure.event), 0);
      hv_store(fields, "height"     ,  6, newSViv(s->xconfigure.height), 0);
      hv_store(fields, "override_redirect", 17, newSViv(s->xconfigure.override_redirect), 0);
      hv_store(fields, "width"      ,  5, newSViv(s->xconfigure.width), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xconfigure.x), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xconfigure.y), 0);
      break;
    case CreateNotify:
      hv_store(fields, "border_width", 12, newSViv(s->xcreatewindow.border_width), 0);
      hv_store(fields, "height"     ,  6, newSViv(s->xcreatewindow.height), 0);
      hv_store(fields, "override_redirect", 17, newSViv(s->xcreatewindow.override_redirect), 0);
      hv_store(fields, "parent"     ,  6, newSVuv(s->xcreatewindow.parent), 0);
      hv_store(fields, "width"      ,  5, newSViv(s->xcreatewindow.width), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xcreatewindow.x), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xcreatewindow.y), 0);
      break;
    case LeaveNotify:
    case EnterNotify:
      hv_store(fields, "detail"     ,  6, newSViv(s->xcrossing.detail), 0);
      hv_store(fields, "focus"      ,  5, newSViv(s->xcrossing.focus), 0);
      hv_store(fields, "mode"       ,  4, newSViv(s->xcrossing.mode), 0);
      hv_store(fields, "root"       ,  4, newSVuv(s->xcrossing.root), 0);
      hv_store(fields, "same_screen", 11, newSViv(s->xcrossing.same_screen), 0);
      hv_store(fields, "state"      ,  5, newSVuv(s->xcrossing.state), 0);
      hv_store(fields, "subwindow"  ,  9, newSVuv(s->xcrossing.subwindow), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xcrossing.time), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xcrossing.x), 0);
      hv_store(fields, "x_root"     ,  6, newSViv(s->xcrossing.x_root), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xcrossing.y), 0);
      hv_store(fields, "y_root"     ,  6, newSViv(s->xcrossing.y_root), 0);
      break;
    case DestroyNotify:
      hv_store(fields, "event"      ,  5, newSVuv(s->xdestroywindow.event), 0);
      break;
    case Expose:
      hv_store(fields, "count"      ,  5, newSViv(s->xexpose.count), 0);
      hv_store(fields, "height"     ,  6, newSViv(s->xexpose.height), 0);
      hv_store(fields, "width"      ,  5, newSViv(s->xexpose.width), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xexpose.x), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xexpose.y), 0);
      break;
    case FocusOut:
    case FocusIn:
      hv_store(fields, "detail"     ,  6, newSViv(s->xfocus.detail), 0);
      hv_store(fields, "mode"       ,  4, newSViv(s->xfocus.mode), 0);
      break;
    case GraphicsExpose:
      hv_store(fields, "count"      ,  5, newSViv(s->xgraphicsexpose.count), 0);
      hv_store(fields, "drawable"   ,  8, newSVuv(s->xgraphicsexpose.drawable), 0);
      hv_store(fields, "height"     ,  6, newSViv(s->xgraphicsexpose.height), 0);
      hv_store(fields, "major_code" , 10, newSViv(s->xgraphicsexpose.major_code), 0);
      hv_store(fields, "minor_code" , 10, newSViv(s->xgraphicsexpose.minor_code), 0);
      hv_store(fields, "width"      ,  5, newSViv(s->xgraphicsexpose.width), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xgraphicsexpose.x), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xgraphicsexpose.y), 0);
      break;
    case GravityNotify:
      hv_store(fields, "event"      ,  5, newSVuv(s->xgravity.event), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xgravity.x), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xgravity.y), 0);
      break;
    case KeyRelease:
    case KeyPress:
      hv_store(fields, "keycode"    ,  7, newSVuv(s->xkey.keycode), 0);
      hv_store(fields, "root"       ,  4, newSVuv(s->xkey.root), 0);
      hv_store(fields, "same_screen", 11, newSViv(s->xkey.same_screen), 0);
      hv_store(fields, "state"      ,  5, newSVuv(s->xkey.state), 0);
      hv_store(fields, "subwindow"  ,  9, newSVuv(s->xkey.subwindow), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xkey.time), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xkey.x), 0);
      hv_store(fields, "x_root"     ,  6, newSViv(s->xkey.x_root), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xkey.y), 0);
      hv_store(fields, "y_root"     ,  6, newSViv(s->xkey.y_root), 0);
      break;
    case KeymapNotify:
      hv_store(fields, "key_vector" , 10, newSVpvn((void*)s->xkeymap.key_vector, sizeof(char)*32), 0);
      break;
    case MapNotify:
      hv_store(fields, "event"      ,  5, newSVuv(s->xmap.event), 0);
      hv_store(fields, "override_redirect", 17, newSViv(s->xmap.override_redirect), 0);
      break;
    case MappingNotify:
      hv_store(fields, "count"      ,  5, newSViv(s->xmapping.count), 0);
      hv_store(fields, "first_keycode", 13, newSViv(s->xmapping.first_keycode), 0);
      hv_store(fields, "request"    ,  7, newSViv(s->xmapping.request), 0);
      break;
    case MotionNotify:
      hv_store(fields, "is_hint"    ,  7, newSViv(s->xmotion.is_hint), 0);
      hv_store(fields, "root"       ,  4, newSVuv(s->xmotion.root), 0);
      hv_store(fields, "same_screen", 11, newSViv(s->xmotion.same_screen), 0);
      hv_store(fields, "state"      ,  5, newSVuv(s->xmotion.state), 0);
      hv_store(fields, "subwindow"  ,  9, newSVuv(s->xmotion.subwindow), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xmotion.time), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xmotion.x), 0);
      hv_store(fields, "x_root"     ,  6, newSViv(s->xmotion.x_root), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xmotion.y), 0);
      hv_store(fields, "y_root"     ,  6, newSViv(s->xmotion.y_root), 0);
      break;
    case NoExpose:
      hv_store(fields, "drawable"   ,  8, newSVuv(s->xnoexpose.drawable), 0);
      hv_store(fields, "major_code" , 10, newSViv(s->xnoexpose.major_code), 0);
      hv_store(fields, "minor_code" , 10, newSViv(s->xnoexpose.minor_code), 0);
      break;
    case PropertyNotify:
      hv_store(fields, "atom"       ,  4, newSVuv(s->xproperty.atom), 0);
      hv_store(fields, "state"      ,  5, newSViv(s->xproperty.state), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xproperty.time), 0);
      break;
    case ReparentNotify:
      hv_store(fields, "event"      ,  5, newSVuv(s->xreparent.event), 0);
      hv_store(fields, "override_redirect", 17, newSViv(s->xreparent.override_redirect), 0);
      hv_store(fields, "parent"     ,  6, newSVuv(s->xreparent.parent), 0);
      hv_store(fields, "x"          ,  1, newSViv(s->xreparent.x), 0);
      hv_store(fields, "y"          ,  1, newSViv(s->xreparent.y), 0);
      break;
    case ResizeRequest:
      hv_store(fields, "height"     ,  6, newSViv(s->xresizerequest.height), 0);
      hv_store(fields, "width"      ,  5, newSViv(s->xresizerequest.width), 0);
      break;
    case SelectionNotify:
      hv_store(fields, "property"   ,  8, newSVuv(s->xselection.property), 0);
      hv_store(fields, "requestor"  ,  9, newSVuv(s->xselection.requestor), 0);
      hv_store(fields, "selection"  ,  9, newSVuv(s->xselection.selection), 0);
      hv_store(fields, "target"     ,  6, newSVuv(s->xselection.target), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xselection.time), 0);
      break;
    case SelectionClear:
      hv_store(fields, "selection"  ,  9, newSVuv(s->xselectionclear.selection), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xselectionclear.time), 0);
      break;
    case SelectionRequest:
      hv_store(fields, "owner"      ,  5, newSVuv(s->xselectionrequest.owner), 0);
      hv_store(fields, "property"   ,  8, newSVuv(s->xselectionrequest.property), 0);
      hv_store(fields, "requestor"  ,  9, newSVuv(s->xselectionrequest.requestor), 0);
      hv_store(fields, "selection"  ,  9, newSVuv(s->xselectionrequest.selection), 0);
      hv_store(fields, "target"     ,  6, newSVuv(s->xselectionrequest.target), 0);
      hv_store(fields, "time"       ,  4, newSVuv(s->xselectionrequest.time), 0);
      break;
    case UnmapNotify:
      hv_store(fields, "event"      ,  5, newSVuv(s->xunmap.event), 0);
      hv_store(fields, "from_configure", 14, newSViv(s->xunmap.from_configure), 0);
      break;
    case VisibilityNotify:
      hv_store(fields, "state"      ,  5, newSViv(s->xvisibility.state), 0);
      break;
    default:
      carp("Unknown XEvent type %d", s->type);
    }
}

// END GENERATED X11_Xlib_XEvent
//----------------------------------------------------------------------------

