----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.02.2022 17:29:52
-- Design Name: 
-- Module Name: Reed_Solomon_encoder - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Reed_Solomon_encoder is
    Port ( CLK: in STD_LOGIC;
           RESET: in STD_LOGIC;
           READY: out STD_LOGIC;
           VLD_IN: in STD_LOGIC;
           symbol_in: in STD_LOGIC_VECTOR (7 downto 0);
           SINK_READY: in STD_LOGIC;
           VLD_OUT: out STD_LOGIC;
           symbol_out: out STD_LOGIC_VECTOR (7 downto 0));
end Reed_Solomon_encoder;

architecture Behavioral of Reed_Solomon_encoder is
component Gallois_multiplier is
port (
        CLK: in  std_logic;
        RESET: in  std_logic;
        READY: out  std_logic;
        VLD_IN: in   std_logic;
        operandA: in  std_logic_vector(7 downto 0);
        operandB: in  std_logic_vector(7 downto 0);
        SINK_READY: in  std_logic;
        VLD_OUT: out std_logic;
        product: out std_logic_vector(7 downto 0));    
end component Gallois_multiplier;

-------- TYPES -------------------------------
type register_array is array (31 downto 0) of std_logic_vector (7 downto 0);
--type register_array is array (254 downto 0) of std_logic_vector (7 downto 0);
type state_type is (Idle, PendingMessage, OutputParityBits);
type ge_array is array (0 to 32) of std_logic_vector(7 downto 0);
--type ge_array is array (0 to 254) of std_logic_vector(7 downto 0);
----------------------------------------------
------ SIGNALS ------------------------
signal current_state,next_state: state_type;
signal product: register_array;
signal parity_info_bits: register_array;
signal vld_in_GF: std_logic;
signal sink_ready_GF: std_logic;

signal counter: unsigned(8 downto 0);
signal counter_coefficients: unsigned(4 downto 0);
signal counter_en: std_logic;
signal counter_coefficients_en: std_logic;
signal counter_reset: std_logic;
signal counter_coefficients_reset: std_logic;
signal control_logic: std_logic;
signal parity_en: std_logic;
signal decision: std_logic_vector(7 downto 0);
signal and_exit: std_logic_vector(7 downto 0);
-------------------------------------------------------------
constant polynomial_of_power: ge_array:= (
                                  "10000000",  
                                  "11011010",  
                                  "11111110", 
                                  "01101010",  
                                  "00001000",  
                                  "01111000",  
                                  "10110000",  
                                  "11010111",  
                                  "10000110",  
                                  "10100101",  
                                  "00010000",  
                                  "01010100", 
                                  "01101100",  
                                  "01101010",  
                                  "11010101",  
                                  "00000100", 
                                  "10001110",  
                                  "00000100",  
                                  "11010101",  
                                  "01101010",  
                                  "01101100",  
                                  "01010100",  
                                  "00010000",  
                                  "10100101",  
                                  "10000110",  
                                  "11010111",  
                                  "10110000",  
                                  "01111000",  
                                  "00001000",  
                                  "01101010",  
                                  "11111110",  
                                  "11011010",  
                                  "10000000"); 

