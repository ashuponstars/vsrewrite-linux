// VS Rewrite Linux: makes SDL's OpenGL window use a 32-bit ARGB X visual, so a compositor can show the desktop
// through the window's see-through (alpha 0) parts. SDL picks the first fbconfig glXChooseFBConfig returns, and the
// 24-bit visual (with an alpha channel the compositor ignores) comes first. This puts a 32-bit TrueColor one first.
// Loaded with LD_PRELOAD; changes nothing when no such config exists.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <string.h>
#include <stdlib.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <GL/glx.h>
#include <stdio.h>

typedef void *(*dlsym_fn)(void *, const char *);
typedef void (*(*gpa_fn)(const GLubyte *))(void);
static dlsym_fn real_dlsym;
static gpa_fn real_gpa;

static void init_real(void)
{
	if (real_dlsym) return;
	real_dlsym = (dlsym_fn)dlvsym(RTLD_NEXT, "dlsym", "GLIBC_2.2.5");
	if (!real_dlsym) real_dlsym = (dlsym_fn)dlvsym(RTLD_NEXT, "dlsym", "GLIBC_2.34");
}

static GLXFBConfig *my_choose(Display *d, int screen, const int *attribs, int *n)
{
	typedef GLXFBConfig *(*choose_fn)(Display *, int, const int *, int *);
	typedef XVisualInfo *(*getvis_fn)(Display *, GLXFBConfig);
	if (getenv("VSR_ARGB_DEBUG")) fprintf(stderr, "[argb] glXChooseFBConfig hooked\n");
	choose_fn real = (choose_fn)real_gpa((const GLubyte *)"glXChooseFBConfig");
	GLXFBConfig *c = real(d, screen, attribs, n);
	if (!c || !n || *n < 2 || getenv("VSR_NO_ARGB")) return c;
	int wantAlpha = 0;
	for (const int *p = attribs; p && *p; p += 2)
		if (*p == GLX_ALPHA_SIZE && p[1] > 0) wantAlpha = 1;
	if (!wantAlpha) return c;
	getvis_fn gv = (getvis_fn)real_gpa((const GLubyte *)"glXGetVisualFromFBConfig");
	if (!gv) return c;
	for (int i = 0; i < *n; i++)
	{
		XVisualInfo *vi = gv(d, c[i]);
		if (getenv("VSR_ARGB_DEBUG") && vi) fprintf(stderr, "[argb] cfg %d visual 0x%lx depth %d class %d\n", i, vi->visualid, vi->depth, vi->class);
		int ok = vi && vi->depth == 32 && vi->class == TrueColor;
		if (vi) XFree(vi);
		if (ok)
		{
			if (i) { GLXFBConfig t = c[0]; c[0] = c[i]; c[i] = t; }
			break;
		}
	}
	return c;
}

static XVisualInfo *my_choosevisual(Display *d, int screen, int *attribs)
{
	typedef XVisualInfo *(*cv_fn)(Display *, int, int *);
	cv_fn real = (cv_fn)real_gpa((const GLubyte *)"glXChooseVisual");
	XVisualInfo *v = real(d, screen, attribs);
	if (getenv("VSR_ARGB_DEBUG")) fprintf(stderr, "[argb] glXChooseVisual -> depth %d class %d\n", v ? v->depth : -1, v ? v->class : -1);
	if (!v || v->depth == 32 || getenv("VSR_NO_ARGB")) return v;
	int wantAlpha = 0;
	for (const int *p = attribs; p && *p; p++)
		if (*p == GLX_ALPHA_SIZE && p[1] > 0) wantAlpha = 1;
	if (!wantAlpha) return v;
	XVisualInfo tmpl;
	if (XMatchVisualInfo(d, screen, 32, TrueColor, &tmpl))
	{
		int n = 0;
		XVisualInfo q; q.visualid = tmpl.visualid;
		XVisualInfo *nv = XGetVisualInfo(d, VisualIDMask, &q, &n);
		if (nv) { if (getenv("VSR_ARGB_DEBUG")) fprintf(stderr, "[argb] using 32-bit visual 0x%lx\n", nv->visualid); XFree(v); return nv; }
	}
	return v;
}

static void (*my_gpa(const GLubyte *name))(void)
{
	if (getenv("VSR_ARGB_DEBUG")) fprintf(stderr, "[argb] gpa %s\n", name ? (const char *)name : "(null)");
	if (name && !strcmp((const char *)name, "glXChooseVisual")) return (void (*)(void))my_choosevisual;
	if (name && !strcmp((const char *)name, "glXChooseFBConfig")) return (void (*)(void))my_choose;
	return real_gpa(name);
}

void *dlsym(void *handle, const char *name)
{
	init_real();
	void *r = real_dlsym(handle, name);
	if (getenv("VSR_ARGB_DEBUG") && name && !strncmp(name, "glX", 3)) fprintf(stderr, "[argb] dlsym %s -> %p\n", name, r);
	if (r && name && (!strcmp(name, "glXGetProcAddressARB") || !strcmp(name, "glXGetProcAddress")))
	{
		real_gpa = (gpa_fn)r;
		return (void *)my_gpa;
	}
	return r;
}
