----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2022 16:14:00
-- Design Name: 
-- Module Name: Reed_Solomon_encoder_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Reed_Solomon_encoder_tb is
generic(
    input_file: string :="C:/Users/Desktop/...."; -- path for the input file
    output_file: string:="C:/Users/Desktop/...."; -- path for the output file
    stall: boolean :=false;
    seed: positive :=10471
);
end Reed_Solomon_encoder_tb;

architecture Behavioral of Reed_Solomon_encoder_tb is

-- FUNCTION DEFINITIONS --
procedure random_stall(
    constant clk_period: in time;
    constant enable: in boolean:=false;
    constant max_stall: in integer:=10;
    constant stall_prob: in real :=0.05;
    variable seed_1: inout positive;
    variable seed_2: inout positive
)is
variable v_random: real;
variable v_stall_length: integer :=20;
begin
    if enable then
        uniform(seed_1, seed_2, v_random);
        v_stall_length := integer(TRUNC(v_random*real(max_stall))); 
        uniform(seed_1, seed_2, v_random);		
        if (v_random < stall_prob) then    
            wait for v_stall_length*clk_period; 
        end if;
      end if;
end procedure;
--- VARIABLES ------
shared variable i_count: integer:=0;
shared variable counter_for_cycles: integer:=0;
shared variable message_blocks_entered: integer:=0;
shared variable message_bits_entered: integer:=0;
shared variable codewords_consumed: integer:=0;
shared variable codebits_consumed: integer:=0;

---- TYPES ------
type charfile is file of character;

-- SIGNALS --
signal CLK: std_logic:='0';
signal RESET: std_logic:='0';
signal SINK_READY: std_logic:='1';
signal READY: std_logic:='0';
signal VLD_IN: std_logic:='0';
signal VLD_OUT: std_logic:='0';
signal symbol_in: std_logic_vector(7 downto 0):=(others=>'0');
signal symbol_out: std_logic_vector(7 downto 0):=(others=>'0');
signal DEBUG_temp_vector: std_logic_vector(7 downto 0);

signal cycles_counter_signal: integer;

-- SHARED VARIABLES ----
shared variable cycles_counter: integer:=0;

------- PROCESS -------
constant clk_period : time := 10 ns;

begin

uut: entity work.Reed_Solomon_encoder
port map(
    CLK=>CLK,
    RESET=>RESET,
    READY=>READY,
    SINK_READY=>SINK_READY,
    VLD_IN=>VLD_IN,
    VLD_OUT=>VLD_OUT,
    symbol_in=>symbol_in,
    symbol_out=>symbol_out
);

--- clk_process ---
process
begin 
    CLK<='0';
    wait for clk_period/2;
    CLK<='1';
    wait for clk_period/2;
    cycles_counter_signal<= cycles_counter+1;
end process;
-- reset process --
process
begin
    RESET<='1';
    wait for clk_period/2;
    RESET<='0';
    wait;
end process;
----------------
-- SOURCE PROCESS --
process
variable c0: character;
file input_file_handle: charfile is in input_file;
variable counter: integer;
variable tempchar: std_logic_vector(7 downto 0);
variable seed_1: positive:= seed+4;
variable seed_2: positive:= seed+77;
variable temp_vector: std_logic_vector(7 downto 0);


begin
    counter:=0;
    VLD_IN<='0';
    symbol_in<=(others=>'0');
    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    
    wait until RESET='0';
    wait for clk_period;
    wait for clk_period;
    wait for clk_period;
    
    wait until falling_edge(CLK) and READY='1';
    wait for clk_period;
    wait for clk_period;
    wait for clk_period; 
    
    L1: while not(endfile(input_file_handle))loop
        wait until rising_edge(CLK);
        wait for 0.1*clk_period;
        
        random_stall(clk_period,stall,50,0.4,seed_1,seed_2);
        if(READY='1')then
            read(input_file_handle,c0);
            message_bits_entered:=message_bits_entered+1;
            symbol_in<=std_logic_vector(to_unsigned(character'pos(c0),8));
            VLD_IN<='1';
            --temp_vector:=std_logic_vector(to_unsigned(character'pos(c0)-48,8));
        else
            symbol_in<=(others=>'0');
            VLD_IN<='0';
        end if;
        message_blocks_entered:=message_bits_entered/4;
    end loop;
    wait for clk_period;
    VLD_IN<='0';
    report "ALL MESSAGE BLOCKS HAVE BEEN ENTERED";
    wait until falling_edge(CLK);
    wait until falling_edge(CLK) and READY='1';
    if(codebits_consumed=message_blocks_entered *7)then
        assert false report "NOT REALLY A FAILURE";
    else 
        assert false report "SOMETHING WENT WRONG";
    end if;
end process;
------ SINK PROCESS ------ 
process
file outputfile: text open write_mode is output_file;
variable L2: line;
variable seed_1: positive:= seed+490;
variable seed_2: positive:= seed+771;
variable temp_vector: std_logic_vector(7 downto 0);
variable index: positive:=0;

begin 
codebits_consumed:=0;
SINK_READY<='1';
wait until falling_edge(CLK) and VLD_OUT='1';
temp_vector(index):= symbol_out(index);
DEBUG_temp_vector<=temp_vector;

if(index=255) then
    write(l2,to_integer(unsigned(temp_vector)),right,8);
    writeline(outputfile,l2);
else
    index := index+1;
end if;
SINK_READY<='0';
random_stall(clk_period,stall,10,0.4,seed_1,seed_2);
wait for clk_period;
end process;
-------------------
end Behavioral;