--constant polynomial_of_power : ge_array:= (
--                                  "10000000", 
--                                  "01000000", 
--                                  "00100000", 
--                                  "00010000", 
--                                  "00001000", 
--                                  "00000100", 
--                                  "00000010", 
--                                  "00000001", 
--                                  "11100001", 
--                                  "10010001", 
--                                  "10101001", 
--                                  "10110101", 
--                                  "10111011", 
--                                  "10111100", 
--                                  "01011110", 
--                                  "00101111", 
--                                  "11110110",
--                                  "01111011", 
--                                  "11011100", 
--                                  "01101110", 
--                                  "00110111", 
--                                  "11111010", 
--                                  "01111101", 
--                                  "11011111", 
--                                  "10001110", 
--                                  "01000111", 
--                                  "11000010", 
--                                  "01100001", 
--                                  "11010001", 
--                                  "10001001", 
--                                  "10100101", 
--                                  "10110011",
--                                  "10111000", 
--                                  "01011100", 
--                                  "00101110",
--                                  "00010111", 
--                                  "11101010", 
--                                  "01110101", 
--                                  "11011011", 
--                                  "10001100", 
--                                  "01000110", 
--                                  "00100011", 
--                                  "11110000", 
--                                  "01111000", 
--                                  "00111100", 
--                                  "00011110", 
--                                  "00001111", 
--                                  "11100110", 
--                                  "01110011", 
--                                  "11011000", 
--                                  "01101100", 
--                                  "00110110",
--                                  "00011011", 
--                                  "11101100", 
--                                  "01110110", 
--                                  "00111011", 
--                                  "11111100", 
--                                  "01111110",
--                                  "00111111", 
--                                  "11111110", 
--                                  "01111111", 
--                                  "11011110", 
--                                  "01101111", 
--                                  "11010110", 
--                                  "01101011", 
--                                  "11010100", 
--                                  "01101010",
--                                  "00110101", 
--                                  "11111011", 
--                                  "10011100", 
--                                  "01001110", 
--                                  "00100111", 
--                                  "11110010", 
--                                  "01111001", 
--                                  "11011101", 
--                                  "10001111", 
--                                  "10100110", 
--                                  "01010011",
--                                  "11001000", 
--                                  "01100100", 
--                                  "00110010", 
--                                  "00011001", 
--                                  "11101101", 
--                                  "10010111", 
--                                  "10101010", 
--                                  "01010101",
--                                  "11001011", 
--                                  "10000100", 
--                                  "01000010", 
--                                  "00100001", 
--                                  "11110001", 
--                                  "10011001", 
--                                  "10101101", 
--                                  "10110111", 
--                                  "10111010", 
--                                  "01011101", 
--                                  "11001111", 
--                                  "10000110", 
--                                  "01000011", 
--                                  "11000000", 
--                                  "01100000", 
--                                  "00110000", 
--                                  "00011000", 
--                                  "00001100", 
--                                  "00000110", 
--                                  "00000011", 
--                                  "11100000", 
--                                  "01110000", 
--                                  "00111000", 
--                                  "00011100", 
--                                  "00001110", 
--                                  "00000111", 
--                                  "11100010", 
--                                  "01110001", 
--                                  "11011001", 
--                                  "10001101", 
--                                  "10100111", 
--                                  "10110010", 
--                                  "01011001", 
--                                  "11001101", 
--                                  "10000111", 
--                                  "10100010", 
--                                  "01010001", 
--                                  "11001001", 
--                                  "10000101", 
--                                  "10100011", 
--                                  "10110000", 
--                                  "01011000", 
--                                  "00101100", 
--                                  "00010110", 
--                                  "00001011", 
--                                  "11100100", 
--                                  "01110010", 
--                                  "00111001", 
--                                  "11111101", 
--                                  "10011111", 
--                                  "10101110", 
--                                  "01010111",
--                                  "11001010", 
--                                  "01100101", 
--                                  "11010011", 
--                                  "10001000", 
--                                  "01000100", 
--                                  "00100010", 
--                                  "00010001", 
--                                  "11101001", 
--                                  "10010101", 
--                                  "10101011", 
--                                  "10110100", 
--                                  "01011010", 
--                                  "00101101", 
--                                  "11110111", 
--                                  "10011010", 
--                                  "01001101", 
--                                  "11000111", 
--                                  "10000010", 
--                                  "01000001", 
--                                  "11000001", 
--                                  "10000001", 
--                                  "10100001", 
--                                  "10110001", 
--                                  "10111001", 
--                                  "10111101", 
--                                  "10111111", 
--                                  "10111110", 
--                                  "01011111", 
--                                  "11001110", 
--                                  "01100111",
--                                  "11010010", 
--                                  "01101001", 
--                                  "11010101", 
--                                  "10001011", 
--                                  "10100100", 
--                                  "01010010", 
--                                  "00101001", 
--                                  "11110101", 
--                                  "10011011", 
--                                  "10101100", 
--                                  "01010110", 
--                                  "00101011", 
--                                  "11110100", 
--                                  "01111010", 
--                                  "00111101", 
--                                  "11111111",
--                                  "10011110", 
--                                  "01001111", 
--                                  "11000110", 
--                                  "01100011", 
--                                  "11010000", 
--                                  "01101000", 
--                                  "00110100", 
--                                  "00011010", 
--                                  "00001101", 
--                                  "11100111", 
--                                  "10010010", 
--                                  "01001001", 
--                                  "11000101", 
--                                  "10000011", 
--                                  "10100000", 
--                                  "01010000", 
--                                  "00101000", 
--                                  "00010100", 
--                                  "00001010", 
--                                  "00000101", 
--                                  "11100011", 
--                                  "10010000", 
--                                  "01001000", 
--                                  "00100100", 
--                                  "00010010", 
--                                  "00001001", 
--                                  "11100101", 
--                                  "10010011", 
--                                  "10101000", 
--                                  "01010100", 
--                                  "00101010", 
--                                  "00010101", 
--                                  "11101011", 
--                                  "10010100", 
--                                  "01001010", 
--                                  "00100101",
--                                  "11110011", 
--                                  "10011000", 
--                                  "01001100", 
--                                  "00100110", 
--                                  "00010011", 
--                                  "11101000", 
--                                  "01110100",
--                                  "00111010", 
--                                  "00011101", 
--                                  "11101111", 
--                                  "10010110", 
--                                  "01001011", 
--                                  "11000100", 
--                                  "01100010", 
--                                  "00110001", 
--                                  "11111001", 
--                                  "10011101", 
--                                  "10101111",
--                                  "10110110", 
--                                  "01011011", 
--                                  "11001100", 
--                                  "01100110", 
--                                  "00110011", 
--                                  "11111000", 
--                                  "01111100", 
--                                  "00111110", 
--                                  "00011111", 
--                                  "11101110", 
--                                  "01110111", 
--                                  "11011010", 
--                                  "01101101",
--                                  "11010111", 
--                                  "10001010", 
--                                  "01000101", 
--                                  "11000011");


