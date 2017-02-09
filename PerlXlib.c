// This file is included directly by Xlib.xs and is not intended to be
// externally usable.  I mostly separated it for the syntax hilighting :-)

void PerlXlib_XEvent_pack(XEvent *e, HV *fields);
void PerlXlib_XEvent_unpack(XEvent *e, HV *fields);

// unusual constants help identify our objects without an expensive check on class name
#define PerlXlib_CONN_LIVE   0x7FEDCB01
#define PerlXlib_CONN_DEAD   0x7FEDCB02
#define PerlXlib_CONN_CLOSED 0x7FEDCB03

// This object provides extra storage for flags associated with a Display*
//  and is what the perl \X11::Xlib scalar ref actually holds.
typedef struct PerlXlib_conn_s {
    Display *dpy;
    int state;
    int foreign: 1;
} PerlXlib_conn_t;

typedef Display* DisplayNotNull; // Used by typemap for stricter conversion
typedef void PerlXlib_struct_pack_fn(SV*, HV*);

// Potentially hot method.
// Allow either instance of X11::Xlib, or instance of X11::Xlib::Display
PerlXlib_conn_t* PerlXlib_get_conn_from_sv(SV *sv, Bool require_live) {
    SV **fp, *inner;
    PerlXlib_conn_t *conn;

    if (sv_isobject(sv)) {
        inner= (SV*) SvRV(sv);
        // find connection field in a hashref-based object
        if (SvTYPE(inner) == SVt_PVHV) {
            fp= hv_fetch((HV*)SvRV(sv), "connection", 10, 0);
            if (fp && *fp && sv_isobject(*fp))
                inner= SvRV(*fp);
        }
        if (SvTYPE(inner) == SVt_PVMG && SvCUR(inner) == sizeof(PerlXlib_conn_t)) {
            conn= (PerlXlib_conn_t*) SvPVX(inner);
            if (conn->state == PerlXlib_CONN_LIVE || !require_live)
                return conn;
            // Else, we either have one of our objects that is invalid, or something else.
            if (sv_derived_from(sv, "X11::Xlib")) {
                // If that was because Xlib fatal error, then give an even more specific error
                if (SvTRUE(get_sv("X11::Xlib::_error_fatal_trapped", GV_ADD)))
                    croak("Cannot call further Xlib functions after fatal Xlib error");
                switch (conn->state) {
                case PerlXlib_CONN_DEAD: croak("X11 connection is dead (but still allocated)");
                case PerlXlib_CONN_CLOSED: croak("X11 connection was closed");
                default: croak("Corrupted data in X11 connection object");
                }
            }
        }
    }
    //sv_dump(sv);
    croak("Invalid Display handle; must be a X11::Xlib instance or X11::Xlib::Display instance");
    return NULL; // make compiler happy
}
//#define PerlXlib_sv_to_display(x) PerlXlib_get_conn_from_sv(x,1)->dpy
#define PerlXlib_sv_to_display(x) (SvOK(x)? PerlXlib_get_conn_from_sv(x, 1)->dpy : NULL)

// Converting a Display* to a \X11::Xlib is difficult because we want
// to re-use the existing object.  We cache them in %X11::Xlib::_connections.
void PerlXlib_sv_from_display(SV *dest, Display *dpy) {
    SV **fp;
    PerlXlib_conn_t conn;
    if (!dpy) {
        // Translate NULL to undef
        sv_setsv(dest, &PL_sv_undef);
    }
    else {
        fp= hv_fetch(get_hv("X11::Xlib::_connections", GV_ADD), (void*) &dpy, sizeof(dpy), 1);
        // Return existing object if we have one for this Display* already
        if (!fp) croak("failed to add item to hash (tied?)");
        if (*fp && SvOK(*fp))
            sv_setsv(dest, *fp);
        // else create a new one, and register it in the _connections
        else {
            // Always create instance of X11::Xlib.  X11::Xlib::Display can override this as needed.
            conn.dpy= dpy;
            conn.state= PerlXlib_CONN_LIVE;
            conn.foreign= 0;
            sv_setref_pvn(dest, "X11::Xlib", (void*)&conn, sizeof(conn));
            // Save a weakref for later
            if (!*fp) *fp= newRV(SvRV(dest));
            else sv_setsv(*fp, dest);
            sv_rvweaken(*fp);
        }
    }
}

