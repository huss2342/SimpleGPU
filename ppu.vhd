------------------------------------------------------------------------------------------------
--- This module will contain the basic ALU design.
--- It will take control signals to specify which operation to perform.
--- It will have inputs and outputs for data.
------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



---------------------------- DEFINING THE ENTITY ----------------------------
entity ppu is
    Port (
      clk          : in  STD_LOGIC;
      reset        : in  STD_LOGIC;
        
		operation    : in  STD_LOGIC_VECTOR(7 downto 0); -- Assuming 8-bit control for operations
        
		input_a      : in  STD_LOGIC_VECTOR(15 downto 0); -- Assuming 16-bit operands
      input_b      : in  STD_LOGIC_VECTOR(15 downto 0);
      output_data  : out STD_LOGIC_VECTOR(15 downto 0);
		  
		start_signal : in  STD_LOGIC;
      done_signal  : out STD_LOGIC
    );
end ppu;


---------------------------- DEFINING THE ARCHITECTURE ----------------------------
architecture BEHAVIORAL of PPU is


-------------- SHIFTS FUNCTIONS --------------

function custom_sll(value: STD_LOGIC_VECTOR; shift_count: integer) return STD_LOGIC_VECTOR is
    variable result: STD_LOGIC_VECTOR(value'range);
begin
    if shift_count >= value'length then
        for i in value'range loop
            result(i) := '0';
        end loop;
    else
        for i in value'range loop
            if i + shift_count <= value'high then
                result(i) := value(i + shift_count);
            else
                result(i) := '0';
            end if;
        end loop;
    end if;
    return result;
end function custom_sll;

function custom_srl(value: STD_LOGIC_VECTOR; shift_count: integer) return STD_LOGIC_VECTOR is
    variable result: STD_LOGIC_VECTOR(value'range);
begin
    if shift_count >= value'length then
        for i in value'range loop
            result(i) := '0';
        end loop;
    else
        for i in value'range loop
            if i - shift_count >= value'low then
                result(i) := value(i - shift_count);
            else
                result(i) := '0';
            end if;
        end loop;
    end if;
    return result;
end function custom_srl;


function custom_sla(value: STD_LOGIC_VECTOR; shift_count: integer) return STD_LOGIC_VECTOR is
begin
    return custom_sll(value, shift_count);  -- Arithmetic and logical left shifts are the same
end function custom_sla;

function custom_sra(value: STD_LOGIC_VECTOR; shift_count: integer) return STD_LOGIC_VECTOR is
    variable result: STD_LOGIC_VECTOR(value'range);
    variable msb: STD_LOGIC := value(value'high);
begin
    if shift_count >= value'length then
        for i in value'range loop
            result(i) := msb;
        end loop;
    else
        for i in value'range loop
            if i - shift_count >= value'low then
                result(i) := value(i - shift_count);
            else
                result(i) := msb;
            end if;
        end loop;
    end if;
    return result;
end function custom_sra;



-------------- ALU OPERATIONS --------------
function alu_op(op: STD_LOGIC_VECTOR; a: STD_LOGIC_VECTOR; b: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
    variable result : STD_LOGIC_VECTOR(15 downto 0);
begin
    case to_integer(unsigned(op)) is
	 
        -- 1. Arithmetic Operations:
        when 0 => -- Addition
            result := STD_LOGIC_VECTOR(unsigned(a) + unsigned(b));
        when 1 => -- Subtraction
            result := STD_LOGIC_VECTOR(unsigned(a) - unsigned(b));
        when 2 => -- Multiplication
            result := STD_LOGIC_VECTOR(resize(unsigned(a) * unsigned(b), 16));
        when 3 => -- Division (Ensure b is not 0)
            if b /= "0000000000000000" then
                result := STD_LOGIC_VECTOR(unsigned(a) / unsigned(b));
            else
                result := (others => '0');
            end if;	
        when 4 => -- Modulus
            if b /= STD_LOGIC_VECTOR(to_unsigned(0, b'length)) then
                result := STD_LOGIC_VECTOR(unsigned(a) mod unsigned(b));
            else
                result := (others => '0');
            end if;
        when 5 => -- Increment (Only considers a)
            result := STD_LOGIC_VECTOR(unsigned(a) + 1);
        when 6 => -- Decrement (Only considers a)
            result := STD_LOGIC_VECTOR(unsigned(a) - 1);
				
        -- 2. Logical Operations:
        when 7 => -- AND
            result := a and b;
        when 8 => -- OR
            result := a or b;
        when 9 => -- NOT (Only considers a)
            result := not a;
        when 10 => -- XOR
            result := a xor b;
        when 11 => -- NAND
            result := not (a and b);
        when 12 => -- NOR
            result := not (a or b);

        -- 3. Bitwise Shifts and Rotates:
        when 13 => -- Shift Left Logically
				    result := custom_sll(a, to_integer(unsigned(b)));
		    when 14 => -- Shift Right Logically
				    result := custom_srl(a, to_integer(unsigned(b)));
		    when 15 => -- Shift Left Arithmetically
				    result := custom_sla(a, to_integer(unsigned(b)));
		    when 16 => -- Shift Right Arithmetically
				    result := custom_sra(a, to_integer(unsigned(b)));
            
 
        

        when others =>
            result := (others => '0');
				
    end case;
    return result;
end function alu_op;

begin -- THE BEGIN FOR ARCHITECTURE

    process(clk, reset)
    begin
        if reset = '0' then
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