begin
--Gallois_Field: for i in 0 to 254 generate
Gallois_Field: for i in 0 to 31 generate  
multiplier: Gallois_multiplier port map(
CLK=>clk, 
RESET=>RESET,
READY=>READY, 
VLD_IN=>vld_in_GF,
operandA=>and_exit,
operandB=>polynomial_of_power(i),
SINK_READY=>sink_ready_GF,
VLD_OUT=>VLD_OUT,
product(0)=>product(i)(7),
product(1)=>product(i)(6),
product(2)=>product(i)(5),
product(3)=>product(i)(4),
product(4)=>product(i)(3),
product(5)=>product(i)(2),
product(6)=>product(i)(1),
product(7)=>product(i)(0));
end generate Gallois_Field;

----------- FSM /STATE REGISTER -------------------------------------
process(CLK)
begin
    if (CLK'event and CLK = '1') then
        if (RESET = '1') then
            current_state <= Idle;          
        else 
            current_state <= next_state;      
        end if;
    end if;
end process;
------------------------------------------------------------------------------
----------------------- FSM ---------------------------------------------
-------------------------------------------------------------------------
process (current_state, VLD_IN, Parity_info_bits, SINK_READY, counter)
begin
    counter_en <= '0';
    counter_coefficients_en <= '0';
    counter_reset <= '0';
    counter_coefficients_reset <= '0';
    VLD_OUT <= '0';
    READY <= sink_ready;
    control_logic <= '0';
    parity_en <= '0';  
    next_state <= current_state;

    case current_state is
        when Idle =>
            READY <= '1';
            if (VLD_IN = '1' and SINK_READY = '1') then
                vld_in_GF <= '1';
                READY <= '0';
                next_state <= PendingMessage;
                counter_en <= '1';
                counter_coefficients_en <= '1';
                parity_en <= '1';
                VLD_OUT <= '1';
            end if;
            
        when PendingMessage =>
            if (counter < to_unsigned(222,9)) then  --  Calculation of message bits
                if (counter_coefficients <= to_unsigned(8,5)) then 
                    READY <= '0';
                    counter_coefficients_en <= '1';
                    parity_en <= '0';
                else 
                    READY <= '1'; 
                    counter_coefficients_reset <= '1';
                    if (VLD_IN = '1' and SINK_READY = '1') then
                         counter_en <= '1'; 
                         counter_coefficients_en <= '1';
                         parity_en <= '1';                                   
                    end if;
                end if;  
                vld_in_GF <= '1';
                next_state <= PendingMessage;
             elsif (counter = to_unsigned(222,9)) then
                 next_state <= OutputParityBits;    
             else
                 counter_reset <= '1';
                 counter_coefficients_reset <= '1';
                 next_state <= Idle;
             end if;

        when OutputParityBits =>
            READY <= '0'; 
            control_logic <= '0';  
            if (SINK_READY = '1') then
                sink_ready_GF <= '1';
                counter_en <= '1';
                parity_en <= '1';
                VLD_OUT <= '1';
                if (counter < to_unsigned(255,9)) then
                    next_state <= OutputParityBits; 
                else
                    next_state <= Idle;
                    counter_reset <= '1';    
                end if;   
             end if;    
                  
        when others =>
            next_state <= Idle;
            counter_reset <= '1';                     
        end case;
end process;
----------------------------------------------------------------------------------------
---------- COUNTER PROCESS ---------------------------------------------------
process(CLK) 
begin
    if (CLK'event and CLK='1') then
        if (RESET ='1' or counter_reset = '1') then 
            counter <= (others => '0'); 
        elsif (counter_en = '1') then
            counter <= to_unsigned(to_integer(counter)+1, counter'length);  
        end if;
        if (RESET ='1' or counter_coefficients_reset = '1') then 
            counter_coefficients <= (others => '0'); 
        elsif (counter_coefficients_en = '1') then
            counter_coefficients <= to_unsigned(to_integer(counter_coefficients)+1, counter_coefficients'length); 
        end if;
    end if; 
end process; 
-----------------------------------------------------------------------------------------
--------------------------- COUNTER PROCESS 2 --------------------------------------------
process(CLK) 
begin
    if (CLK'event and CLK='1') then
        if (RESET ='1' or counter_reset = '1') then 
            counter <= (others => '0'); 
        elsif (counter_en = '1') then
            counter <= to_unsigned(to_integer(counter)+1, counter'length);  
        end if;
    end if;
end process; 
----------------------------------------------------------------------------
------------- PARITY BITS PROCESS ------------------------------------------------
process(CLK, Parity_info_bits, product)
begin
    if (CLK'event and CLK = '1') then
        if(parity_en = '1') then
            if (counter = to_unsigned(1,9)) then 
                for i in 0 to 31 loop
                      Parity_info_bits(i) <= (others => '0');
                end loop;
--                  for i in 0 to 254 loop
--                        Parity_info_bits(i) <= (others => '0');
--                  end loop;
            elsif (counter > to_unsigned(1,9) and counter <= to_unsigned(223,9)) then
                for i in 0 to 31 loop
                    if (i=0) then
                        Parity_info_bits(0) <= product(0);
                    else
                        Parity_info_bits(i) <= (product(i) xor Parity_info_bits(i-1));
                    end if;
--                  for i in 0 to 254 loop
--                      if (i=0) then
--                            Parity_info_bits(0) <= product(0);
--                        else
--                            Parity_info_bits(i) <= (product(i) xor Parity_info_bits(i-1));
--                        end if;
                end loop;
            elsif (counter > to_unsigned(223,9) and counter <= to_unsigned(255,9)) then
                for i in 0 to 30 loop
                    Parity_info_bits(i+1) <= Parity_info_bits(i);
                end loop;  
--                for i in 0 to 253 loop
--                    Parity_info_bits(i+1) <= Parity_info_bits(i);
--                end loop; 
            else
                for i in 0 to 31 loop
                      Parity_info_bits(i) <= (others => '0');
                end loop; 
--                    for i in 0 to 253 loop
--                        Parity_info_bits(i+1) <= Parity_info_bits(i);
--                    end loop; 
           end if;
        end if;
    end if;                                   
end process;
---------------------------------------------------------------------------------
---------- FINAL PRODUCT OUT PROCESS ------------------------------------------------
process(symbol_in, Parity_info_bits(31), control_logic)
--variable local_decision: std_logic_vector(7 downto 0);
begin   
--	decision <= Parity_info_bits(31) xor symbol_in;
--	--decision <= Parity_info_bits(254) xor symbol_in;
--	local_decision := decision;
--	for i in 0 to 7 loop
--        and_exit(7-i) <= local_decision(i) and control_logic;
--	end loop;

    if(control_logic='0')then
        symbol_out<=parity_info_bits(31);
    elsif(control_logic='1')then
        symbol_out<=symbol_in;
    else
        symbol_out<="00000000";
    end if; 
end process;  	
------------------------------------------------------
------ FINAL PRODUCT OUT -----------------------------   
process (symbol_in, Parity_info_bits(31),control_logic)
begin
   if(control_logic = '1') then
        symbol_out <= symbol_in;
   elsif (control_logic = '0') then
        symbol_out <= Parity_info_bits(31);
        --symbol_out <= Parity_info_bits(254);
   else
       symbol_out <= "00000000";
   end if;
end process;  
---------- AND/XOR PROCESSES --------
process(symbol_in,parity_info_bits(31))
begin
    decision<=parity_info_bits(31) xor symbol_in;
end process;

process(decision,control_logic)
begin
    for j in 0 to 7 loop
        and_exit(j)<=decision(j) and control_logic;
    end loop;
end process;
---------------------------------------------------------------------------------
end Behavioral;
