x2150 Overview
==============

verilog to implement most of the logic of the 2150.

Synopsis
--------

This is an s/360 control unit which can control one 1052 printer / keyboard.

What is it?
-----------
The 1052 was the console typewriter for most of the early larger members of
the IBM 360 series mainframes.   This was usually attached to the same
reading panel that sat under the iconic front panels of these machines,
and would have been used by the operators as they ran batch jobs,
mounted tapes, and collected printer output.

To interface the 1052 to the mainframe required a control unit;
logic to translate from the I/O paradigm of the 360 series,
to the solenoids and switches of the 1052.
This logic was tucked away somewhere in the CPU cabinets for
the IBM 360 models 40 44 50 65 67 75.

This same logic was also available as a free-standing unit, the 2150, along
with a primitive remote console with just enough controls to stop and
start the mainframe.

The smaller members of the 360 series had their own different console
implementations.  Model 30 had a complete 1050 series device loop
including the 1051 controller.
Models 22 and 25 had an integrated device attachment for the 1052,
which is a fancy way of saying it was controlled directly by microcode
in the CPU.  The later 91 and 85 had early video terminals.

About the 1052
--------------

The 1052 is basically an industrial version of the familiar IBM Selectric
typewriter, with the keyboard & printer split up so they could be
attached to other peripherals in the 1050 family.  The 1052 was almost
purely mechanical like the Selectric, the main difference being
$hat actions that required mechanical actuation on the Selectric
instead required an electric signal to actuate a solenoid.

Besides heavy duty
construction, the other noteworthy property of this hardware is that it
used its own unique code, PTTC/BCD, which is neither ASCII nor EBCDIC.
The keyboard on the 1052 is similar to those used on other IBM equipment,
and mechanically converts key presses into PTTC/BCD.  However, the printer
part of the 1052 is not quite so smart; it takes in tilt/rotate codes
for its type-ball, and there are other separate lines to control other
functions such as a bell, shift, and carriage return.

1052 typewriters were somewhat notorious for being unreliable.  These
were generally left powered up all the time, and so they would cook off
the oil used to lubricate the many mechanical components.  There were
also many bits that could get out of adjustment, so required frequent
regular maintenance visits by the local IBM typewriter service person to
oil and adjust the mechanism for continued operation.  As time went on,
the 1052 models offered with the mainframe lost non-essential features.
The early models had familiar typewriter features such as the ability
to backspace, type in red, mechanical paper margins, and mechanical tab
stops that could be set by hand.  All these features were deleted on the
later 1052 console typewriters.  Some customers would add things back
as an extra cost RFQ, and for instance the FAA 7201 machines apparently
had red ribbon support.

Interfacing to the mainframe
-----------------------------

The standard I/O attachment mode for I/O devices for the 360 was via
channel bus and tag cables.  This is somewhat similar to SCSI or USB,
but used much larger giant cables.  Electrically they used common
collector technology to "wire-or" shared data lines.  Each control unit
had one or more plug-boards to program in a device address (0-255).
Each unit also had an assigned priority which was determined by the
order in which it was cabled up to the CPU.  The 1050's control unit,
being in the mainframe itself, could be wired up either as the highest
priority device, or the lowest.

The 1052, as used by the 360, is a half-duplex device.  On input, key
are echoed locally to the printer at the same time they are being sent to
the mainframe's memory.  In fact, unless the computer issues a read, it's
not possible to type any input to the computer, and when the computer is
printing, it can't also be reading.  To stop the operator for missing up
the printer, the keyboard was physically locked unless the computer was
reading, it wasn't possible to push most keys down.  In normal operation
with an IBM operating system, the operating system would issue occasional
writes as important events happened in the operating system, such as a
request to mount a tape.  When the operator wished to enter a command,
they'd first press <request>, wait for the computer to issue a read
(which would also stop any further output from happening), then they
could type in a command, usually pretty short (remember, no backspace).
They could then either press alt-5 ("enter"), in a normal way (and let the
OS act on the command), or they could press alt-0 which would terminate
the read with an exception indicating to the OS that it should ignore
the line.  There was also an obvious large but not useful <return> key,
which would do a carriage return, but not end input.

