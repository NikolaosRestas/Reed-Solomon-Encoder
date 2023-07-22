library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Gallois_multiplier is
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
        
end Gallois_multiplier;

architecture Behavioral of Gallois_multiplier is

    type reg_array is array (7 downto 0, 7 downto 0) of std_logic;
    type and_array is array (7 downto 0, 7 downto 0) of std_logic;
    type xor_array is array (7 downto 0, 7 downto 0) of std_logic;
    type state_type is (Idle, PendingMessage, OutputParityBits);
    
    signal operandA_info_bits: reg_array;
    signal registerC_info_bits: reg_array;    
    signal and_output: and_array; 
    signal xor_output: xor_array;
    signal current_state, next_state : state_type;
    
    signal operandB_info_bits: std_logic_vector(7 downto 0);
    signal rd_en: std_logic;
    
    signal counter: unsigned(3 downto 0); 
    signal counter_en: std_logic;   
    signal counter_reset: std_logic;   


begin
---------- FSM PROCESS/STATE REGISTER -------------
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
--------------------------------------------
------------ FSM ---------------------------
--------------------------------------------
process (current_state, VLD_IN, operandA, operandB, SINK_READY, counter)
begin

    counter_en <= '0';
    counter_reset <= '0';
    VLD_OUT <= '0';
    READY <= SINK_READY;
    rd_en<='0';
    next_state <= current_state;

    case current_state is
        when Idle =>
            READY<='1';
            if(VLD_IN = '1') then   
                next_state <= PendingMessage;
                counter_en <= '1';
                rd_en<='1';
 
            end if;

        when PendingMessage =>  
            READY<='1';    
            if (VLD_IN = '1') then   
                counter_en <= '1';
                rd_en<='1';
                if (counter < to_unsigned(8,4)) then   
                    next_state <= PendingMessage;
                elsif (counter = to_unsigned(8,4)) then  
                    next_state <= OutputParityBits; 
                else
                    counter_reset <= '1';
                    next_state <= Idle;
                end if;
            end if;

        when OutputParityBits =>   
    
            READY <= '0'; 
            VLD_OUT  <= '1';  
            if (SINK_READY = '1') then 
                counter_reset <= '1';
                next_state <= Idle; 
            end if;
        
        when others =>    
            counter_reset <= '1';
            next_state <= Idle;
    end case;
end process;
---------------------------------------------------------------
process(CLK) 
begin
    if (CLK'event and CLK='1') then
        if (RESET ='1' or counter_reset = '1') then 
            counter <= (others => '0');  
        elsif (counter_en = '1') then
            counter <= to_unsigned(to_integer(counter)+1,counter'length);  
        end if;
    end if; 
end process; 
------------------------------------------------------------------------------
----------- OPERAND A & OPERAND B IN REGISTERS -----------------
process(clk,operandA,operandB)
begin
        

    if (CLK'event and CLK = '1') then
        if (rd_en = '1') then
            for i in 0 to 7 loop
                operandA_info_bits(0,i) <= operandA(7-i);
                operandB_info_bits(i) <= operandB(7-i);     
            end loop;
        end if;
    end if;
      
    for k in 0 to 6 loop
        if (CLK'event and CLK = '1') then
            if (rd_en = '1') then     
                operandA_info_bits(k+1,0) <= operandA_info_bits(k,7);
                for i in 0 to 6 loop   
                    operandA_info_bits(k+1,i+1) <= operandA_info_bits(k,i);
                end loop;
            end if;        
        end if; 
    end loop;    
end process;
-----------------------------------------------------------------
-------- AND PROCESS ---------------------------------------------
process (operandA_info_bits,operandB_info_bits) 
begin
      for i in 0 to 7 loop
          for j in 0 to 7 loop
            and_output(i,j) <= operandA_info_bits(i,7) and operandB_info_bits(j); 
          end loop;
      end loop; 
end process;  
-----------------------------------------------------------------
-------- XOR THE AND OUTPUT WITH REGISTER C VALUES ---------
process(and_output, registerC_info_bits)
begin

    for i in 0 to 7 loop
       xor_output(0,i) <= and_output(0,i) xor '0';
    end loop;

    for i in 0 to 6 loop
        for j in 0 to 7 loop
            if (j=0) then
                xor_output(i+1,j) <= and_output(i+1,j) xor registerC_info_bits(i,7);
            elsif (j=1 or j=2 or j=7) then
                xor_output(i+1,j) <= and_output(i+1,j) xor registerC_info_bits(i,j-1) xor registerC_info_bits(i,7);
            else
                xor_output(i+1,j) <= and_output(i+1,j) xor registerC_info_bits(i,j-1);   
            end if;
        end loop;
    end loop;  

end process;
--------------------------------------------------------------------
----- SAVE THE XOR OUTPUT TO REGITER C --------------------
process(CLK, xor_output)
begin
    if (CLK'event and CLK = '1') then
        if (rd_en = '1') then
            for i in 0 to 7 loop
                for j in 0 to 7 loop
                    registerC_info_bits(i,j) <= xor_output(i,j);
                end loop;  
            end loop;
        end if;
    end if;           
end process;
---------------------------------------------------------------
-------- MOV THE REGISTER C VALUE TO THE NEXT REGISTER ----------------------
process(registerC_info_bits)
begin
    if (SINK_READY='1') then
        for i in 0 to 7 loop
            product(7-i) <= registerC_info_bits(7,i);
        end loop;  
    else
        for i in 0 to 7 loop
            product(i) <= '0';
        end loop; 
    end if;
end process;
-------------------------------------------------------------
end Behavioral;

