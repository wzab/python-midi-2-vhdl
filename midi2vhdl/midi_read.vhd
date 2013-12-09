-------------------------------------------------------------------------------
-- Title      : midi_read - entity for reading MIDI commands from text file
-- Project    : 
-------------------------------------------------------------------------------
-- File       : midi_read.vhd
-- Author     : Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl)
-- Company    : 
-- Created    : 2013-12-09
-- Last update: 2013-12-09
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Simple entity reading the MIDI commands from text file
--              prepared with the midi2vhdl_txt.py utility
--              The command are available on the output at the appropriate
--              simulation time.
--              Please note, that this code is not synthesizable
-------------------------------------------------------------------------------
-- Copyright (c) Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl) 2013
-- License: CC0 Public Domain Dedication
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-12-09  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--use ieee.std_logic_textio.all;
use std.textio.all;

entity midi_read is
  generic (
    midi_txt_file : string := "midi_in.txt");
  port (
    cmd   : out integer;                -- MIDI command
    chan  : out integer;                -- MIDI channel
    byte1 : out integer;                -- byte with first value
    byte2 : out integer;    -- byte with second value (or 0 if not used)
    eof   : out std_logic;  -- informs, that end of file was reached
    dav   : out std_logic;  -- informs, that new command is available
    ack   : in  std_logic   -- acknowledges reception of the command
    );

end midi_read;

architecture beh1 of midi_read is

  signal ticks : time;
  signal s_dav : std_logic := '0';
  signal s_eof : std_logic := '0';
  
begin  -- beh1

  dav <= s_dav;
  eof <= s_eof;

  process
    file events_in      : text open read_mode is midi_txt_file;
    variable input_line : line;
    variable v_ticks    : real;
    variable ticks      : time;
    variable v_byte0    : integer;
    variable v_byte1    : integer;
    variable v_byte2    : integer;
  begin  -- process
    loop
      exit when endfile(events_in);
      readline(events_in, input_line);
      read(input_line, v_ticks);
      read(input_line, v_byte0);
      read(input_line, v_byte1);
      read(input_line, v_byte2);
      ticks := v_ticks * 1000 ms;
      if now < ticks then
        wait for ticks - now;
      end if;
      cmd   <= integer(v_byte0/16);
      chan  <= v_byte0 mod 16;
      byte1 <= v_byte1;
      byte2 <= v_byte2;
      s_dav <= '1';
      wait until ack = '1';
      s_dav <= '0';
      wait until ack = '0';
    end loop;
    s_eof <= '1';
    wait;
  end process;

end beh1;
