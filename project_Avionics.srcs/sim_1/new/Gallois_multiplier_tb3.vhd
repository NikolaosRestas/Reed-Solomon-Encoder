----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.02.2022 17:09:58
-- Design Name: 
-- Module Name: Gallois_multiplier_tb3 - Behavioral
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
use std.env.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Gallois_multiplier_tb3 is
--  Port ( );
end Gallois_multiplier_tb3;

architecture Behavioral of Gallois_multiplier_tb3 is
constant clk_period: time :=20ns;
--------- TYPES ---------------------------------------------------
type ge_array is array (0 to 254) of std_logic_vector(7 downto 0);
--------------------------------------------------------------------
constant polynomial_of_power : ge_array:= (
                                  "10000000", 
                                  "01000000", 
                                  "00100000", 
                                  "00010000", 
                                  "00001000", 
                                  "00000100", 
                                  "00000010", 
                                  "00000001", 
                                  "11100001", 
                                  "10010001", 
                                  "10101001", 
                                  "10110101", 
                                  "10111011", 
                                  "10111100", 
                                  "01011110", 
                                  "00101111", 
                                  "11110110",
                                  "01111011", 
                                  "11011100", 
                                  "01101110", 
                                  "00110111", 
                                  "11111010", 
                                  "01111101", 
                                  "11011111", 
                                  "10001110", 
                                  "01000111", 
                                  "11000010", 
                                  "01100001", 
                                  "11010001", 
                                  "10001001", 
                                  "10100101", 
                                  "10110011",
                                  "10111000", 
                                  "01011100", 
                                  "00101110",
                                  "00010111", 
                                  "11101010", 
                                  "01110101", 
                                  "11011011", 
                                  "10001100", 
                                  "01000110", 
                                  "00100011", 
                                  "11110000", 
                                  "01111000", 
                                  "00111100", 
                                  "00011110", 
                                  "00001111", 
                                  "11100110", 
                                  "01110011", 
                                  "11011000", 
                                  "01101100", 
                                  "00110110",
                                  "00011011", 
                                  "11101100", 
                                  "01110110", 
                                  "00111011", 
                                  "11111100", 
                                  "01111110",
                                  "00111111", 
                                  "11111110", 
                                  "01111111", 
                                  "11011110", 
                                  "01101111", 
                                  "11010110", 
                                  "01101011", 
                                  "11010100", 
                                  "01101010",
                                  "00110101", 
                                  "11111011", 
                                  "10011100", 
                                  "01001110", 
                                  "00100111", 
                                  "11110010", 
                                  "01111001", 
                                  "11011101", 
                                  "10001111", 
                                  "10100110", 
                                  "01010011",
                                  "11001000", 
                                  "01100100", 
                                  "00110010", 
                                  "00011001", 
                                  "11101101", 
                                  "10010111", 
                                  "10101010", 
                                  "01010101",
                                  "11001011", 
                                  "10000100", 
                                  "01000010", 
                                  "00100001", 
                                  "11110001", 
                                  "10011001", 
                                  "10101101", 
                                  "10110111", 
                                  "10111010", 
                                  "01011101", 
                                  "11001111", 
                                  "10000110", 
                                  "01000011", 
                                  "11000000", 
                                  "01100000", 
                                  "00110000", 
                                  "00011000", 
                                  "00001100", 
                                  "00000110", 
                                  "00000011", 
                                  "11100000", 
                                  "01110000", 
                                  "00111000", 
                                  "00011100", 
                                  "00001110", 
                                  "00000111", 
                                  "11100010", 
                                  "01110001", 
                                  "11011001", 
                                  "10001101", 
                                  "10100111", 
                                  "10110010", 
                                  "01011001", 
                                  "11001101", 
                                  "10000111", 
                                  "10100010", 
                                  "01010001", 
                                  "11001001", 
                                  "10000101", 
                                  "10100011", 
                                  "10110000", 
                                  "01011000", 
                                  "00101100", 
                                  "00010110", 
                                  "00001011", 
                                  "11100100", 
                                  "01110010", 
                                  "00111001", 
                                  "11111101", 
                                  "10011111", 
                                  "10101110", 
                                  "01010111",
                                  "11001010", 
                                  "01100101", 
                                  "11010011", 
                                  "10001000", 
                                  "01000100", 
                                  "00100010", 
                                  "00010001", 
                                  "11101001", 
                                  "10010101", 
                                  "10101011", 
                                  "10110100", 
                                  "01011010", 
                                  "00101101", 
                                  "11110111", 
                                  "10011010", 
                                  "01001101", 
                                  "11000111", 
                                  "10000010", 
                                  "01000001", 
                                  "11000001", 
                                  "10000001", 
                                  "10100001", 
                                  "10110001", 
                                  "10111001", 
                                  "10111101", 
                                  "10111111", 
                                  "10111110", 
                                  "01011111", 
                                  "11001110", 
                                  "01100111",
                                  "11010010", 
                                  "01101001", 
                                  "11010101", 
                                  "10001011", 
                                  "10100100", 
                                  "01010010", 
                                  "00101001", 
                                  "11110101", 
                                  "10011011", 
                                  "10101100", 
                                  "01010110", 
                                  "00101011", 
                                  "11110100", 
                                  "01111010", 
                                  "00111101", 
                                  "11111111",
                                  "10011110", 
                                  "01001111", 
                                  "11000110", 
                                  "01100011", 
                                  "11010000", 
                                  "01101000", 
                                  "00110100", 
                                  "00011010", 
                                  "00001101", 
                                  "11100111", 
                                  "10010010", 
                                  "01001001", 
                                  "11000101", 
                                  "10000011", 
                                  "10100000", 
                                  "01010000", 
                                  "00101000", 
                                  "00010100", 
                                  "00001010", 
                                  "00000101", 
                                  "11100011", 
                                  "10010000", 
                                  "01001000", 
                                  "00100100", 
                                  "00010010", 
                                  "00001001", 
                                  "11100101", 
                                  "10010011", 
                                  "10101000", 
                                  "01010100", 
                                  "00101010", 
                                  "00010101", 
                                  "11101011", 
                                  "10010100", 
                                  "01001010", 
                                  "00100101",
                                  "11110011", 
                                  "10011000", 
                                  "01001100", 
                                  "00100110", 
                                  "00010011", 
                                  "11101000", 
                                  "01110100",
                                  "00111010", 
                                  "00011101", 
                                  "11101111", 
                                  "10010110", 
                                  "01001011", 
                                  "11000100", 
                                  "01100010", 
                                  "00110001", 
                                  "11111001", 
                                  "10011101", 
                                  "10101111",
                                  "10110110", 
                                  "01011011", 
                                  "11001100", 
                                  "01100110", 
                                  "00110011", 
                                  "11111000", 
                                  "01111100", 
                                  "00111110", 
                                  "00011111", 
                                  "11101110", 
                                  "01110111", 
                                  "11011010", 
                                  "01101101",
                                  "11010111", 
                                  "10001010", 
                                  "01000101", 
                                  "11000011");

