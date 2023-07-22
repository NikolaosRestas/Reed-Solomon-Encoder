library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.all;

entity Gallois_multiplier_tb1 is
--  Port ( );
end Gallois_multiplier_tb1;

architecture Behavioral of Gallois_multiplier_tb1 is

constant CLK_period : time := 20 ns;

component Gallois_multiplier is
port (
        CLK: in std_logic;
        RESET: in std_logic;
        READY: out std_logic;
        VLD_IN: in std_logic;
        operandA: in std_logic_vector(7 downto 0);
        operandB: in std_logic_vector(7 downto 0);
        SINK_READY:in std_logic;
        VLD_OUT: out std_logic;
        product: out std_logic_vector(7 downto 0));
        
end component Gallois_multiplier;
------ SIGNALS ---------
signal CLK_tb: std_logic;
signal RESET_tb: std_logic;
signal READY_tb:std_logic;
signal VLD_IN_tb: std_logic;
signal SINK_READY_tb: std_logic;
signal VLD_OUT_tb: std_logic;
signal operandA_tb: std_logic_vector(7 downto 0);
signal operandB_tb: std_logic_vector(7 downto 0);
signal product_tb: std_logic_vector(7 downto 0);

begin

test_process: 
Gallois_multiplier 
port map (
    CLK=>CLK_tb,
    RESET=>RESET_tb, 
    READY=>READY_tb,
    VLD_IN=>VLD_IN_tb,
    operandA=>operandA_tb, 
    operandB=>operandB_tb,
    SINK_READY=>SINK_READY_tb,
    VLD_OUT=>VLD_OUT_tb,
    product=>product_tb);
------- PROCESSES ------------
CLK_process: process 
    begin
        CLK_tb <= '0';
        wait for CLK_period/2;
        CLK_tb <= '1';
        wait for CLK_period/2;
    end process CLK_process;
    
stimulus_proc: process
    begin 
        RESET_tb <= '1';
        wait for 10ns;
        wait until (CLK_tb = '0' and CLK_tb'event);
        RESET_tb <= '0';
    VLD_IN_tb<='1'; SINK_READY_tb<='0';operandA_tb<="00110111";operandB_tb<="11110011";
    wait for 9*CLK_period;
    VLD_IN_tb<='0';SINK_READY_tb<='1';
    wait for CLK_period;
    
     VLD_IN_tb<='1';SINK_READY_tb<='0';operandA_tb<="01000000";operandB_tb<="11110011"; 
    wait for 10*CLK_period;
    VLD_IN_tb<='0';SINK_READY_tb<='1';
    wait for CLK_period;

    VLD_IN_tb<='1';SINK_READY_tb<='0';operandA_tb<="10000000";operandB_tb<="11000011"; 
    wait for 10*CLK_period;
    VLD_IN_tb<='0';SINK_READY_tb<='1';
    wait for 1*CLK_period;
    
    VLD_IN_tb<='1';SINK_READY_tb<='0';operandA_tb<="01000000";operandB_tb<="11110011"; 
    wait for 10*CLK_period;
    VLD_IN_tb<='0';SINK_READY_tb<='1';
    wait for CLK_period;
end process stimulus_proc;          

end Behavioral;