void PerlXlib_conn_mark_closed(PerlXlib_conn_t *conn) {
    if (conn->dpy) {
        conn->state= PerlXlib_CONN_CLOSED;
        // Now, we must also remove the object from the $_connections cache.
        // It's a weak reference, but if we leave it there then a new Display*
        // could get created at the same address and cause confusion.
        hv_delete(get_hv("X11::Xlib::_connections", GV_ADD),
            (void*) &(conn->dpy), sizeof(Display*), 0);
        hv_delete(get_hv("X11::Xlib::Display::_displays", GV_ADD),
            (void*) &(conn->dpy), sizeof(Display*), 0);
        conn->dpy= NULL;
    }
    return;
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

void* PerlXlib_get_struct_ptr(SV *sv, const char* pkg, int struct_size, PerlXlib_struct_pack_fn *packer) {
    void* buf;

    if (SvROK(sv)) {
        // Follow scalar refs, to get to the buffer of a blessed object
        if (SvTYPE(SvRV(sv)) == SVt_PVMG)
            sv= SvRV(sv);
            // continue below using this SV

        // Also accept a hashref, which we pass to "pack"
        else if (SvTYPE(SvRV(sv)) == SVt_PVHV) {
            // Need a buffer that lasts for the rest of our XS call stack.
            // Cheat by using a mortal SV :-)
            buf= SvPVX(sv_2mortal(newSV(struct_size)));
            pack(buf, (HV*) SvRV(sv));
            return buf;
        }
    }
    // If uninitialized, initialize to a blessed struct object
    else if (!SvOK(sv)) {
        sv= newSVrv(sv, pkg);
        // sv is now the referenced scalar, which is undef, and gets inflated next
    }
    
    if (!SvOK(sv)) {
        sv_setpvn(sv, "", 0);
        sv_grow(sv, struct_size+1);
        SvCUR_set(sv, struct_size);
        memset(SvPVX(sv), 0, struct_size+1);
    }
    else if (!SvPOK(sv))
        croak("Paramters requiring %s can only be coerced from scalar, scalar ref, hashref, or undef", pkg);
    else if (SvCUR(sv) < struct_size)
        croak("Scalars used as %s must be at least %d bytes long (got %d)",
            pkg, struct_size, SvCUR(sv));
    return SvPVX(sv);
}

int PerlXlib_X_error_handler(Display *d, XErrorEvent *e) {
    dSP;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    EXTEND(SP, 1);
    PUSHs(sv_2mortal(sv_setref_pvn(newSV(0), "X11::Xlib::XEvent::XErrorEvent", (void*) e, sizeof(XEvent))));
    PUTBACK;
    call_pv("X11::Xlib::_error_nonfatal", G_VOID|G_DISCARD|G_EVAL|G_KEEPERR);
    FREETMPS;
    LEAVE;
    return 0;
}

/*

What a mess.   So Xlib has a stupid design where they forcibly abort the
program when an I/O error occurs and the X server is lost.  Even if you
install the error handler, they expect you to abort the program and they
do it for you if you return.  Furthermore, they tell you that you may not
call any more Xlib functions at all.

Luckily we can cheat with croak (longjmp) back out of the callback and
avoid the forced program exit.  However now we can't officially use Xlib
again for the duration of the program, and there could be lost resources
from our longjmp.  So, set a global flag to prevent any re-entry into XLib.

*/
int PerlXlib_X_IO_error_handler(Display *d) {
    SV *conn;
    sv_setiv(get_sv("X11::Xlib::_error_fatal_trapped", GV_ADD), 1);
    warn("Xlib fatal error.  Further calls to Xlib are forbidden.");
    dSP;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    EXTEND(SP, 1);
    conn= sv_2mortal(newSV(0));
    PerlXlib_sv_from_display(conn, d);
    PUSHs(conn);
    PUTBACK;
    call_pv("X11::Xlib::_error_fatal", G_VOID|G_DISCARD|G_EVAL|G_KEEPERR);
    FREETMPS;
    LEAVE;
    croak("Fatal X11 I/O Error"); // longjmp past Xlib, which wants to kill us
    return 0; // never reached.  Make compiler happy.
}

// Install the Xlib error handlers, only if they have not already been installed.
// Use perl scalars to store this status, to avoid threading issues and to
// give users potential to inspect.
void PerlXlib_install_error_handlers(Bool nonfatal, Bool fatal) {
    SV *nonfatal_installed= get_sv("X11::Xlib::_error_nonfatal_installed", GV_ADD);
    SV *fatal_installed= get_sv("X11::Xlib::_error_fatal_installed", GV_ADD);
    if (nonfatal && !SvTRUE(nonfatal_installed)) {
        XSetErrorHandler(&PerlXlib_X_error_handler);
        sv_setiv(nonfatal_installed, 1);
    }
    if (fatal && !SvTRUE(fatal_installed)) {
        XSetIOErrorHandler(&PerlXlib_X_IO_error_handler);
        sv_setiv(fatal_installed, 1);
    }
}

//----------------------------------------------------------------------------
// BEGIN GENERATED X11_Xlib_XEvent

void PerlXlib_XEvent_pack(XEvent *s, HV *fields) {
    SV **fp;

    memset(s, 0, sizeof(*s)); // wipe the struct
      fp= hv_fetch(fields, "display", 7, 0);
      if (fp && *fp) { s->xany.display= PerlXlib_sv_to_display(*fp); }
      fp= hv_fetch(fields, "send_event", 10, 0);
      if (fp && *fp) { s->xany.send_event= SvIV(*fp); }
      fp= hv_fetch(fields, "serial", 6, 0);
      if (fp && *fp) { s->xany.serial= SvUV(*fp); }
      fp= hv_fetch(fields, "type", 4, 0);
      if (fp && *fp) { s->xany.type= SvIV(*fp); }
      fp= hv_fetch(fields, "window", 6, 0);
      if (fp && *fp) { s->xany.window= SvUV(*fp); }
    switch( s->type ) {
    case ButtonPress:
    case ButtonRelease:
      fp= hv_fetch(fields, "button", 6, 0);
      if (fp && *fp) { s->xbutton.button= SvUV(*fp); }

      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xbutton.root= SvUV(*fp); }

      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xbutton.same_screen= SvIV(*fp); }

      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xbutton.state= SvUV(*fp); }

      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xbutton.subwindow= SvUV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xbutton.time= SvUV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xbutton.x= SvIV(*fp); }

      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xbutton.x_root= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xbutton.y= SvIV(*fp); }

      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xbutton.y_root= SvIV(*fp); }

      break;
    case CirculateNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xcirculate.event= SvUV(*fp); }

      fp= hv_fetch(fields, "place", 5, 0);
      if (fp && *fp) { s->xcirculate.place= SvIV(*fp); }

      break;
    case ClientMessage:
      fp= hv_fetch(fields, "b", 1, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvCUR(*fp) != sizeof(char)*20)  croak("Expected scalar of length %d but got %d", sizeof(char)*20, SvCUR(*fp)); memcpy(s->xclient.data.b, SvPVX(*fp), sizeof(char)*20);} }

      fp= hv_fetch(fields, "l", 1, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvCUR(*fp) != sizeof(long)*5)  croak("Expected scalar of length %d but got %d", sizeof(long)*5, SvCUR(*fp)); memcpy(s->xclient.data.l, SvPVX(*fp), sizeof(long)*5);} }

      fp= hv_fetch(fields, "s", 1, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvCUR(*fp) != sizeof(short)*10)  croak("Expected scalar of length %d but got %d", sizeof(short)*10, SvCUR(*fp)); memcpy(s->xclient.data.s, SvPVX(*fp), sizeof(short)*10);} }

      fp= hv_fetch(fields, "format", 6, 0);
      if (fp && *fp) { s->xclient.format= SvIV(*fp); }

      fp= hv_fetch(fields, "message_type", 12, 0);
      if (fp && *fp) { s->xclient.message_type= SvUV(*fp); }

      break;
    case ColormapNotify:
      fp= hv_fetch(fields, "colormap", 8, 0);
      if (fp && *fp) { s->xcolormap.colormap= SvUV(*fp); }

      fp= hv_fetch(fields, "new", 3, 0);
      if (fp && *fp) { s->xcolormap.new= SvIV(*fp); }

      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xcolormap.state= SvIV(*fp); }

      break;
    case ConfigureNotify:
      fp= hv_fetch(fields, "above", 5, 0);
      if (fp && *fp) { s->xconfigure.above= SvUV(*fp); }

      fp= hv_fetch(fields, "border_width", 12, 0);
      if (fp && *fp) { s->xconfigure.border_width= SvIV(*fp); }

      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xconfigure.event= SvUV(*fp); }

      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xconfigure.height= SvIV(*fp); }

      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xconfigure.override_redirect= SvIV(*fp); }

      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xconfigure.width= SvIV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xconfigure.x= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xconfigure.y= SvIV(*fp); }

      break;
    case CreateNotify:
      fp= hv_fetch(fields, "border_width", 12, 0);
      if (fp && *fp) { s->xcreatewindow.border_width= SvIV(*fp); }

      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xcreatewindow.height= SvIV(*fp); }

      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xcreatewindow.override_redirect= SvIV(*fp); }

      fp= hv_fetch(fields, "parent", 6, 0);
      if (fp && *fp) { s->xcreatewindow.parent= SvUV(*fp); }

      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xcreatewindow.width= SvIV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xcreatewindow.x= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xcreatewindow.y= SvIV(*fp); }

      break;
    case EnterNotify:
    case LeaveNotify:
      fp= hv_fetch(fields, "detail", 6, 0);
      if (fp && *fp) { s->xcrossing.detail= SvIV(*fp); }

      fp= hv_fetch(fields, "focus", 5, 0);
      if (fp && *fp) { s->xcrossing.focus= SvIV(*fp); }

      fp= hv_fetch(fields, "mode", 4, 0);
      if (fp && *fp) { s->xcrossing.mode= SvIV(*fp); }

      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xcrossing.root= SvUV(*fp); }

      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xcrossing.same_screen= SvIV(*fp); }

      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xcrossing.state= SvUV(*fp); }

      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xcrossing.subwindow= SvUV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xcrossing.time= SvUV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xcrossing.x= SvIV(*fp); }

      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xcrossing.x_root= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xcrossing.y= SvIV(*fp); }

      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xcrossing.y_root= SvIV(*fp); }

      break;
    case DestroyNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xdestroywindow.event= SvUV(*fp); }

      break;
    case Expose:
      fp= hv_fetch(fields, "count", 5, 0);
      if (fp && *fp) { s->xexpose.count= SvIV(*fp); }

      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xexpose.height= SvIV(*fp); }

      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xexpose.width= SvIV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xexpose.x= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xexpose.y= SvIV(*fp); }

      break;
    case FocusIn:
    case FocusOut:
      fp= hv_fetch(fields, "detail", 6, 0);
      if (fp && *fp) { s->xfocus.detail= SvIV(*fp); }

      fp= hv_fetch(fields, "mode", 4, 0);
      if (fp && *fp) { s->xfocus.mode= SvIV(*fp); }

      break;
    case GraphicsExpose:
      fp= hv_fetch(fields, "count", 5, 0);
      if (fp && *fp) { s->xgraphicsexpose.count= SvIV(*fp); }

      fp= hv_fetch(fields, "drawable", 8, 0);
      if (fp && *fp) { s->xgraphicsexpose.drawable= SvUV(*fp); }

      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xgraphicsexpose.height= SvIV(*fp); }

      fp= hv_fetch(fields, "major_code", 10, 0);
      if (fp && *fp) { s->xgraphicsexpose.major_code= SvIV(*fp); }

      fp= hv_fetch(fields, "minor_code", 10, 0);
      if (fp && *fp) { s->xgraphicsexpose.minor_code= SvIV(*fp); }

      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xgraphicsexpose.width= SvIV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xgraphicsexpose.x= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xgraphicsexpose.y= SvIV(*fp); }

      break;
    case GravityNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xgravity.event= SvUV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xgravity.x= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xgravity.y= SvIV(*fp); }

      break;
    case KeyPress:
    case KeyRelease:
      fp= hv_fetch(fields, "keycode", 7, 0);
      if (fp && *fp) { s->xkey.keycode= SvUV(*fp); }

      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xkey.root= SvUV(*fp); }

      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xkey.same_screen= SvIV(*fp); }

      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xkey.state= SvUV(*fp); }

      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xkey.subwindow= SvUV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xkey.time= SvUV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xkey.x= SvIV(*fp); }

      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xkey.x_root= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xkey.y= SvIV(*fp); }

      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xkey.y_root= SvIV(*fp); }

      break;
    case KeymapNotify:
      fp= hv_fetch(fields, "key_vector", 10, 0);
      if (fp && *fp) { { if (!SvPOK(*fp) || SvCUR(*fp) != sizeof(char)*32)  croak("Expected scalar of length %d but got %d", sizeof(char)*32, SvCUR(*fp)); memcpy(s->xkeymap.key_vector, SvPVX(*fp), sizeof(char)*32);} }

      break;
    case MapNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xmap.event= SvUV(*fp); }

      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xmap.override_redirect= SvIV(*fp); }

      break;
    case MappingNotify:
      fp= hv_fetch(fields, "count", 5, 0);
      if (fp && *fp) { s->xmapping.count= SvIV(*fp); }

      fp= hv_fetch(fields, "first_keycode", 13, 0);
      if (fp && *fp) { s->xmapping.first_keycode= SvIV(*fp); }

      fp= hv_fetch(fields, "request", 7, 0);
      if (fp && *fp) { s->xmapping.request= SvIV(*fp); }

      break;
    case MotionNotify:
      fp= hv_fetch(fields, "is_hint", 7, 0);
      if (fp && *fp) { s->xmotion.is_hint= SvIV(*fp); }

      fp= hv_fetch(fields, "root", 4, 0);
      if (fp && *fp) { s->xmotion.root= SvUV(*fp); }

      fp= hv_fetch(fields, "same_screen", 11, 0);
      if (fp && *fp) { s->xmotion.same_screen= SvIV(*fp); }

      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xmotion.state= SvUV(*fp); }

      fp= hv_fetch(fields, "subwindow", 9, 0);
      if (fp && *fp) { s->xmotion.subwindow= SvUV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xmotion.time= SvUV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xmotion.x= SvIV(*fp); }

      fp= hv_fetch(fields, "x_root", 6, 0);
      if (fp && *fp) { s->xmotion.x_root= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xmotion.y= SvIV(*fp); }

      fp= hv_fetch(fields, "y_root", 6, 0);
      if (fp && *fp) { s->xmotion.y_root= SvIV(*fp); }

      break;
    case NoExpose:
      fp= hv_fetch(fields, "drawable", 8, 0);
      if (fp && *fp) { s->xnoexpose.drawable= SvUV(*fp); }

      fp= hv_fetch(fields, "major_code", 10, 0);
      if (fp && *fp) { s->xnoexpose.major_code= SvIV(*fp); }

      fp= hv_fetch(fields, "minor_code", 10, 0);
      if (fp && *fp) { s->xnoexpose.minor_code= SvIV(*fp); }

      break;
    case PropertyNotify:
      fp= hv_fetch(fields, "atom", 4, 0);
      if (fp && *fp) { s->xproperty.atom= SvUV(*fp); }

      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xproperty.state= SvIV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xproperty.time= SvUV(*fp); }

      break;
    case ReparentNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xreparent.event= SvUV(*fp); }

      fp= hv_fetch(fields, "override_redirect", 17, 0);
      if (fp && *fp) { s->xreparent.override_redirect= SvIV(*fp); }

      fp= hv_fetch(fields, "parent", 6, 0);
      if (fp && *fp) { s->xreparent.parent= SvUV(*fp); }

      fp= hv_fetch(fields, "x", 1, 0);
      if (fp && *fp) { s->xreparent.x= SvIV(*fp); }

      fp= hv_fetch(fields, "y", 1, 0);
      if (fp && *fp) { s->xreparent.y= SvIV(*fp); }

      break;
    case ResizeRequest:
      fp= hv_fetch(fields, "height", 6, 0);
      if (fp && *fp) { s->xresizerequest.height= SvIV(*fp); }

      fp= hv_fetch(fields, "width", 5, 0);
      if (fp && *fp) { s->xresizerequest.width= SvIV(*fp); }

      break;
    case SelectionNotify:
      fp= hv_fetch(fields, "property", 8, 0);
      if (fp && *fp) { s->xselection.property= SvUV(*fp); }

      fp= hv_fetch(fields, "requestor", 9, 0);
      if (fp && *fp) { s->xselection.requestor= SvUV(*fp); }

      fp= hv_fetch(fields, "selection", 9, 0);
      if (fp && *fp) { s->xselection.selection= SvUV(*fp); }

      fp= hv_fetch(fields, "target", 6, 0);
      if (fp && *fp) { s->xselection.target= SvUV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xselection.time= SvUV(*fp); }

      break;
    case SelectionClear:
      fp= hv_fetch(fields, "selection", 9, 0);
      if (fp && *fp) { s->xselectionclear.selection= SvUV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xselectionclear.time= SvUV(*fp); }

      break;
    case SelectionRequest:
      fp= hv_fetch(fields, "owner", 5, 0);
      if (fp && *fp) { s->xselectionrequest.owner= SvUV(*fp); }

      fp= hv_fetch(fields, "property", 8, 0);
      if (fp && *fp) { s->xselectionrequest.property= SvUV(*fp); }

      fp= hv_fetch(fields, "requestor", 9, 0);
      if (fp && *fp) { s->xselectionrequest.requestor= SvUV(*fp); }

      fp= hv_fetch(fields, "selection", 9, 0);
      if (fp && *fp) { s->xselectionrequest.selection= SvUV(*fp); }

      fp= hv_fetch(fields, "target", 6, 0);
      if (fp && *fp) { s->xselectionrequest.target= SvUV(*fp); }

      fp= hv_fetch(fields, "time", 4, 0);
      if (fp && *fp) { s->xselectionrequest.time= SvUV(*fp); }

      break;
    case UnmapNotify:
      fp= hv_fetch(fields, "event", 5, 0);
      if (fp && *fp) { s->xunmap.event= SvUV(*fp); }

      fp= hv_fetch(fields, "from_configure", 14, 0);
      if (fp && *fp) { s->xunmap.from_configure= SvIV(*fp); }

      break;
    case VisibilityNotify:
      fp= hv_fetch(fields, "state", 5, 0);
      if (fp && *fp) { s->xvisibility.state= SvIV(*fp); }

      break;
    default:
      croak("Unknown XEvent type %d", s->type);
    }
}

