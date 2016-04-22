# -------------------------------------------------------------
# Hdf5 library
# -------------------------------------------------------------
AC_DEFUN([CONFIGURE_HDF5],
[
  AC_ARG_ENABLE(hdf5,
                AS_HELP_STRING([--disable-hdf5],
                               [build without HDF5 support]),
                [case "${enableval}" in
                  yes)  enablehdf5=yes ;;
                  no)  enablehdf5=no ;;
                  *)  AC_MSG_ERROR(bad value ${enableval} for --enable-hdf5) ;;
                esac],
                [enablehdf5=$enableoptional])

  if (test $enablehdf5 = yes); then
    AX_PATH_HDF5(1.8.0,1.8.12,no)
    if (test "x$HAVE_HDF5" = "x0"); then
      enablehdf5=no
      AC_MSG_RESULT(<<< HDF5 support not found or disabled >>>)
    else
      AC_MSG_RESULT(<<< Configuring library with HDF5 support >>>)
    fi
  fi
])




# SYNOPSIS
#
#   Test for HDF5
#
#   AX_PATH_HDF5( <Minimum Required Version>, <Maximum Allowed Version>, <package-required=yes/no> )
#
# DESCRIPTION
#
#   Provides a --with-hdf5=DIR option and minimum version check for
#   the HDF I/O library. Searches --with-hdf5, $HDF5_DIR, and the
#   usual places for HDF5 headers and libraries.
#
#   On success, sets HDF5_CFLAGS, HDF5_LIBS, and #defines HAVE_HDF5.
#   Assumes package is optional unless overridden with $3=yes.
#
# LAST MODIFICATION
#
#   $Id: hdf5_new.m4 31520 2012-06-28 14:53:30Z mpanesi $
#
# COPYLEFT
#
#   Copyright (c) 2013 Roy H. Stogner <roystgnr@ices.utexas.edu>
#   Copyright (c) 2010 Karl W. Schulz <karl@ices.utexas.edu>
#   Copyright (c) 2009 Rhys Ulerich <rhys.ulerich@gmail.com>
#   Copyright (c) 2008 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2008 Caolan McNamara <caolan@skynet.ie>
#   Copyright (c) 2008 Alexandre Duret-Lutz <adl@gnu.org>
#   Copyright (c) 2008 Matthew Mueller <donut@azstarnet.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.

