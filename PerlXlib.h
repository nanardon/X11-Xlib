/*
 * This header defines the "C API" for this module.  It might be safe to copy
 * this header to other dists and use these functions, but I'm not making API
 * promises yet.
 */

// This object provides extra storage for flags associated with a Display*
//  and is what the perl \X11::Xlib scalar ref actually holds.
typedef struct PerlXlib_conn_s {
    Display *dpy;
    int state;
    int foreign: 1;
} PerlXlib_conn_t;

// unusual constants help identify our objects without an expensive check on class name
#define PerlXlib_CONN_LIVE    0x7FEDCB01
#define PerlXlib_CONN_DEAD    0x7FEDCB02
#define PerlXlib_CONN_CLOSED  0x7FEDCB03

typedef Display* DisplayOrNull; // Used by typemap for stricter conversion
typedef void PerlXlib_struct_pack_fn(SV*, HV*, Bool consume);

PerlXlib_conn_t* PerlXlib_get_conn_from_sv(SV *sv, Bool require_live);
#define PerlXlib_sv_to_display(x) (SvOK(x)? PerlXlib_get_conn_from_sv(x, 1)->dpy : NULL)
SV * PerlXlib_sv_from_display(SV *dest, Display *dpy);
SV * PerlXlib_sv_assign_conn(SV *dest, Display *dpy, bool foreign);
void PerlXlib_conn_mark_closed(PerlXlib_conn_t *conn);
XID PerlXlib_sv_to_xid(SV *sv);

void* PerlXlib_get_struct_ptr(SV *sv, const char* pkg, int struct_size, PerlXlib_struct_pack_fn *packer);
void PerlXlib_install_error_handlers(Bool nonfatal, Bool fatal);
const char* PerlXlib_xevent_pkg_for_type(int type);
void PerlXlib_XEvent_pack(XEvent *s, HV *fields, Bool consume);
void PerlXlib_XEvent_unpack(XEvent *s, HV *fields);
void PerlXlib_XVisualInfo_pack(XVisualInfo *s, HV *fields, Bool consume);
void PerlXlib_XVisualInfo_unpack(XVisualInfo *s, HV *fields);
void PerlXlib_XSetWindowAttributes_pack(XSetWindowAttributes *s, HV *fields, Bool consume);
void PerlXlib_XSetWindowAttributes_unpack(XSetWindowAttributes *s, HV *fields);
void PerlXlib_XSizeHints_pack(XSizeHints *s, HV *fields, Bool consume);
void PerlXlib_XSizeHints_unpack(XSizeHints *s, HV *fields);