void PerlXlib_XEvent_unpack(XEvent *s, HV *fields) {
    // hv_store may return NULL if there is an error, or if the hash is tied.
    // If it does, we need to clean up the value!
    SV *sv= NULL;
    if (!hv_store(fields, "type", 4, (sv= newSViv(s->type)), 0)) goto store_fail;
    if (!hv_store(fields, "display"   ,  7, (sv=(s->xany.display? sv_setref_pv(newSV(0), "X11::Xlib", (void*)s->xany.display) : &PL_sv_undef)), 0)) goto store_fail;
    if (!hv_store(fields, "send_event", 10, (sv=newSViv(s->xany.send_event)), 0)) goto store_fail;
    if (!hv_store(fields, "serial"    ,  6, (sv=newSVuv(s->xany.serial)), 0)) goto store_fail;
    if (!hv_store(fields, "type"      ,  4, (sv=newSViv(s->xany.type)), 0)) goto store_fail;
    if (!hv_store(fields, "window"    ,  6, (sv=newSVuv(s->xany.window)), 0)) goto store_fail;
    switch( s->type ) {
    case ButtonPress:
    case ButtonRelease:
      if (!hv_store(fields, "button"     ,  6, (sv=newSVuv(s->xbutton.button)), 0)) goto store_fail;
      if (!hv_store(fields, "root"       ,  4, (sv=newSVuv(s->xbutton.root)), 0)) goto store_fail;
      if (!hv_store(fields, "same_screen", 11, (sv=newSViv(s->xbutton.same_screen)), 0)) goto store_fail;
      if (!hv_store(fields, "state"      ,  5, (sv=newSVuv(s->xbutton.state)), 0)) goto store_fail;
      if (!hv_store(fields, "subwindow"  ,  9, (sv=newSVuv(s->xbutton.subwindow)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xbutton.time)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xbutton.x)), 0)) goto store_fail;
      if (!hv_store(fields, "x_root"     ,  6, (sv=newSViv(s->xbutton.x_root)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xbutton.y)), 0)) goto store_fail;
      if (!hv_store(fields, "y_root"     ,  6, (sv=newSViv(s->xbutton.y_root)), 0)) goto store_fail;
      break;
    case CirculateNotify:
      if (!hv_store(fields, "event"      ,  5, (sv=newSVuv(s->xcirculate.event)), 0)) goto store_fail;
      if (!hv_store(fields, "place"      ,  5, (sv=newSViv(s->xcirculate.place)), 0)) goto store_fail;
      break;
    case ClientMessage:
      if (!hv_store(fields, "b"          ,  1, (sv=newSVpvn((void*)s->xclient.data.b, sizeof(char)*20)), 0)) goto store_fail;
      if (!hv_store(fields, "l"          ,  1, (sv=newSVpvn((void*)s->xclient.data.l, sizeof(long)*5)), 0)) goto store_fail;
      if (!hv_store(fields, "s"          ,  1, (sv=newSVpvn((void*)s->xclient.data.s, sizeof(short)*10)), 0)) goto store_fail;
      if (!hv_store(fields, "format"     ,  6, (sv=newSViv(s->xclient.format)), 0)) goto store_fail;
      if (!hv_store(fields, "message_type", 12, (sv=newSVuv(s->xclient.message_type)), 0)) goto store_fail;
      break;
    case ColormapNotify:
      if (!hv_store(fields, "colormap"   ,  8, (sv=newSVuv(s->xcolormap.colormap)), 0)) goto store_fail;
      if (!hv_store(fields, "new"        ,  3, (sv=newSViv(s->xcolormap.new)), 0)) goto store_fail;
      if (!hv_store(fields, "state"      ,  5, (sv=newSViv(s->xcolormap.state)), 0)) goto store_fail;
      break;
    case ConfigureNotify:
      if (!hv_store(fields, "above"      ,  5, (sv=newSVuv(s->xconfigure.above)), 0)) goto store_fail;
      if (!hv_store(fields, "border_width", 12, (sv=newSViv(s->xconfigure.border_width)), 0)) goto store_fail;
      if (!hv_store(fields, "event"      ,  5, (sv=newSVuv(s->xconfigure.event)), 0)) goto store_fail;
      if (!hv_store(fields, "height"     ,  6, (sv=newSViv(s->xconfigure.height)), 0)) goto store_fail;
      if (!hv_store(fields, "override_redirect", 17, (sv=newSViv(s->xconfigure.override_redirect)), 0)) goto store_fail;
      if (!hv_store(fields, "width"      ,  5, (sv=newSViv(s->xconfigure.width)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xconfigure.x)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xconfigure.y)), 0)) goto store_fail;
      break;
    case CreateNotify:
      if (!hv_store(fields, "border_width", 12, (sv=newSViv(s->xcreatewindow.border_width)), 0)) goto store_fail;
      if (!hv_store(fields, "height"     ,  6, (sv=newSViv(s->xcreatewindow.height)), 0)) goto store_fail;
      if (!hv_store(fields, "override_redirect", 17, (sv=newSViv(s->xcreatewindow.override_redirect)), 0)) goto store_fail;
      if (!hv_store(fields, "parent"     ,  6, (sv=newSVuv(s->xcreatewindow.parent)), 0)) goto store_fail;
      if (!hv_store(fields, "width"      ,  5, (sv=newSViv(s->xcreatewindow.width)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xcreatewindow.x)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xcreatewindow.y)), 0)) goto store_fail;
      break;
    case EnterNotify:
    case LeaveNotify:
      if (!hv_store(fields, "detail"     ,  6, (sv=newSViv(s->xcrossing.detail)), 0)) goto store_fail;
      if (!hv_store(fields, "focus"      ,  5, (sv=newSViv(s->xcrossing.focus)), 0)) goto store_fail;
      if (!hv_store(fields, "mode"       ,  4, (sv=newSViv(s->xcrossing.mode)), 0)) goto store_fail;
      if (!hv_store(fields, "root"       ,  4, (sv=newSVuv(s->xcrossing.root)), 0)) goto store_fail;
      if (!hv_store(fields, "same_screen", 11, (sv=newSViv(s->xcrossing.same_screen)), 0)) goto store_fail;
      if (!hv_store(fields, "state"      ,  5, (sv=newSVuv(s->xcrossing.state)), 0)) goto store_fail;
      if (!hv_store(fields, "subwindow"  ,  9, (sv=newSVuv(s->xcrossing.subwindow)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xcrossing.time)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xcrossing.x)), 0)) goto store_fail;
      if (!hv_store(fields, "x_root"     ,  6, (sv=newSViv(s->xcrossing.x_root)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xcrossing.y)), 0)) goto store_fail;
      if (!hv_store(fields, "y_root"     ,  6, (sv=newSViv(s->xcrossing.y_root)), 0)) goto store_fail;
      break;
    case DestroyNotify:
      if (!hv_store(fields, "event"      ,  5, (sv=newSVuv(s->xdestroywindow.event)), 0)) goto store_fail;
      break;
    case Expose:
      if (!hv_store(fields, "count"      ,  5, (sv=newSViv(s->xexpose.count)), 0)) goto store_fail;
      if (!hv_store(fields, "height"     ,  6, (sv=newSViv(s->xexpose.height)), 0)) goto store_fail;
      if (!hv_store(fields, "width"      ,  5, (sv=newSViv(s->xexpose.width)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xexpose.x)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xexpose.y)), 0)) goto store_fail;
      break;
    case FocusIn:
    case FocusOut:
      if (!hv_store(fields, "detail"     ,  6, (sv=newSViv(s->xfocus.detail)), 0)) goto store_fail;
      if (!hv_store(fields, "mode"       ,  4, (sv=newSViv(s->xfocus.mode)), 0)) goto store_fail;
      break;
    case GraphicsExpose:
      if (!hv_store(fields, "count"      ,  5, (sv=newSViv(s->xgraphicsexpose.count)), 0)) goto store_fail;
      if (!hv_store(fields, "drawable"   ,  8, (sv=newSVuv(s->xgraphicsexpose.drawable)), 0)) goto store_fail;
      if (!hv_store(fields, "height"     ,  6, (sv=newSViv(s->xgraphicsexpose.height)), 0)) goto store_fail;
      if (!hv_store(fields, "major_code" , 10, (sv=newSViv(s->xgraphicsexpose.major_code)), 0)) goto store_fail;
      if (!hv_store(fields, "minor_code" , 10, (sv=newSViv(s->xgraphicsexpose.minor_code)), 0)) goto store_fail;
      if (!hv_store(fields, "width"      ,  5, (sv=newSViv(s->xgraphicsexpose.width)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xgraphicsexpose.x)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xgraphicsexpose.y)), 0)) goto store_fail;
      break;
    case GravityNotify:
      if (!hv_store(fields, "event"      ,  5, (sv=newSVuv(s->xgravity.event)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xgravity.x)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xgravity.y)), 0)) goto store_fail;
      break;
    case KeyPress:
    case KeyRelease:
      if (!hv_store(fields, "keycode"    ,  7, (sv=newSVuv(s->xkey.keycode)), 0)) goto store_fail;
      if (!hv_store(fields, "root"       ,  4, (sv=newSVuv(s->xkey.root)), 0)) goto store_fail;
      if (!hv_store(fields, "same_screen", 11, (sv=newSViv(s->xkey.same_screen)), 0)) goto store_fail;
      if (!hv_store(fields, "state"      ,  5, (sv=newSVuv(s->xkey.state)), 0)) goto store_fail;
      if (!hv_store(fields, "subwindow"  ,  9, (sv=newSVuv(s->xkey.subwindow)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xkey.time)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xkey.x)), 0)) goto store_fail;
      if (!hv_store(fields, "x_root"     ,  6, (sv=newSViv(s->xkey.x_root)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xkey.y)), 0)) goto store_fail;
      if (!hv_store(fields, "y_root"     ,  6, (sv=newSViv(s->xkey.y_root)), 0)) goto store_fail;
      break;
    case KeymapNotify:
      if (!hv_store(fields, "key_vector" , 10, (sv=newSVpvn((void*)s->xkeymap.key_vector, sizeof(char)*32)), 0)) goto store_fail;
      break;
    case MapNotify:
      if (!hv_store(fields, "event"      ,  5, (sv=newSVuv(s->xmap.event)), 0)) goto store_fail;
      if (!hv_store(fields, "override_redirect", 17, (sv=newSViv(s->xmap.override_redirect)), 0)) goto store_fail;
      break;
    case MappingNotify:
      if (!hv_store(fields, "count"      ,  5, (sv=newSViv(s->xmapping.count)), 0)) goto store_fail;
      if (!hv_store(fields, "first_keycode", 13, (sv=newSViv(s->xmapping.first_keycode)), 0)) goto store_fail;
      if (!hv_store(fields, "request"    ,  7, (sv=newSViv(s->xmapping.request)), 0)) goto store_fail;
      break;
    case MotionNotify:
      if (!hv_store(fields, "is_hint"    ,  7, (sv=newSViv(s->xmotion.is_hint)), 0)) goto store_fail;
      if (!hv_store(fields, "root"       ,  4, (sv=newSVuv(s->xmotion.root)), 0)) goto store_fail;
      if (!hv_store(fields, "same_screen", 11, (sv=newSViv(s->xmotion.same_screen)), 0)) goto store_fail;
      if (!hv_store(fields, "state"      ,  5, (sv=newSVuv(s->xmotion.state)), 0)) goto store_fail;
      if (!hv_store(fields, "subwindow"  ,  9, (sv=newSVuv(s->xmotion.subwindow)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xmotion.time)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xmotion.x)), 0)) goto store_fail;
      if (!hv_store(fields, "x_root"     ,  6, (sv=newSViv(s->xmotion.x_root)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xmotion.y)), 0)) goto store_fail;
      if (!hv_store(fields, "y_root"     ,  6, (sv=newSViv(s->xmotion.y_root)), 0)) goto store_fail;
      break;
    case NoExpose:
      if (!hv_store(fields, "drawable"   ,  8, (sv=newSVuv(s->xnoexpose.drawable)), 0)) goto store_fail;
      if (!hv_store(fields, "major_code" , 10, (sv=newSViv(s->xnoexpose.major_code)), 0)) goto store_fail;
      if (!hv_store(fields, "minor_code" , 10, (sv=newSViv(s->xnoexpose.minor_code)), 0)) goto store_fail;
      break;
    case PropertyNotify:
      if (!hv_store(fields, "atom"       ,  4, (sv=newSVuv(s->xproperty.atom)), 0)) goto store_fail;
      if (!hv_store(fields, "state"      ,  5, (sv=newSViv(s->xproperty.state)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xproperty.time)), 0)) goto store_fail;
      break;
    case ReparentNotify:
      if (!hv_store(fields, "event"      ,  5, (sv=newSVuv(s->xreparent.event)), 0)) goto store_fail;
      if (!hv_store(fields, "override_redirect", 17, (sv=newSViv(s->xreparent.override_redirect)), 0)) goto store_fail;
      if (!hv_store(fields, "parent"     ,  6, (sv=newSVuv(s->xreparent.parent)), 0)) goto store_fail;
      if (!hv_store(fields, "x"          ,  1, (sv=newSViv(s->xreparent.x)), 0)) goto store_fail;
      if (!hv_store(fields, "y"          ,  1, (sv=newSViv(s->xreparent.y)), 0)) goto store_fail;
      break;
    case ResizeRequest:
      if (!hv_store(fields, "height"     ,  6, (sv=newSViv(s->xresizerequest.height)), 0)) goto store_fail;
      if (!hv_store(fields, "width"      ,  5, (sv=newSViv(s->xresizerequest.width)), 0)) goto store_fail;
      break;
    case SelectionNotify:
      if (!hv_store(fields, "property"   ,  8, (sv=newSVuv(s->xselection.property)), 0)) goto store_fail;
      if (!hv_store(fields, "requestor"  ,  9, (sv=newSVuv(s->xselection.requestor)), 0)) goto store_fail;
      if (!hv_store(fields, "selection"  ,  9, (sv=newSVuv(s->xselection.selection)), 0)) goto store_fail;
      if (!hv_store(fields, "target"     ,  6, (sv=newSVuv(s->xselection.target)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xselection.time)), 0)) goto store_fail;
      break;
    case SelectionClear:
      if (!hv_store(fields, "selection"  ,  9, (sv=newSVuv(s->xselectionclear.selection)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xselectionclear.time)), 0)) goto store_fail;
      break;
    case SelectionRequest:
      if (!hv_store(fields, "owner"      ,  5, (sv=newSVuv(s->xselectionrequest.owner)), 0)) goto store_fail;
      if (!hv_store(fields, "property"   ,  8, (sv=newSVuv(s->xselectionrequest.property)), 0)) goto store_fail;
      if (!hv_store(fields, "requestor"  ,  9, (sv=newSVuv(s->xselectionrequest.requestor)), 0)) goto store_fail;
      if (!hv_store(fields, "selection"  ,  9, (sv=newSVuv(s->xselectionrequest.selection)), 0)) goto store_fail;
      if (!hv_store(fields, "target"     ,  6, (sv=newSVuv(s->xselectionrequest.target)), 0)) goto store_fail;
      if (!hv_store(fields, "time"       ,  4, (sv=newSVuv(s->xselectionrequest.time)), 0)) goto store_fail;
      break;
    case UnmapNotify:
      if (!hv_store(fields, "event"      ,  5, (sv=newSVuv(s->xunmap.event)), 0)) goto store_fail;
      if (!hv_store(fields, "from_configure", 14, (sv=newSViv(s->xunmap.from_configure)), 0)) goto store_fail;
      break;
    case VisibilityNotify:
      if (!hv_store(fields, "state"      ,  5, (sv=newSViv(s->xvisibility.state)), 0)) goto store_fail;
      break;
    default:
      warn("Unknown XEvent type %d", s->type);
    }
    return;
    store_fail:
        if (sv) sv_2mortal(sv);
        croak("Can't store field in supplied hash (tied maybe?)");
}

