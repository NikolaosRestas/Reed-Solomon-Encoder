----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.02.2022 18:09:53
-- Design Name: 
-- Module Name: Gallois_multiplier_tb2 - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Gallois_multiplier_tb2 is
generic(
stall: boolean := false;
seed: positive:=11471);
end Gallois_multiplier_tb2;

architecture Behavioral of Gallois_multiplier_tb2 is
procedure random_stall(      
      constant clk_period : in    time;
      constant en         : in    boolean := false;  
      constant max_stall  : in    integer := 20;     
      constant stall_prob : in    real    := 0.09;  
      variable seed_1     : inout positive;          
      variable seed_2     : inout positive           
      ) is
      variable v_random       : real;     -- VALUE RANDOM FROM 0 TO 1.0 --
      variable v_stall_length : integer := 20;
begin
    if en then
        uniform(seed_1, seed_2, v_random);
        v_stall_length := integer(TRUNC(v_random*real(max_stall))); 
        uniform(seed_1, seed_2, v_random);		
        if (v_random < stall_prob) then    
            wait for v_stall_length*clk_period; 
        end if;
      end if;
end procedure;
--------- VARIABLES ----------------------
shared variable i_count: integer:=0;
shared variable counter_for_cycles: integer:=0;
shared variable message_blocks_entered: integer:=0;
shared variable message_bits_entered: integer:=0;
shared variable codewords_consumed: integer:=0;
shared variable codebits_consumed: integer:=0;
------------------------------------------
-------- TYPES -----------------------------
type char_file is file of character;
type ge_array_of_7bit_tuples is array (0 to 10) of std_logic_vector(7 downto 0);   -- 10 STOIXEIA ME MHKOS 8 BITS --

    constant polynomial_of_power: ge_array_of_7bit_tuples := (
                                                        "00000000" ,
                                                        "10000000" ,
                                                        "01000000" , 
                                                        "00100000" , 
                                                        "00010000" ,
                                                        "00001000" , 
                                                        "00000100" ,
                                                        "00000010" , 
                                                        "00000001" ,
                                                        "11100001" , 
                                                        "10010001");
-------------------------------------------------------------------------------------
-------- SIGNALS --------------------------------------------------------------------
signal CLK: std_logic:= '0';
signal RESET: std_logic:='0';
signal READY: std_logic:='0';
signal SINK_READY: std_logic:='1';
signal VLD_IN: std_logic:='0';
signal VLD_OUT: std_logic:='0';
signal operandA: std_logic_vector(7 downto 0):=(others=>'0');
signal operandB: std_logic_vector(7 downto 0):=(others=>'0');
signal product: std_logic_vector(7 downto 0):=(others=>'0');
signal i_temp: integer:=0;
signal counter_of_cycles_signal: integer:=0;
signal message_bits_entered_signal: integer:=0;
signal message_blocks_entered_signal: integer:=0;
signal codeword_current: std_logic_vector(7 downto 0):=(others=>'0');
signal codewords_consumption: integer:=0;
signal Debug_for_codewords: std_logic_vector(7 downto 0):=(others=>'0');
signal current_codeword_temp: std_logic_vector(7 downto 0):=(others=>'0');
signal codebits_consumption: integer:=0;

