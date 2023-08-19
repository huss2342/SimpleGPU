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
      address_a     : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
      address_b     : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
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

  COMPONENT memory_controller
    PORT(
      address_a     : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
      address_b     : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
      data_a        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      data_b        : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
      inclock       : IN STD_LOGIC;
      outclock      : IN STD_LOGIC;
      wren_a        : IN STD_LOGIC;
      wren_b        : IN STD_LOGIC;
      write_protect : IN STD_LOGIC:= '0'; 
      reset         : IN STD_LOGIC; 
      q_a           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      q_b           : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;
  
  -- Control signals
  signal reset      : std_logic := '1';
  signal clk        : std_logic := '0';
  signal start      : std_logic := '0';
  signal done       : std_logic := '0';
  signal opcode     : std_logic_vector(7 downto 0) := "00000000";

  -- Address and data signals
  signal address_a  : std_logic_vector(11 downto 0);
  signal address_b  : std_logic_vector(11 downto 0);
  signal data_a     : std_logic_vector(15 downto 0);
  signal data_b     : std_logic_vector(15 downto 0);
  signal q_a        : std_logic_vector(15 downto 0);
  signal q_b        : std_logic_vector(15 downto 0);

  -- PPU-related signals
  signal ppu_a       : std_logic_vector(15 downto 0);
  signal ppu_b       : std_logic_vector(15 downto 0);
  signal ppu_result  : std_logic_vector(15 downto 0);
  signal ppu_operation : std_logic_vector(7 downto 0);

  -- Read and write activity signals
  signal mem_wren_a : std_logic := '0'; 
  signal mem_wren_b : std_logic := '0'; 

  signal ram_initialized : std_logic := '0';
  
  BEGIN
    -- 20ns CLOCK+
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

    -- Instantiate the Memory Controller with signals
    memory: memory_controller port map (
      address_a     => address_a,
      address_b     => address_b,
      data_a        => data_a,
      data_b        => data_b,
      inclock       => clk,      
      outclock      => clk,  
      wren_a        => mem_wren_a,
      wren_b        => mem_wren_b,
      reset         => reset,         -- Connect to reset signal
      q_a           => q_a,
      q_b           => q_b
    );
	 

	stimulus_process: process
      CONSTANT ARRAY_DEPTH : INTEGER := 512;
    begin
      wait until ram_initialized = '1'; -- Wait for RAM initialization
      wait for 50 ns;
      opcode <= "00000000"; 
      start <= '1';
      wait for 50 ns;
      reset <= '0';       -- Assert reset
      wait for 20 ns;     -- Wait for 20ns
      reset <= '1';       -- Deassert reset
      wait until done = '1'; -- Wait until operation is complete
      report "Operation completed at time: " & time'image(now); -- Report the time
      start <= '0';
    end process stimulus_process;

    -- INITIALIZING THE RAM
    RAM_INIT: process
       CONSTANT ARRAY_DEPTH : INTEGER := 512;
    begin
       if ram_initialized = '0' then
          for i in 0 to ARRAY_DEPTH-1 loop
             address_a <= std_logic_vector(to_unsigned(i, address_a'length));
             data_a <= "0000000000000001";
             mem_wren_a <= '1';
             wait for 10 ns;
             mem_wren_a <= '0';

             address_b <= std_logic_vector(to_unsigned(i + ARRAY_DEPTH, address_b'length));
             data_b <= "0000000000000010"; -- Direct binary value for 2
             mem_wren_b <= '1';
             wait for 10 ns;
             mem_wren_b <= '0';
          end loop;
          ram_initialized <= '1';
       end if;
       wait;
    end process RAM_INIT;
  end behavior;