// END GENERATED X11_Xlib_XEvent
//----------------------------------------------------------------------------
// BEGIN GENERATED X11_Xlib_XVisualInfo

void PerlXlib_XVisualInfo_pack(XVisualInfo *s, HV *fields) {
    SV **fp;

    memset(s, 0, sizeof(*s)); // wipe the struct
    fp= hv_fetch(fields, "bits_per_rgb", 12, 0);
    if (fp && *fp) { s->bits_per_rgb= SvIV(*fp); }
    fp= hv_fetch(fields, "blue_mask", 9, 0);
    if (fp && *fp) { s->blue_mask= SvUV(*fp); }
    fp= hv_fetch(fields, "class", 5, 0);
    if (fp && *fp) { s->class= SvIV(*fp); }
    fp= hv_fetch(fields, "colormap_size", 13, 0);
    if (fp && *fp) { s->colormap_size= SvIV(*fp); }
    fp= hv_fetch(fields, "depth", 5, 0);
    if (fp && *fp) { s->depth= SvIV(*fp); }
    fp= hv_fetch(fields, "green_mask", 10, 0);
    if (fp && *fp) { s->green_mask= SvUV(*fp); }
    fp= hv_fetch(fields, "red_mask", 8, 0);
    if (fp && *fp) { s->red_mask= SvUV(*fp); }
    fp= hv_fetch(fields, "screen", 6, 0);
    if (fp && *fp) { s->screen= SvIV(*fp); }
    fp= hv_fetch(fields, "visual", 6, 0);
    if (fp && *fp) { { if (!SvPOK(*fp) || SvCUR(*fp) != sizeof(Visual *))  croak("Expected scalar of length %d but got %d", sizeof(Visual *), SvCUR(*fp)); s->visual= * (Visual * *) SvPVX(*fp);} }
    fp= hv_fetch(fields, "visualid", 8, 0);
    if (fp && *fp) { s->visualid= SvUV(*fp); }

}

