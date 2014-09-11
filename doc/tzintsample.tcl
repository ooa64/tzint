#!/bin/sh
#\
exec /usr/local/bin/tclsh8.6 "$0" "$@"

load ./libtzint1.0.dylib

#array set val {}

#puts [list version [tzint::Encode version]]
#puts [list symbologies [tzint::Encode sym]]

#puts [list [tzint::Encode xbm val Abc12 -symbol qr -stat stat] $val $stat]

#tzint::Encode file ./composite_symbol.png {[99]1234-abcd} -symbol eanx-cc -mode 1 -primary {331234567890}
#tzint::Encode file ./qr_symbol.png {Abc12} -symbol qr
tzint::Encode file ./code128.png {1234567890128} -symbol code128


if 0 {
  puts "--- bits ---"
  if {[set rc [tzint::Encode bits val {abc} -symbol codabar -onchar {#} -offchar { } -stat stat -notext 1 -height 30]] == 0} {
    foreach row [dict get $val bits] {
      puts $row
    }
  }
  puts "rc $rc"
  puts "stat [list $stat]"
}

if 1 {
  puts "--- bits ---"
  if {[set rc [tzint::Encode bits val {zint for tcl v1.0} -symbol qr -onchar {#} -offchar { } -stat stat -height 60]] == 0} {
    foreach row [dict get $val bits] {
      puts $row
    }
  }
  puts "rc $rc"
  puts "stat [list $stat]"
}

if 0 {
  puts "--- xbm ---"
  if {[set rc [tzint::Encode xbm val {zint for tcl v1.0} -symbol qr -stat stat]] == 0} {
    puts $val
  }
  puts "rc $rc"
  puts "stat [list $stat]"
}

if 0 {
  puts "--- eps ---"
  if {[set rc [tzint::Encode eps val {zint for tcl v1.0} -symbol qr -stat stat]] == 0} {
    puts $val
  }
  puts "rc $rc"
  puts "stat [list $stat]"
}

if 0 {
  puts "--- svg ---"
  if {[set rc [tzint::Encode svg val {zint for tcl v1.0} -symbol qr -stat stat]] == 0} {
    puts $val
  }
  puts "rc $rc"
  puts "stat [list $stat]"
}

if 1 {
  puts "--- png file ---"
  if {[set rc [tzint::Encode file qr.png {zint for tcl v1.0} -symbol qr -stat stat -bg #00ff00 -fg #ff0000]] == 0} {
  }
  puts "rc $rc"
  puts "stat [list $stat]"

  puts "--- svg file ---"
  if {[set rc [tzint::Encode file qr.svg {zint for tcl v1.0} -symbol qr -stat stat]] == 0} {
  }
  puts "rc $rc"
  puts "stat [list $stat]"

  puts "--- eps file ---"
  if {[set rc [tzint::Encode file qr.eps {zint for tcl v1.0} -symbol qr -stat stat]] == 0} {
  }
  puts "rc $rc"
  puts "stat [list $stat]"

  puts "--- dat file ---"
  if {[set rc [tzint::Encode file qr.dat {zint for tcl v1.0} -symbol qr -stat stat]] == 0} {
  }
  puts "rc $rc"
  puts "stat [list $stat]"
}


if 0 {
  package require Tk 8.6
  puts "--- xbm and tk ---"
  if {[set rc [tzint::Encode xbm val {zint for tcl v1.0} -symbol qr -stat stat]] == 0} {
    set image [image create bitmap -data $val]
    label .l -image $image
    pack .l
  }
  puts "rc $rc"
  puts "stat [list $stat]"
}