-------- SIGNALS -----------------------------------------------
signal CLK: std_logic:='0';
signal RESET: std_logic:='0';
signal SINK_READY: std_logic:='0';
signal READY: std_logic:='0';
signal VLD_IN: std_logic:='0';
signal VLD_OUT: std_logic:='0';
signal operandA: std_logic_vector(7 downto 0):=(others=>'0');
signal operandB: std_logic_vector(7 downto 0):=(others=>'0');
signal product: std_logic_vector(7 downto 0):=(others=>'0');
signal product_temp:std_logic_vector(7 downto 0);
signal counter_cycles_signal: integer:=0;
signal show_counter_signal: integer:=0;
signal show_counter_current_signal: integer:=0;
---------------------------------------------------------------------
------------------ FUNCTION FOR STRING ------------------------------
function to_string ( char: std_logic_vector) return string is
        variable character : string (1 to char'length) := (others => NUL);
        variable string : integer := 1;
    begin
        for i in char'range loop
            character(string) := std_logic'image(char((i)))(2);
            string := string+1;
        end loop;
        return character;
end function;
-----------------------------------------------------------------------
begin
uut: entity work.Gallois_multiplier port map(
CLK=>CLK, 
RESET=>RESET, 
READY=>READY,
VLD_IN=>VLD_IN,
operandA=>operandA, 
operandB=>operandB,
sink_ready=>sink_ready,
VLD_OUT=>VLD_OUT,
product=>product);
-------------- PROCESSES FOR RESET & CLK -------------
process
    begin
        RESET<='1';
        wait for 20*clk_period;
        RESET<='0';
end process;

process
variable counter_cycle:integer:=0;
    begin 
    CLK<='0';
    wait for clk_period/4;
    CLK<='1';
    wait for clk_period/4;
    counter_cycle:=counter_cycle+1;
    counter_cycles_signal<=counter_cycle;
end process;
------------------------------------------------------
------- PROCESS FOR THE DATA ---------------------------
process
variable show_counter:integer:=0;
variable temp: std_logic_vector(7 downto 0);
variable current_show_counter: integer:=0;
    begin
    for j in 0 to 254 loop
        for i in 0 to 254 loop
            if(j=0 and i=0)then
                wait for 20*clk_period;
            end if;
            ---- LOAD THE DATA ----
            show_counter:=0;
            operandA<=polynomial_of_power(j);
            operandB<=polynomial_of_power(i);
            VLD_IN<='1';
            SINK_READY<='0';
            if(j=0 and i=0)then
                wait for 10*clk_period;
            else
                wait for 20*clk_period;
            end if;
            --- CHANGE THE SIGNALS ----
            VLD_IN<='1';
            SINK_READY<='1';
            wait for clk_period;
            if(j+i>254)then
                product_temp<=(product xor polynomial_of_power(j+i-255));
            else
                if(j=0 or i=0)then
                    product_temp<=(product xor polynomial_of_power(0));
                else
                    product_temp<=(product xor polynomial_of_power(j+i));
                end if;
            end if;
            --- CHANGE THE VARIABLES ---
            current_show_counter:=show_counter;
            show_counter_current_signal<=current_show_counter;
            ----- CHANGING THE VARIABLE SHOW COUNTER -----
            if(product_temp="00000000")then
                show_counter:=show_counter+1;
            end if;
            ------ MESSAGES ----
            if(show_counter_current_signal=show_counter+1)then
                if(j+i>254)then
                    assert false report "operandA" & to_string(operandA) & "operandB" & to_string(operandB) & "WE HAD THE: "& to_string(product)& "INSTEAD OF" & to_string(polynomial_of_power(j+i-255)) severity failure;
                else
                    assert false report "operandA: " &  to_string(operandA) & "operandB: " & to_string(operandB) & "WE HAD THE: " & to_string(product) &" INSTEAD OF " & to_string(polynomial_of_power(j+i)) severity failure; 
                end if;
            end if;
            show_counter_current_signal<=show_counter;
        end loop;
    end loop;
    ---- LAST CHECK ------------
    if(show_counter_current_signal=show_counter_signal-1)then
        assert false report " NOT FAILURE. SIMULATION FINISHED. " & "ALL TESTED MESSAGE BLOCKS GAVE THE CORRECT CORRESPONDING" severity failure; 
    end if; 
end process;
end Behavioral;
