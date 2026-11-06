#!/bin/sh

set -e

if [ $# -lt 2 ]; then
    echo "usage: $0 PACKAGE_NAME PACKAGE_VERSION" >&2
    echo "intended to be called via 'make release' (or 'make archive')" >&2
    exit 1
fi

# CDPATH would make cd print the target directory
unset CDPATH

PACKAGE_NAME=$1
PACKAGE_VERSION=$2

# ignore AppleDouble files
# macOS 10.4
COPY_EXTENDED_ATTRIBUTES_DISABLE=1
export COPY_EXTENDED_ATTRIBUTES_DISABLE
# macOS >= 10.5
COPYFILE_DISABLE=1
export COPYFILE_DISABLE

mkdir -p uv
rm -f uv/${PACKAGE_NAME}*.tar.gz uv/${PACKAGE_NAME}*.zip

# The download page is optional: without the template it is skipped rather
# than failing the whole archive run.
if [ -f uv/template-download.html ]; then
    sed "s/PACKAGE_VERSION/${PACKAGE_VERSION}/g" uv/template-download.html > uv/download.html
else
    echo "archive: uv/template-download.html is missing - download.html not generated" >&2
fi

# tzint is a C extension, so there is no binary archive: a built library holds
# for one platform and one Tcl series, and naming it after neither would put a
# file on the server that nobody can tell apart. What ships is the source, and
# the recipient runs configure.
#
# The tar below takes the whole tree rather than a list of files, so everything
# that a build or a checkout leaves behind travels unless it is named here.
# The build artefacts are the same set that .fossil-settings/ignore-glob keeps
# out of a check-in - object files, the shared library, the generated Makefile,
# pkgIndex.tcl, manifest.h and what autoconf leaves lying around.
#
# .claude/ and docs/prompts/ are internal working material. They are German
# notes on how this package is worked on, not part of it, and ignore-glob keeps
# them out of the repository for the same reason.
cd ..
tar --no-xattrs --no-mac-metadata --disable-copyfile \
    --exclude="${PACKAGE_NAME}/uv" \
    --exclude="${PACKAGE_NAME}/.fslckout" \
    --exclude="${PACKAGE_NAME}/.fossil-settings" \
    --exclude="${PACKAGE_NAME}/.claude" \
    --exclude="${PACKAGE_NAME}/docs" \
    --exclude="${PACKAGE_NAME}/.gitattributes" \
    --exclude="${PACKAGE_NAME}/.vscode" \
    --exclude='.DS_Store' --exclude='*/.DS_Store' \
    --exclude='*.o' --exclude='*.so' --exclude='*.dylib' --exclude='*.dll' \
    --exclude="${PACKAGE_NAME}/Makefile" \
    --exclude="${PACKAGE_NAME}/pkgIndex.tcl" \
    --exclude="${PACKAGE_NAME}/manifest.h" \
    --exclude='config.log' --exclude='config.status' \
    --exclude='configure~' --exclude='autom4te.cache' \
    -czf ${PACKAGE_NAME}/uv/${PACKAGE_NAME}${PACKAGE_VERSION}-src.tar.gz ${PACKAGE_NAME}
