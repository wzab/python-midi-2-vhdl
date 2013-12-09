-------------------------------------------------------------------------------
-- Title      : Testbench for design "midi_read"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : midi_read_tb.vhd
-- Author     : Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl)
-- Company    : 
-- Created    : 2013-12-09
-- Last update: 2013-12-09
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This file implements a VHDL testbench, which reads
--              MIDI commands from the cw.txt file (generated with
--              the midi2vhdl_txt.py utility).
--              If you run it in GHDL with switched on output to the
--              GHW file, you'll see how the MIDI commands are produced on the
--              output in the appropriate simulation time
-- 
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

-------------------------------------------------------------------------------

entity midi_read_tb is

end midi_read_tb;

-------------------------------------------------------------------------------

architecture beh3 of midi_read_tb is

  component midi_read
    generic (
      midi_txt_file : string);
    port (
      cmd   : out integer;
      chan  : out integer;
      byte1 : out integer;
      byte2 : out integer;
      eof   : out std_logic;
      dav   : out std_logic;
      ack   : in  std_logic
      );
  end component;

  -- component ports
  signal cmd   : integer;
  signal chan  : integer;
  signal byte1 : integer;
  signal byte2 : integer;

  signal ack               : std_logic := '0';
  signal dav               : std_logic := '0';
  signal eof               : std_logic := '0';
  signal end_of_simulation : std_logic := '0';

  -- clock
  signal Clk : std_logic := '1';

begin  -- beh3

  -- component instantiation
  DUT : midi_read
    generic map (
      midi_txt_file => "cw.txt")
    port map (
      cmd   => cmd,
      chan  => chan,
      byte1 => byte1,
      byte2 => byte2,
      eof   => eof,
      dav   => dav,
      ack   => ack
      );

  -- clock generation
  -- For real FPGA synthesizer the clock should be much faster,
  -- but if we simply want to verify that the commands are read correctly
  -- from relatively long MIDI file, it is better to set low clock frequency
  -- otherwise the waveform file will be very huge
  Clk <= not Clk after 100 ms when end_of_simulation = '0' else Clk;

  -- end of simulation (add some delay to allow last note to decay)
  end_of_simulation <= eof after 20000 ms;
  -- process receiving data
  process
  begin  -- process
    while end_of_simulation = '0' loop
      wait until dav = '1';
      wait for 100 ns;
      ack <= '1';
      wait until dav = '0';
      wait for 100 ns;
      ack <= '0';
    end loop;
  end process;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    
    wait until Clk = '1';
  end process WaveGen_Proc;

  

end beh3;

-------------------------------------------------------------------------------

configuration midi_read_tb_beh3_cfg of midi_read_tb is
  for beh3
  end for;
end midi_read_tb_beh3_cfg;

-------------------------------------------------------------------------------