void PerlXlib_XVisualInfo_unpack(XVisualInfo *s, HV *fields) {
    // hv_store may return NULL if there is an error, or if the hash is tied.
    // If it does, we need to clean up the value.
    SV *sv= NULL;
    if (!hv_store(fields, "bits_per_rgb", 12, (sv=newSViv(s->bits_per_rgb)), 0)) goto store_fail;
    if (!hv_store(fields, "blue_mask" ,  9, (sv=newSVuv(s->blue_mask)), 0)) goto store_fail;
    if (!hv_store(fields, "class"     ,  5, (sv=newSViv(s->class)), 0)) goto store_fail;
    if (!hv_store(fields, "colormap_size", 13, (sv=newSViv(s->colormap_size)), 0)) goto store_fail;
    if (!hv_store(fields, "depth"     ,  5, (sv=newSViv(s->depth)), 0)) goto store_fail;
    if (!hv_store(fields, "green_mask", 10, (sv=newSVuv(s->green_mask)), 0)) goto store_fail;
    if (!hv_store(fields, "red_mask"  ,  8, (sv=newSVuv(s->red_mask)), 0)) goto store_fail;
    if (!hv_store(fields, "screen"    ,  6, (sv=newSViv(s->screen)), 0)) goto store_fail;
    if (!hv_store(fields, "visual"    ,  6, (sv=newSVpvn((void*) &s->visual, sizeof(Visual *))), 0)) goto store_fail;
    if (!hv_store(fields, "visualid"  ,  8, (sv=newSVuv(s->visualid)), 0)) goto store_fail;
    return;
    store_fail:
        if (sv) sv_2mortal(sv);
        croak("Can't store field in supplied hash (tied maybe?)");
}

// END GENERATED X11_Xlib_XVisualInfo
//----------------------------------------------------------------------------