AC_DEFUN([AX_PATH_HDF5],
[

HAVE_HDF5=0

AC_ARG_VAR(HDF5_DIR,[root directory of HDF5 installation])

AC_ARG_WITH(hdf5,
  [AS_HELP_STRING([--with-hdf5=DIR],[root directory of HDF5 installation (default = HDF5_DIR)])],
  dnl action-if-given
  [
    with_hdf5=$withval
    if test "${with_hdf5}" != yes; then
      HDF5_PREFIX=$withval
    fi
  ],
  dnl action-if-not-given
  [
    # This is "no" if the user did not specify --with-hdf5=foo
    with_hdf5=$withval

    # If $HDF5_DIR is set in the user's environment, then treat that
    # as though they had said --with-hdf5=$HDF5_DIR.
    if test "x${HDF5_DIR}" != "x"; then
      HDF5_PREFIX=${HDF5_DIR}
      with_hdf5=yes
    fi
  ])

# package requirement; if not specified, the default is to assume that
# the package is optional

# GNU-m4 ifelse documentation:
# ifelse (string-1, string-2, equal, [not-equal])
# If string-1 and string-2 are equal (character for character),
# expands to the string in 'equal', otherwise to the string in
# 'not-equal'.
is_package_required=ifelse([$3], ,no, $3)

AC_MSG_RESULT([Debugging: with_hdf5 = $with_hdf5])

if test "${with_hdf5}" != no ; then

    if test -d "${HDF5_PREFIX}/lib" ; then
       HDF5_LIBS="-L${HDF5_PREFIX}/lib -lhdf5 -Wl,-rpath,${HDF5_PREFIX}/lib"
       HDF5_FLIBS="-L${HDF5_PREFIX}/lib -lhdf5_fortran -Wl,-rpath,${HDF5_PREFIX}/lib"
       HDF5_CXXLIBS="-L${HDF5_PREFIX}/lib -lhdf5_cpp -Wl,-rpath,${HDF5_PREFIX}/lib"
    fi

    if test -d "${HDF5_PREFIX}/include" ; then
        HDF5_CPPFLAGS="-I${HDF5_PREFIX}/include"
    fi

    ac_HDF5_save_CFLAGS="$CFLAGS"
    ac_HDF5_save_CPPFLAGS="$CPPFLAGS"
    ac_HDF5_save_LDFLAGS="$LDFLAGS"
    ac_HDF5_save_LIBS="$LIBS"

    CFLAGS="${HDF5_CPPFLAGS} ${CFLAGS}"
    CPPFLAGS="${HDF5_CPPFLAGS} ${CPPFLAGS}"
    LDFLAGS="${HDF5_LIBS} ${LDFLAGS}"
    AC_LANG_PUSH([C])
    AC_CHECK_HEADER([hdf5.h],[found_header=yes],[found_header=no])

    #------------------------------
    # Minimum/Maximum version check
    #------------------------------

    min_hdf5_version=ifelse([$1], ,1.8.0, $1)
    max_hdf5_version=ifelse([$2], ,1.8.0, $2)

    AC_MSG_CHECKING([for $min_hdf5_version <= HDF5 <= $max_hdf5_version])

    # Strip the major.minor.micro version numbers out of the min version string
    MAJOR_VER=`echo $min_hdf5_version | sed 's/^\([[0-9]]*\).*/\1/'`
    if test "x${MAJOR_VER}" = "x" ; then
       MAJOR_VER=0
    fi

    MINOR_VER=`echo $min_hdf5_version | sed 's/^\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\).*/\2/'`
    if test "x${MINOR_VER}" = "x" ; then
       MINOR_VER=0
    fi

    MICRO_VER=`echo $min_hdf5_version | sed 's/^\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\).*/\3/'`
    if test "x${MICRO_VER}" = "x" ; then
       MICRO_VER=0
    fi

    # Strip the major.minor.micro version numbers out of the max version string
    MAJOR_VER_MAX=`echo $max_hdf5_version | sed 's/^\([[0-9]]*\).*/\1/'`
    if test "x${MAJOR_VER_MAX}" = "x" ; then
       MAJOR_VER_MAX=0
    fi

    MINOR_VER_MAX=`echo $max_hdf5_version | sed 's/^\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\).*/\2/'`
    if test "x${MINOR_VER_MAX}" = "x" ; then
       MINOR_VER_MAX=0
    fi

    MICRO_VER_MAX=`echo $max_hdf5_version | sed 's/^\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\)\.\{0,1\}\([[0-9]]*\).*/\3/'`
    if test "x${MICRO_VER_MAX}" = "x" ; then
       MICRO_VER_MAX=0
    fi

    # begin additional test(s) if header if available

    succeeded=no
    AC_LANG_PUSH([C])

    if test "x${found_header}" = "xyes" ; then
      min_version_succeeded=no
      max_version_succeeded=no

      # Test that HDF5 version is greater than or equal to the required min version.
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        @%:@include <hdf5.h>
            ]], [[
            @%:@if H5_VERS_MAJOR > $MAJOR_VER
            /* Sweet nibblets */
            @%:@elif (H5_VERS_MAJOR >= $MAJOR_VER) && (H5_VERS_MINOR >= $MINOR_VER) && (H5_VERS_RELEASE >= $MICRO_VER)
            /* Winner winner, chicken dinner */
            @%:@else
            @%:@  error HDF5 version is too old
            @%:@endif
        ]])],[
            min_version_succeeded=yes
        ],[
            min_version_succeeded=no
        ])

      # Test that HDF5 version is less than or equal to the required max version.
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        @%:@include <hdf5.h>
            ]], [[
            @%:@if H5_VERS_MAJOR > $MAJOR_VER_MAX
            @%:@  error HDF5 version is too new
            @%:@elif (H5_VERS_MAJOR == $MAJOR_VER_MAX) && (H5_VERS_MINOR > $MINOR_VER_MAX)
            @%:@  error HDF5 version is too new
            @%:@elif (H5_VERS_MAJOR == $MAJOR_VER_MAX) && (H5_VERS_MINOR == $MINOR_VER_MAX) && (H5_VERS_RELEASE > $MICRO_VER_MAX)
            @%:@  error HDF5 version is too new
            @%:@else
            /* It should work */
            @%:@endif
        ]])],[
            max_version_succeeded=yes
        ],[
            min_version_succeeded=no
        ])

      AC_LANG_POP([C])

      if (test "$min_version_succeeded" = "no" -o "$max_version_succeeded" = "no"); then
        AC_MSG_RESULT(no)
        if test "$is_package_required" = yes; then
          AC_MSG_ERROR([Your HDF5 library version does not meet the minimum and maximum versioning
                        requirements ($min_hdf5_version <= HDF5 <= $max_hdf5_version).
                        Please use --with-hdf5 to specify the location of a valid installation.])
        fi
      else
        AC_MSG_RESULT(yes)
      fi

      # Library availability
      AC_CHECK_LIB([hdf5],[H5Fopen],[found_library=yes],[found_library=no])
      AC_LANG_POP([C])

      succeeded=no
      if test "$found_header" = yes; then
        if test "$min_version_succeeded" = yes; then
          if test "$max_version_succeeded" = yes; then
            if test "$found_library" = yes; then
              succeeded=yes
            fi
          fi
        fi
      fi
    fi dnl end test if header if available

    CFLAGS="$ac_HDF5_save_CFLAGS"
    CPPFLAGS="$ac_HDF5_save_CPPFLAGS"
    LDFLAGS="$ac_HDF5_save_LDFLAGS"
    LIBS="$ac_HDF5_save_LIBS"

    if test "$succeeded" = no; then
      if test "$is_package_required" = yes; then
        AC_MSG_ERROR([HDF5 not found.  Try either --with-hdf5 or setting HDF5_DIR.])
      else
         AC_MSG_NOTICE([optional HDF5 library not found, or does not meet version requirements])
      fi

      HDF5_CFLAGS=""
      HDF5_CPPFLAGS=""
      HDF5_LIBS=""
      HDF5_FLIBS=""
      HDF5_CXXLIBS=""
      HDF5_PREFIX=""
    else
      HAVE_HDF5=1
      AC_DEFINE(HAVE_HDF5,1,[Define if HDF5 is available])
      AC_SUBST(HDF5_CFLAGS)
      AC_SUBST(HDF5_CPPFLAGS)
      AC_SUBST(HDF5_LIBS)
      AC_SUBST(HDF5_FLIBS)
      AC_SUBST(HDF5_CXXLIBS)
      AC_SUBST(HDF5_PREFIX)
    fi
    #AC_SUBST(HAVE_HDF5)
fi

#AM_CONDITIONAL(HDF5_ENABLED,test x$HAVE_HDF5 = x1)

])
