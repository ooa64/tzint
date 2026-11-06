#
# Include the TEA standard macro set
#

builtin(include,tclconfig/tcl.m4)

#
# Add here whatever m4 macros you want to define for your package
#

#------------------------------------------------------------------------
# TZINT_PATH_PNG --
#
#	Locate the PNG library and header files
#
# Arguments:
#	none
#
# Results:
#
#	Adds the following arguments to configure:
#		--enable-filecmd
#		--with-png-include=...
#		--with-png-lib=...
#		--enable-pngstatic
#
#	Defines the following vars:
#		PNG_INC_DIR	Full path to the directory containing png.h
#		PNG_LIB_DIR	Full path to the directory containing libpng
#
#	Sets up TEA_ADD_INCLUDES and TEA_ADD_LIBS accordingly
#	Defines NO_CMD_FILE if filecmd is disabled
#------------------------------------------------------------------------

AC_DEFUN([TZINT_PATH_PNG], [
    AC_ARG_ENABLE(filecmd,
	[  --enable-filecmd         with file command (png lib needed) (default: on)],
	[enable_filecmd=$enableval],
	[enable_filecmd=yes])

    if test "$enable_filecmd" = "no"; then
	# Without the file command nothing writes a raster file, so libpng is not
	# needed either. ZINT_NO_PNG makes the backend leave png.c empty and
	# report the missing support through ZBarcode_NoPng().
	AC_DEFINE(NO_CMD_FILE)
	AC_DEFINE(ZINT_NO_PNG)
    else
	AC_ARG_WITH(png-include,
	    [  --with-png-include=DIR   PNG includes are in DIR],
	    [PNG_INC_DIR=$withval],
	    [PNG_INC_DIR=""])

	AC_ARG_WITH(png-lib,
	    [  --with-png-lib=DIR       PNG libraries are in DIR],
	    [PNG_LIB_DIR=$withval],
	    [PNG_LIB_DIR=""])

	AC_ARG_ENABLE(pngstatic,
	    [  --enable-pngstatic       link static with libpng.a (default: off)],
	    [png_static=$enableval],
	    [png_static=no])

    #--------------------------------------------------------------------
    # Search for png.h in common locations
    #--------------------------------------------------------------------
    # pkg-config knows where the distribution put libpng and is asked first;
    # the directory list below is the fallback where it is absent or silent
    if test "x${PNG_INC_DIR}" = "x" ; then
	AC_PATH_PROG(PKG_CONFIG, pkg-config, none)
	if test "${PKG_CONFIG}" != "none" && ${PKG_CONFIG} --exists libpng ; then
	    png_pkg_inc=`${PKG_CONFIG} --variable=includedir libpng 2>/dev/null`
	    if test "x${png_pkg_inc}" != "x" && test -f "${png_pkg_inc}/png.h" ; then
		PNG_INC_DIR="${png_pkg_inc}"
	    fi
	fi
    fi

    AC_MSG_CHECKING([for png header])

    png_inc_search="/usr/include /usr/local/include /opt/local/include /opt/homebrew/include /usr/include/libpng16 /usr/local/include/libpng16"

    if test "x${PNG_INC_DIR}" = "x" ; then
	for dir in $png_inc_search ; do
	    if test -f "$dir/png.h" ; then
		PNG_INC_DIR="$dir"
		break
	    fi
	done
    fi

    if test "x${PNG_INC_DIR}" = "x" || test ! -f "${PNG_INC_DIR}/png.h" ; then
	AC_MSG_RESULT([no])
	AC_MSG_ERROR([Cannot find png.h.

Searched: ${png_inc_search}

On Debian and Ubuntu the runtime package libpng16-16 does not carry the
headers; install the development package as well:

    apt install libpng-dev

Give the directory with --with-png-include=DIR if it is elsewhere, or build
without the file command and its PNG dependency using --enable-filecmd=no.])
    fi

    AC_MSG_RESULT([${PNG_INC_DIR}])
    TEA_ADD_INCLUDES([-I"${PNG_INC_DIR}"])

    #--------------------------------------------------------------------
    # Search for libpng in common locations
    #--------------------------------------------------------------------
    if test "x${PNG_LIB_DIR}" = "x" && test "$png_static" != "yes" ; then
	if test "${PKG_CONFIG}" != "none" && test "x${PKG_CONFIG}" != "x" \
		&& ${PKG_CONFIG} --exists libpng ; then
	    png_pkg_lib=`${PKG_CONFIG} --variable=libdir libpng 2>/dev/null`
	    if test "x${png_pkg_lib}" != "x" && test -d "${png_pkg_lib}" ; then
		PNG_LIB_DIR="${png_pkg_lib}"
	    fi
	fi
    fi

    AC_MSG_CHECKING([for libpng library])

    png_lib_search="/usr/lib /usr/local/lib /opt/local/lib /opt/homebrew/lib /usr/lib/x86_64-linux-gnu /usr/lib/aarch64-linux-gnu"

    if test "x${PNG_LIB_DIR}" = "x" ; then
	if test "$png_static" = "yes"; then
	    png_lib_name="libpng.a"
	else
	    png_lib_name="libpng${TCL_SHLIB_SUFFIX}"
	fi

	for dir in $png_lib_search ; do
	    if test -f "$dir/$png_lib_name" ; then
		PNG_LIB_DIR="$dir"
		break
	    fi
	    # Also try with version suffix
	    if test -f "$dir/libpng16${TCL_SHLIB_SUFFIX}" ; then
		PNG_LIB_DIR="$dir"
		break
	    fi
	done
    fi

    if test "x${PNG_LIB_DIR}" = "x" ; then
	AC_MSG_RESULT([no])
	AC_MSG_ERROR([Cannot find libpng.

Searched: ${png_lib_search}

Give the directory with --with-png-lib=DIR, or build without the file command
and its PNG dependency using --enable-filecmd=no.])
    fi

    # Verify the library exists
    if test "$png_static" = "yes"; then
	if test ! -f "${PNG_LIB_DIR}/libpng.a" ; then
	    AC_MSG_ERROR([Cannot find libpng.a in ${PNG_LIB_DIR}])
	fi
	AC_MSG_RESULT([${PNG_LIB_DIR}/libpng.a (static)])
	TEA_ADD_LIBS([${PNG_LIB_DIR}/libpng.a])
    else
	if test ! -f "${PNG_LIB_DIR}/libpng${TCL_SHLIB_SUFFIX}" && test ! -f "${PNG_LIB_DIR}/libpng16${TCL_SHLIB_SUFFIX}" ; then
	    AC_MSG_ERROR([Cannot find libpng${TCL_SHLIB_SUFFIX} in ${PNG_LIB_DIR}])
	fi
	AC_MSG_RESULT([${PNG_LIB_DIR}])
	TEA_ADD_LIBS([-L"${PNG_LIB_DIR}" -lpng])
    fi
    fi
])