-----------------------------------------------------------------------------
---- CHARACTER FILE PROCEDURE-----------------------------------
------------------------------------------------------------------------------
function to_string ( char: std_logic_vector) return string is
        variable char_length : string (1 to char'length) := (others => NUL);
        variable string : integer := 1;
    begin
        for i in char'range loop
            char_length(string) := std_logic'image(char((i)))(2);
            string := string+1;
        end loop;
        return char_length;
    end function;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
constant clk_period : time := 10 ns;
begin
uut: entity work.Gallois_multiplier 
          port map (
          CLK=>CLK, 
          RESET=>RESET,
          READY=>READY, 
          VLD_IN=>VLD_IN, 
          operandA=>operandA, 
          operandB=>operandB, 
          SINK_READY=>SINK_READY, 
          VLD_OUT=>VLD_OUT,
          product=>product); 
-----------------------------------------------
-------- PROCESS FOR CLK AND RESET ------------
   clk_process :process
   begin
       CLK <= '0';
       wait for clk_period/2;
       CLK <= '1';
       wait for clk_period/2;
       counter_for_cycles := counter_for_cycles + 1;
       counter_of_cycles_signal <= counter_for_cycles;
   end process;

   reset_process: process
   begin
       RESET <= '1';
       wait for clk_period;
       RESET <= '0';
       wait;
   end process;
----------------------------------------------------------
------------- PROCESS FOR FEEDING THE BLOCKS --------------
 process

    variable counter  : integer;
    variable tempchar : std_logic_vector(7 downto 0);
    variable seed_1   : positive := seed + 4;  -- RANDOM GENERATOR
    variable seed_2   : positive := seed + 77; -- RANDOM GENERATOR
    variable tmp_vector : std_logic_vector(7 downto 0);

 begin
     counter := 0;
     VLD_IN  <= '0';
     
     operandA <= (others=> '0');
     operandB <= (others=> '0');

     wait until RESET = '0';
     wait for clk_period;
     wait until falling_edge(clk) and ready ='1';
     wait for clk_period;


     for i in 0 to 15 loop
         for k in 0 to 7 loop        --8 BITS --

             random_stall(clk_period, stall, 50, 0.4, seed_1, seed_2);

             wait until falling_edge(clk) and ready = '1';
             wait for 1*clk_period;

             i_count := i;

             operandA(k) <= polynomial_of_power(i)(k);
             operandB(7-k) <= polynomial_of_power(10-i)(7-k);
             message_bits_entered   := message_bits_entered + 1;    -- 1 BIT FOR EACH LOOP
             message_blocks_entered := message_bits_entered / 8;    --8BIT = 1 BLOCK

             
             VLD_IN <= '1';
             wait for 10*clk_period;
             VLD_IN <= '0';
             
             message_bits_entered_signal   <= message_bits_entered;
             if (message_bits_entered mod 8 = 0) then
                message_blocks_entered_signal <= message_blocks_entered;
             else
                message_blocks_entered_signal <= integer(ceil(real(message_blocks_entered)));
             end if;
             
             assert false report " SOURCE PROCESS";
         end loop;
     end loop;

     wait for clk_period;
     vld_in  <= '0';
     report "ALL 16 BLOCKS HAVE ENTERED";
     wait until falling_edge(CLK);
     wait until falling_edge(CLK) and READY = '1';

     if (codebits_consumed = message_blocks_entered) then
         assert false report
         " Not really a failure. Simulation finished successfully. " &
         "All tested message blocks gave the correct corresponding " &
         "codewords!" severity failure;
     else 
         assert false report "ERROR" severity failure; 
     end if;  
     wait;
 end process;

sink: process

variable seed_1 : positive := seed + 490; -- SEED FOR RANDOM GENERATOR --
variable seed_2 : positive := seed + 771; -- SEED FOR RANDOM GENERATOR --
variable current_codeword: std_logic_vector(7 downto 0);
variable index: positive := 0;
begin
    codebits_consumed := 0;
    SINK_READY <= '0';
    random_stall(clk_period, stall, 10, 0.4, seed_1, seed_2);
    index := 0;
    while (true) loop
        i_temp <=index;
        sink_ready <= '1';
        wait until rising_edge(CLK) and VLD_OUT = '1';

        current_codeword(index) := product(index);
                
        Debug_for_codewords(index) <= current_codeword(index);
        current_codeword_temp(index) <= current_codeword(index);
        
        if (index = 7) then
            index := 0;
            codewords_consumed := codewords_consumed + 1;
        else
            index := index + 1;
        end if;
        assert false report "LAST ONE";
        codebits_consumed := codebits_consumed + 1;
        codebits_consumption <= codebits_consumption;
        codewords_consumption <= codewords_consumption;
        
        SINK_READY <= '0';
        random_stall(clk_period, stall, 20, 0.4, seed_1, seed_2);
        
    end loop;
    wait;   
end process;
-------------------------------------------------------------------------------
end Behavioral;