Implementation Features
-----------------------

One special oddity of this logic is the upper case latch.  Remember:
6 bit PTTC code - there are upshift and downshift characters, which the
keyboard automatically generated.  The printer mechanism had a special
"shift" line which would spin the type-ball around 180 degrees.  Neither
mechanism provides any way to tell which mechanical state they're in, and
the control unit tries to track it all with one flip-flop.  This almost
works (remember, that's a half-duplex keyboard), but when switching
between computer output & typed input, this obviously isn't sufficient,
and so in this case, the control unit logic has a special hack to emit
an extra "space" to force the correct case.

For the verilog code here; this is all based on the 2150 logic.
The original logic is all asynchronous, with a number of one-shots
to control any necessary timing.  There are a number of flip-flops
implemented as combinational logic with feedback.
For use with a modern FPGA, I've adapted this to synchronous logic.

The actual electrical interconnect to the 1052 is not well described.
I've made my best guess.  

Key debouncing deserves mention.  Mechanical switches, when
actuated, do not generate clean sharp 0/1 transitions.  They
stutter, and jangle, and bounce.  There are lots of ways to deal
with this, the simplest being a short delay to let the keys settle.
That's trivial today, but in 1964, that took extra logic, and logic
was very expensive.  So there were a number of alternatives.
The simplest is, for things like the keyboard that have a mechanical
timing to them, simply to take advantage of that.  The keyboard
strobe isn't active until all the keyboard character code has
settled, and once the keyboard is seen as a "1", it can't be used
again until the printer has completed a mechanical cycle.
In fact, the keyboard is locked until the printing is completed
and the key is released, so N-key rollover is simply not an issue.
For a number of the push-buttons on the 1052, there were actually
2 switches in the push-button, one was broken, then the
other one made, when the button was pressed.  This was typically
used to set two sides of what IBM called a trigger, but which
we might call a S-R flip-flop today.  In a modern circuit diagram
this is often shown as two nand-gates with a criss-cross X
connection in between.

Other general principles: in the IBM alds, a given line might be either
positive sense or negative.  The negative sense line is often prefixed
with "not".  These lines are often used in wired-or and wired-and
configurations.  I've tried to identify all the hidden gates used this
way to replace them with conventional logic.  I've also tried to eliminate
most "not" form signals in in favor of using ~ as necessary.

The 1052 type-ball has 88 positions.  There are 7 degrees of movement on
the type-ball (2 x tilt (4 tilt orientations), 1 x shift (2 sides), and 4
x rotate (11 rotation positions).  The type-ball in turn is mounted on a
carriage that shifts from left to right as each character is imprinted
on the paper.  The tilt and rotate settings are made by activating
solenoids, which mechanically actuate whiffletrees which then perform
the rotation through cables on the advancing carriage.  All 16 rotation
codes produce valid rotation positions, so some positions have more than
one possible encoding.

Code translation
----------------

I've provided ptt2e and tt3 logic to convert from PTTC/BCD
to EBCDIC, and from EBCDIC to tilt rotate code for the printer.
Other members of the 1050 hardware family
included card and paper tape readers, hence its use of PTT/BCD.
The code provided in SY22-2909-2 turns out to be neither complete
nor accurate, it much have been for "instructional purposes only".
IBM type-balls came in a number of encodings; the most common is of course
"Correspondence", which is what all those IBM typewriters use, and is
its own unique code.
For the 1050 family, it was evidently more attractive to supply
different type-balls than to include a lot of extra logic for
the more complicated translation to "correspondence".
The IBM 360/25 uses the same 1052-7 hardware as the
rest of the 360 series, but has a slightly different
encoding, and had different type-balls.
The IBM 1130, which also has a 1052
based console typewriter, has a similar but slightly different code.

Also, note that for the 1052 keyboard, Alt-0 generates a character with
invalid parity.  In the control unit, this generates a unit
exception.  Operating system software would then consider this
to be a "line kill" condition, ignore any input given, and
go back to printing system messages.

References
----------

XXX Need something here...
