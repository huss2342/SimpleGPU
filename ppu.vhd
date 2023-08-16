------------------------------------------------------------------------------------------------
--- This module will contain the basic ALU design.
--- It will take control signals to specify which operation to perform.
--- It will have inputs and outputs for data.
------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ppu is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        
		  operation    : in  STD_LOGIC_VECTOR(3 downto 0); -- Assuming 4-bit control for operations
        
		  input_a      : in  STD_LOGIC_VECTOR(15 downto 0); -- Assuming 16-bit operands
        input_b      : in  STD_LOGIC_VECTOR(15 downto 0);
        output_data  : out STD_LOGIC_VECTOR(15 downto 0);
		  
		  start_signal : in  STD_LOGIC;
        done_signal  : out STD_LOGIC
    );
end ppu;

function alu_op(op: STD_LOGIC_VECTOR; a: STD_LOGIC_VECTOR; b: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
    variable result : STD_LOGIC_VECTOR(15 downto 0);
begin
    case op is
	 
        -- 1. Arithmetic Operations:
        when "0000" => -- Addition
            result := a + b;
        when "0001" => -- Subtraction
            result := a - b;
        when "0010" => -- Multiplication
            result := a * b;
        when "0011" => -- Division (Ensure b is not 0)
            if b /= "0000000000000000" then
                result := a / b;
            else
                result := (others => '0');
            end if;	
        when "0100" => -- Modulus
            if b /= "0000000000000000" then
                result := a mod b;
            else
                result := (others => '0');
            end if;
        when "0101" => -- Increment (Only considers a)
            result := a + 1;
        when "0110" => -- Decrement (Only considers a)
            result := a - 1;

        -- 2. Logical Operations:
        when "0111" => -- AND
            result := a and b;
        when "1000" => -- OR
            result := a or b;
        when "1001" => -- NOT (Only considers a)
            result := not a;
        when "1010" => -- XOR
            result := a xor b;
        when "1011" => -- NAND
            result := not (a and b);
        when "1100" => -- NOR
            result := not (a or b);

        -- 3. Bitwise Shifts and Rotates:
        when "1101" => -- Shift Left
            result := a sll 1;
        when "1110" => -- Shift Right
            result := a srl 1;
        -- ... Additional operations like rotates can be added ...

        -- 4. Comparison Operations (You may need to adjust return types or use flags):
        -- EQ, NEQ, GT, LT, GTE, LTE can be implemented but might be better suited for flag-based operations.

        -- 5. Other operations specific to GPU can be added later.

        when others =>
            result := (others => '0');
    end case;
    return result;
end function alu_op;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            output_data <= (others => '0');
            done_signal <= '0';
        elsif rising_edge(clk) then
            if start_signal = '1' then
                output_data <= alu_op(operation, input_a, input_b);
                done_signal <= '1';
            else
                done_signal <= '0';
            end if;
        end if;
    end process;

end Behavioral;

