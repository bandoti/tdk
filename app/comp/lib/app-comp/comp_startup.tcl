# Copyright (c) 2018 ActiveState Software Inc.
# Released under the BSD-3 license. See LICENSE file for details.
#
# startup.tcl --
#
#  Startup script for the Tcl Dev Kit bytecode compiler.
#  See procomp.tcl for a description of the call syntax
#  and behaviour of the procomp package.
#
# Copyright (c) 1998      by Scriptics Corporation.
# Copyright (c) 2002-2011 ActiveState Software Inc.
#


# 
# RCS: @(#) $Id: startup.tcl,v 1.4 2000/10/31 23:31:05 welch Exp $

package provide app-comp 1.0

###############################################################################
# Basic log settings ... Logging to stdout or a file.
# The GUI will override this with logging to a window.

package require log
log::lvSuppress debug
log::lvSuppress warning 0 ; # Activate
log::lvSuppress info    0 ; # Activate
log::lvSuppress notice  0 ; # Activate

###############################################################################

# Prevent misinterpretation by Tk
set ::pargc $::argc ; set ::argc 0
set ::pargv $::argv ; set ::argv {}

if {[string match -psn* [lindex $::pargv 0]]} {
    # Strip Apple's option providing the Processor Serial Number to bundles.
    incr ::pargc -1
    set  ::pargv [lrange $::pargv 1 end]
}

package require projectInfo ; # Tclpro | 
package require cmdline     ; # Tcllib | Processing the command line.

package require procomp     ; # The engine itself

###############################################################################
###############################################################################
##
# New code, TclDevKit graphical user interface ...

# Invoked automatically if the application is called without arguments
# and a DISPLAY is present. If either there is no DISPLAY or we are
# unable to load Tk we do not follow this branch further but fall
# through to the default command line mode (which will print a help
# message).

# If the first argument is a -gui the UI is forced, and
# a second argument will be interpreted as a configuration
# to load. Any other arguments will be ignored in that mode.

set config {}
if {[string equal -gui [lindex $pargv 0]]} {
    set config [lindex $pargv 1]
    set pargv [list]
}

# Give something to the Tk check.
set ::argc $::pargc
set ::argv $::pargv

package require tcldevkit::tk

# And remove everything again.
set ::argc 0
set ::argv {}

if {[::tcldevkit::tk::present]} {
    package require tcldevkit::appframe
    package require help

    package require style::as
    style::as::init
    style::as::enable control-mousewheel global

    ::help::page Compiler
    ::tcldevkit::appframe::setName Compiler [info patchlevel]
    ::tcldevkit::appframe::NeedReadOrdered
    ::tcldevkit::appframe::initConfig $config
    ::tcldevkit::appframe::run     tcldevkit::compiler

    # The 'run' will not return.
}

# Need this information when loading a configuration file (-config)
# Future: Separate the application framework into Tk and non-Tk parts.
package require tcldevkit::appframe
::tcldevkit::appframe::setName Compiler

###############################################################################
###############################################################################
# Perform all "command-line" level processing.

::log::log info    "| $::tcldevkit::appframe::appNameV"
::log::log info    "| Copyright (C) 2001-2011 ActiveState Software Inc. All rights reserved."

::log::log notice "Compiling ..."

set status [procomp::run $pargv]

::log::log notice "Done"

exit [expr {$status == 0}]
