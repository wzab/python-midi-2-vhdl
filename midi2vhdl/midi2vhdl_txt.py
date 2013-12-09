#!/usr/bin/env python
"""
This program is written by Wojciech M. Zabolotny ( wzab<at>ise.pw.edu.pl )
as a utility for translation of MIDI files to text files readable 
for the VHDL simulator.

You should run it as e.g.:
$./midi2seq.py my_midi_file output_text_file_for_VHDL_simulator

This program is based on the midiplay script, which is a part of
the Python MIDI library, available at https://github.com/vishnubob/python-midi
This library must be installed.

This program is published under the The MIT License (MIT)
(as the original Python MIDI library)
Attach to a MIDI device and send the contents of a MIDI file to it.
"""
import sys
import time
import midi
#import midi.sequencer as sequencer


def event_write(event, direct=False, relative=False, tick=False):
    #print event.__class__, event
    ## Event Filter
    if isinstance(event, midi.EndOfTrackEvent):
        return
    ## Tempo Change
    ## We ignore it?
    ## Note Event
    elif isinstance(event, midi.NoteEvent):
        if isinstance(event, midi.NoteOnEvent):
            data= chr(0x90 | event.channel) + \
               chr(event.pitch) + chr(event.velocity)
        if isinstance(event, midi.NoteOffEvent):
            data= chr(0x80 | event.channel)+ \
               chr(event.pitch)+chr(event.velocity)
    ## Control Change
    elif isinstance(event, midi.ControlChangeEvent):
        data= chr(0xb0 | event.channel) + \
           chr(event.control) + chr(event.value)
    ## Program Change
    elif isinstance(event, midi.ProgramChangeEvent):
        data= chr(0xc0 | event.channel) + \
           chr(event.value)
    ## Pitch Bench
    elif isinstance(event, midi.PitchWheelEvent):
        data= chr(0xe0 | event.channel) + \
           chr(event.data[0]) + chr(event.data[1])
    ## Unknown
    else:
        print "Warning :: Unknown event type: %s" % event
        return ""
    return data


if len(sys.argv) != 3:
    print "Usage: {0} <file> <output_text_file>".format(sys.argv[0])
    exit(2)

filename = sys.argv[1]
fo=open(sys.argv[2],'w')

pattern = midi.read_midifile(filename)
pattern.make_ticks_abs()
events = []
for track in pattern:
    for event in track:
        events.append(event)
events.sort()
tstart = time.time()
for event in events:
    data=event_write(event)
    #print event.tick
    if data:
        data = data + chr(0) * (3-len(data))
        line = str(event.tick/1000.0)
        for c in data:
            line += " "+str(ord(c))
        fo.write(line+"\n")
fo.close()
