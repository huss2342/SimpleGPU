LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_ppu_controller IS
END tb_ppu_controller;

ARCHITECTURE behavior OF tb_ppu_controller IS

    -- Signals for ppu_controller ports
    SIGNAL clk           : STD_LOGIC                      := '0';
    SIGNAL reset         : STD_LOGIC                      := '1';
    SIGNAL ppuctl_opcode : STD_LOGIC_VECTOR(7 DOWNTO 0)   := (others => '0');
    SIGNAL ppuctl_start  : STD_LOGIC                      := '0';
    SIGNAL ppuctl_done   : STD_LOGIC                      := '0';

	-- Signals for memory_controller ports
	SIGNAL mem_address_a, mem_address_b : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	SIGNAL mem_data_a, mem_data_b       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL mem_wren_a, mem_wren_b       : STD_LOGIC := '0';
	SIGNAL mem_q_a, mem_q_b             : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	 
    -- TESTING SIGNALS
	 SIGNAL   ram_initialized : STD_LOGIC                   := '0';
	 CONSTANT ARRAY_DEPTH     : INTEGER := 1536; -- Corresponds to 3KB with 16-bit words
	 CONSTANT SECTION_A_START : INTEGER := 0;
	 CONSTANT SECTION_A_END   : INTEGER := 511;
	 CONSTANT SECTION_B_START : INTEGER := 512;
	 CONSTANT SECTION_B_END   : INTEGER := 1023;
	 signal   init_index      : INTEGER := 0;
	 
	 -- Instantiate the ppu_controller
	 COMPONENT ppu_controller
    PORT(
			 clk                  : IN   STD_LOGIC;
			 reset                : IN   STD_LOGIC                      := '1';
			 
			 ppuctl_opcode        : IN   STD_LOGIC_VECTOR (7 DOWNTO 0)  := (others => '0');
			 ppuctl_start         : IN   STD_LOGIC                      := '0';
			 ppuctl_done          : OUT  STD_LOGIC                      := '0';
			 
			 address_a            : OUT  STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 address_b            : OUT  STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 data_a               : OUT  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 data_b               : OUT  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 wren_a               : OUT  STD_LOGIC                      := '0';
			 wren_b               : OUT  STD_LOGIC                      := '0';
			 q_a                  : IN   STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 q_b                  : IN   STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0')
		);
	 END COMPONENT;
	 
	 -- Instantiate the memory_controller
	 COMPONENT memory_controller
		PORT(
			 inclock       : IN STD_LOGIC;
			 outclock      : IN STD_LOGIC;
			 reset         : IN STD_LOGIC:= '1';
			 
			 mem_address_a     : IN STD_LOGIC_VECTOR (11 DOWNTO 0)  := (others => '0');
			 mem_address_b     : IN STD_LOGIC_VECTOR (11 DOWNTO 0)  := (others => '0');
			 mem_data_a        : IN STD_LOGIC_VECTOR (15 DOWNTO 0)  := (others => '0');
			 mem_data_b        : IN STD_LOGIC_VECTOR (15 DOWNTO 0)  := (others => '0');
			 mem_wren_a        : IN STD_LOGIC                       := '0';
			 mem_wren_b        : IN STD_LOGIC                       := '0';
			 mem_q_a           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 mem_q_b           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0')

		);
  END COMPONENT;

   -- Intermediate signals for ppu_controller
	SIGNAL int_address_a, int_address_b : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	SIGNAL int_data_a, int_data_b       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL int_wren_a, int_wren_b       : STD_LOGIC := '0';

	-- Intermediate signals for RAM initialization
	SIGNAL ram_address_a, ram_address_b : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	SIGNAL ram_data_a, ram_data_b       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL ram_wren_a, ram_wren_b       : STD_LOGIC := '0';
BEGIN

   -- 20ns CLOCK
   clk <= not clk after 10 ns;
		
	-- Instantiate the ppu_controller
	UUT: ppu_controller PORT MAP (
			clk           => clk,
			reset         => reset,
			ppuctl_opcode => ppuctl_opcode,
			ppuctl_start  => ppuctl_start,
			ppuctl_done   => ppuctl_done,
			address_a     => int_address_a,  
			address_b     => int_address_b,
			data_a        => int_data_a,
			data_b        => int_data_b,
			wren_a        => int_wren_a,
			wren_b        => int_wren_b,
			q_a           => mem_q_a,
			q_b           => mem_q_b
			);

				-- Instantiate the memory_controller
	memory: memory_controller PORT MAP(
			  inclock       => clk,
			  outclock      => clk,
			  reset         => reset,
			  mem_address_a => mem_address_a,
			  mem_address_b => mem_address_b,
			  mem_data_a    => mem_data_a,
			  mem_data_b    => mem_data_b,
			  mem_wren_a    => mem_wren_a,
			  mem_wren_b    => mem_wren_b,
			  mem_q_a       => mem_q_a,
			  mem_q_b       => mem_q_b
			  );
			
	process(clk, reset)
	begin
		 if reset = '0' then
			  -- Reset logic for intermediate signals
		 elsif rising_edge(clk) then
			  -- Transfer logic between intermediate signals and memory_controller signals
			  if ram_initialized = '0' then
					mem_address_a <= ram_address_a;
					mem_address_b <= ram_address_b;
					mem_data_a    <= ram_data_a;
					mem_data_b    <= ram_data_b;
					mem_wren_a    <= ram_wren_a;
					mem_wren_b    <= ram_wren_b;
			  else
					mem_address_a <= int_address_a;
					mem_address_b <= int_address_b;
					mem_data_a    <= int_data_a;
					mem_data_b    <= int_data_b;
					mem_wren_a    <= int_wren_a;
					mem_wren_b    <= int_wren_b;
			  end if;
		 end if;
	end process;
	


		-- INITIALIZING THE RAM
		RAM_INIT: process(clk, reset)
		begin
			  if reset = '0' then
					 ram_initialized <= '0';
					 init_index <= 0;
					 ram_wren_a <= '0';
					 ram_wren_b <= '0';
			  elsif rising_edge(clk) and ram_initialized = '0' then
					 if init_index <= SECTION_A_END then
							-- Writing to Section A
							ram_address_a <= std_logic_vector(to_unsigned(init_index, ram_address_a'length));
							ram_data_a    <= "0000000000000001";
							ram_wren_a    <= '1';

							-- Writing to Section B
							ram_address_b <= std_logic_vector(to_unsigned(init_index + SECTION_B_START, ram_address_b'length));
							ram_data_b    <= "0000000000000010"; -- Direct binary value for 2
							ram_wren_b    <= '1';

							init_index <= init_index + 1;
					 else
							ram_wren_a <= '0';
							ram_wren_b <= '0';
							ram_initialized <= '1';
					 end if;
			  end if;
		end process RAM_INIT;



		-- STARTING THE PPU_CONTROLLER
		process(clk, reset)
			 variable started : boolean := false;
		begin
			 if reset = '0' then
				  ppuctl_start <= '0';
				  started := false;
			 elsif rising_edge(clk) and ram_initialized = '1' then
				  if not started then
						ppuctl_opcode <= "00000000";
						ppuctl_start <= '1';
						started := true;
				  elsif ppuctl_done = '1' then
						ppuctl_start <= '0'; -- Stop the ALU after it's done
						started := false;
				  end if;
			 end if;
		end process;



END behavior;
