LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_ppu_controller IS
END tb_ppu_controller;

ARCHITECTURE behavior OF tb_ppu_controller IS 

COMPONENT ppu_controller
	PORT(
		 clk           : IN  STD_LOGIC;
		 opcode        : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 start         : IN  STD_LOGIC;
		 reset         : IN  STD_LOGIC := '1';
		 address_a     : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		 address_b     : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		 data_a        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		 data_b        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		 mem_wren_a    : OUT STD_LOGIC;
		 mem_wren_b    : OUT STD_LOGIC;
		 q_a           : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 q_b           : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 ppu_a         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		 ppu_b         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		 ppu_operation : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		 ppu_result    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		 done          : OUT STD_LOGIC
	);
END COMPONENT;
  
signal reset : std_logic := '1';
signal clk, start, done : std_logic := '0';
signal opcode : std_logic_vector(7 downto 0) := "00000000";
signal address_a, address_b : std_logic_vector(9 downto 0);
signal data_a, data_b, q_a, q_b : std_logic_vector(15 downto 0);
signal mem_wren_a, mem_wren_b, ppu_enable : std_logic;
signal ppu_a, ppu_b, ppu_result : std_logic_vector(15 downto 0);
signal ppu_operation : std_logic_vector(7 downto 0);

-- Signals for memory mock-up
type memory_array_type is array(0 to 2047) of std_logic_vector(15 downto 0);
signal memory : memory_array_type := (others => (others => '0'));

signal init_address : std_logic_vector(9 downto 0);
signal init_wren : std_logic := '0';

BEGIN
	-- 20ns CLOCK
	clk <= not clk after 10 ns;

    -- Instantiate the PPU with signals
	 UUT: ppu_controller port map (
		 clk           => clk,
		 opcode        => opcode,
		 start         => start,
		 reset         => reset,
		 
		 -- Memory controller interface
		 address_a     => address_a,
		 address_b     => address_b,
		 data_a        => data_a,
		 data_b        => data_b,
		 mem_wren_a    => mem_wren_a,
		 mem_wren_b    => mem_wren_b,
		 q_a           => q_a,
		 q_b           => q_b,

		 -- PPU interface
		 ppu_a         => ppu_a,
		 ppu_b         => ppu_b,
		 ppu_operation => ppu_operation,
		 ppu_result    => ppu_result,

		 done          => done
	 );

	 
	 
stimulus_process: process
begin
    wait for 50 ns;
    opcode <= "00000000"; 
    start <= '1';
	 wait for 50 ns;
	 
	 reset <= '0';       -- Assert reset
	 wait for 20 ns;     -- Wait for 20ns
	 reset <= '1';       -- Deassert reset

	 
	 wait for 30 ns;
	 start <= '1';
    wait for 100 ns;
	 start <= '0';
    wait for 500 ns;
    wait; 
end process stimulus_process;


		RAM_INIT: process
			 CONSTANT ARRAY_DEPTH : INTEGER := 1024;
		begin
			 for i in 0 to ARRAY_DEPTH-1 loop
				  init_address <= std_logic_vector(to_unsigned(i, init_address'length)); 
				  data_a <= std_logic_vector(to_unsigned(i, data_a'length));
				  init_wren <= '1'; -- Set init_wren to '1' during initialization
				  wait for 10 ns;
			 end loop;

			 init_wren <= '0'; -- Reset init_wren to '0' after initialization
			 wait;
		end process RAM_INIT;

	 
		-- Memory Mock-up Process
		process(clk)
		begin
			 if rising_edge(clk) then
				  -- Write operation for initialization
				  if init_wren = '1' then
						memory(to_integer(unsigned(init_address))) <= data_a;
				  end if;
				  
				  -- Write operation for A (from ppu_controller)
				  if mem_wren_a = '1' then
						memory(to_integer(unsigned(address_a))) <= data_a;
				  end if;
				  
				  -- Write operation for B
				  if mem_wren_b = '1' then
						memory(to_integer(unsigned(address_b))) <= data_b;
				  end if;
				  
				  -- Read operation for A
				  q_a <= memory(to_integer(unsigned(address_a)));
				  
				  -- Read operation for B
				  q_b <= memory(to_integer(unsigned(address_b)));
			 end if;
		end process;


end behavior;