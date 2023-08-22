library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.gpu_pkg.all; --array_t
 
entity gpu_top is
    Port (
      clk             : in  STD_LOGIC;
      reset           : in  STD_LOGIC := '1';
      start           : in  STD_LOGIC;
      input_array_a   : in  array_t := (others => (others => '0')); -- {ONLY TESTING A FEW ELEMENTS FOR NOW} 512 elements, each 16 bytes
      input_array_b   : in  array_t := (others => (others => '0'));
      operation_code  : in  STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
		result_array    : out array_t := (others => (others => '0'));
		  
      gpu_top_done    : out STD_LOGIC := '0';
		gpu_result_done : out STD_LOGIC := '0';
		elements_length : IN STD_LOGIC_VECTOR (11 downto 0) := std_logic_vector(to_unsigned(array_t'length, 12))
    );
end entity gpu_top;

architecture behavior of gpu_top is
	--SIGNAL elements_lengthSIGNAL : INTEGER := array_t'length;
	
-- Signals for ppu_controller ports
   SIGNAL ppuctl_opcode : STD_LOGIC_VECTOR(7 DOWNTO 0)   := (others => '0');
   SIGNAL ppuctl_start  : STD_LOGIC                      := '0';
   SIGNAL ppuctl_done   : STD_LOGIC                      := '0';

-- Signals for memory_controller ports
	SIGNAL mem_address_a, mem_address_b   : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	SIGNAL mem_data_a, mem_data_b         : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL mem_wren_a, mem_wren_b         : STD_LOGIC 							 := '0';
	SIGNAL mem_q_a, mem_q_b				     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL mem_q_a2, mem_q_b2             : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
		
	--SIGNAL mem_address_a2, mem_address_b2 : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	--SIGNAL mem_data_a2, mem_data_b2       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	--SIGNAL mem_wren_a2, mem_wren_b2       : STD_LOGIC 							 := '0';
	 
-- INITIALIZATION SIGNALS
	SIGNAL   ram_initialized  : STD_LOGIC := '0';
	
	CONSTANT ARRAY_DEPTH      : INTEGER := 1536;
	
	-- input sections
	CONSTANT SECTION_A_START  : INTEGER := 0;
	CONSTANT SECTION_A_END    : INTEGER := 511;
	CONSTANT SECTION_B_START  : INTEGER := 512;
	CONSTANT SECTION_B_END    : INTEGER := 1023;
	
	-- result section
	CONSTANT SECTION_C_START  : INTEGER := 1024;
	CONSTANT SECTION_C_END    : INTEGER := 1535;
	
	--index signals
	signal   init_index       : INTEGER := SECTION_A_START;	 
	
-- Instantiate the ppu_controller
	 COMPONENT ppu_controller
		PORT(
			 clk                  : IN  STD_LOGIC;
			 reset                : IN  STD_LOGIC                      := '1';
			 
			 ppuctl_opcode        : IN  STD_LOGIC_VECTOR (7 DOWNTO 0)  := (others => '0');
			 ppuctl_start         : IN  STD_LOGIC                      := '0';
			 ppuctl_done          : OUT STD_LOGIC                      := '0';
			 
			 address_a            : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 address_b            : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 data_a               : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 data_b               : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 wren_a               : OUT STD_LOGIC                      := '0';
			 wren_b               : OUT STD_LOGIC                      := '0';
			 q_a                  : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 q_b                  : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
		
			 data_a2              : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 data_b2              : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 address_a2           : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 address_b2           : OUT STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 q_a2                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 q_b2                 : IN  STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 
			 memory_ready			 : IN STD_LOGIC 							  := '0';
			 elements_length 		 : IN STD_LOGIC_VECTOR (11 downto 0)  := (others => '0') 
		);
	 END COMPONENT;
	 
-- Instantiate the memory_controller
	 COMPONENT memory_controller
		PORT(
			 inclock       : IN STD_LOGIC;
			 outclock      : IN STD_LOGIC;
			 reset         : IN STD_LOGIC                      := '1'; 
			 
			 mem_address_a : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 mem_address_b : IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
			 mem_data_a    : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 mem_data_b    : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
			 mem_wren_a    : IN STD_LOGIC                      := '0';
			 mem_wren_b    : IN STD_LOGIC                      := '0';
			 mem_q_a       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
			 mem_q_b       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
			 
			 
			 mem_address_a2: IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0'); 
			 mem_address_b2: IN STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0'); 
			 mem_data_a2   : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0'); 
			 mem_data_b2   : IN STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0'); 
			 mem_wren_a2   : IN STD_LOGIC                      := '0';             
			 mem_wren_b2   : IN STD_LOGIC                      := '0';             
			 mem_q_a2      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0'); 
			 mem_q_b2      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0):= (others => '0');
			
			memory_ready   : OUT STD_LOGIC 							:= '0'
		);
  END COMPONENT;

	-- Intermediate signals for ppu_controller
	SIGNAL int_address_a, int_address_b   : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	SIGNAL int_data_a, int_data_b         : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL int_wren_a, int_wren_b         : STD_LOGIC := '0';

	--SIGNAL int_address_a2, int_address_b2 : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	--SIGNAL int_data_a2, int_data_b2       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	--SIGNAL int_wren_a2, int_wren_b2       : STD_LOGIC := '0';

	-- Intermediate signals for RAM initialization
	SIGNAL ram_address_a, ram_address_b   : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	SIGNAL ram_data_a, ram_data_b         : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	SIGNAL ram_wren_a, ram_wren_b         : STD_LOGIC := '0';
	--SIGNAL ram_address_a2, ram_address_b2 : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	--SIGNAL ram_data_a2, ram_data_b2       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
	--SIGNAL ram_wren_a2, ram_wren_b2       : STD_LOGIC := '0';
	
	SIGNAL memory_ready 						  : STD_LOGIC := '0';

	-- reading from memory states
	type fsm_state is (IDLE, INIT_MEMORY, START_PPUCTL, WAIT_PPUCTL_DONE, READ_FROM_MEM, WAIT_FOR_MEMORY, DONE);
	signal current_state, next_state: fsm_state := IDLE;
	
	
BEGIN


		
	-- Instantiate the ppu_controller => connecting it to ppu_controller's intermediate signals
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
			q_b           => mem_q_b,
			
			--data_a2       => int_data_a2,
			--data_b2       => int_data_b2,
			--address_a2    => int_address_a2,
			--address_b2    => int_address_b2,
			q_a2          => mem_q_a2,
			q_b2          => mem_q_b2,
			
			memory_ready => memory_ready,
			elements_length => elements_length
			);


	-- Instantiate the memory_controller => connecting it to the memory signals
	memory: memory_controller PORT MAP(
      inclock        => clk,
      outclock       => clk,
      reset          => reset,
      
      mem_address_a  => mem_address_a,
      mem_address_b  => mem_address_b,
      mem_data_a     => mem_data_a,
      mem_data_b     => mem_data_b,
      mem_wren_a     => mem_wren_a,
      mem_wren_b     => mem_wren_b,
      mem_q_a        => mem_q_a,
      mem_q_b        => mem_q_b,
      
      --mem_address_a2 => mem_address_a2,
      --mem_address_b2 => mem_address_b2,
      --mem_data_a2    => mem_data_a2,
      --mem_data_b2    => mem_data_b2,
      --mem_wren_a2    => mem_wren_a2,
      --mem_wren_b2    => mem_wren_b2,
      mem_q_a2       => mem_q_a2,
      mem_q_b2       => mem_q_b2,
		
		memory_ready   => memory_ready
      );


			
	process(clk)
	begin
		if rising_edge(clk) then
			-- Transfer logic between intermediate signals and memory_controller signals
			if (ram_initialized = '0' OR ppuctl_done = '1') then
				--speaking directly to ram--
				mem_address_a  <= ram_address_a;
				mem_address_b  <= ram_address_b;
				mem_data_a     <= ram_data_a;
				mem_data_b     <= ram_data_b;
				mem_wren_a     <= ram_wren_a;
				mem_wren_b     <= ram_wren_b;

				--mem_address_a2 <= ram_address_a2;
				--mem_address_b2 <= ram_address_b2;
				--mem_data_a2    <= ram_data_a2;
				--mem_data_b2    <= ram_data_b2;
				--mem_wren_a2    <= ram_wren_a2;
				--mem_wren_b2    <= ram_wren_b2;
			else
				--letting the signals from the ppu_controller flow
				mem_address_a <= int_address_a;
				mem_address_b <= int_address_b;
				mem_data_a    <= int_data_a;
				mem_data_b    <= int_data_b;
				mem_wren_a    <= int_wren_a;
				mem_wren_b    <= int_wren_b;

				--mem_address_a2 <= int_address_a2;
				---mem_address_b2 <= int_address_b2;
				--mem_data_a2    <= int_data_a2;
				--mem_data_b2    <= int_data_b2;
				--mem_wren_a2    <= int_wren_a;
				--mem_wren_b2    <= int_wren_b;
			end if;
		end if;
	end process;




process(clk, reset)
	variable out_index : INTEGER := 0;
	variable sent_to_mem : boolean := false;
begin
	if reset = '0' then
		init_index <= SECTION_A_START;
		out_index := 0;
		sent_to_mem := false;
		--int_address_a <= (others => '0');
		--int_address_b <= (others => '0');
		--int_data_a <= (others => '0');
		--int_data_b <= (others => '0');
		--int_wren_a <= '0';
		--int_wren_b <= '0';

		--int_address_a2 <= (others => '0');
		--int_address_b2 <= (others => '0');
		--int_data_a2 <= (others => '0');
		--int_data_b2 <= (others => '0');
		--int_wren_a2 <= '0';
		--int_wren_b2 <= '0';

		ram_address_a <= (others => '0');
		ram_address_b <= (others => '0');
		ram_data_a <= (others => '0');
		ram_data_b <= (others => '0');
		ram_wren_a <= '0';
		ram_wren_b <= '0';

		current_state <= IDLE;
		next_state <= IDLE;

		
	elsif rising_edge(clk) then
		case current_state is
		
			when IDLE =>
				if start = '1' then
					--the gpu_top receives the start signal
					next_state <= INIT_MEMORY;
				end if;
				
			when INIT_MEMORY =>
				if init_index <= array_t'LENGTH-1 then
					-- this will iterate and write the input array to memory
					
					-- Writing to Section A
					ram_address_a <= std_logic_vector(to_unsigned(init_index, ram_address_a'length));
					--I DO NOT WRITE TO THE SECOND RAM, THIS IS A SEQUENTIAL TEST, SINCE THE ARRAY IS SMALL ANYWAYS****************** 
					
					ram_data_a <= input_array_a(init_index); -- Value is taken from input_array_a
					ram_wren_a <= '1';

					-- Writing to Section B
					ram_address_b <= std_logic_vector(to_unsigned(init_index + SECTION_B_START, ram_address_b'length));
					--I DO NOT WRITE TO THE SECOND RAM, THIS IS A SEQUENTIAL TEST, SINCE THE ARRAY IS SMALL ANYWAYS******************
					
					ram_data_b <= input_array_b(init_index); -- Value is taken from input_array_b
					ram_wren_b <= '1';

					init_index <= init_index + 1;
				
				else
					init_index <= SECTION_A_START;
					ram_wren_a <= '0';
					ram_wren_b <= '0';
					ram_initialized <= '1'; --TODO might not be needed as much anymore?
					next_state <= START_PPUCTL;					
				end if;
				
			when START_PPUCTL =>
				-- starting the ppu_controll unit which will read memory, do an operation then write the result
				if ((ram_initialized = '1') AND (ppuctl_done = '0')) then --TODO might not need this if statements
					ppuctl_opcode <= operation_code;
					ppuctl_start <= '1';
					next_state <= WAIT_PPUCTL_DONE;
				end if;					
				
			when WAIT_PPUCTL_DONE =>
				if ppuctl_done = '1' then
					--once the calculations are complete, we'll reset some variables and declare that the calculations were complete
					--in order to make it easier for another system to know that the results are now ready
					gpu_top_done <= '1';
					ram_initialized <= '0';
					ppuctl_start <= '0';
					ram_wren_a <= '0';
					ram_wren_b <= '0';
					next_state <= READ_FROM_MEM;
				end if;
				
			when READ_FROM_MEM =>
				--this will read memory from the output section (SECTION_C_START)
				--this will read from memory sequentially and not in parallel. it is actually possible to read from memory from 4 seperate pins at a time
				
				ram_address_a <= std_logic_vector(to_unsigned(out_index+SECTION_C_START,ram_address_b'length));
				sent_to_mem := false;
				next_state <= WAIT_FOR_MEMORY;
				
			when WAIT_FOR_MEMORY =>
				-- This will wait for the memory to take in the input address and switch the output to what is correctly stored there
				-- we have to wait a little bit just to be safe since it seems like memory takes a bit longer than expected to switch its output
				if memory_ready = '1' and sent_to_mem = false then
					if out_index < array_t'LENGTH then
						result_array(out_index) <= mem_q_a;
						out_index := out_index + 1;
						sent_to_mem := true;
						--if there is more to read then go back to reading from memory
						next_state <= READ_FROM_MEM;
					else
						--if there is no more to read then we are done
						next_state <= DONE;
					end if;
				else
					next_state <= WAIT_FOR_MEMORY;
				end if;
				
			when DONE =>
				gpu_result_done <= '1'; -- all the results have been read
				out_index := 0;  --resetting the index
				
				if start = '1' then
					next_state <= READ_FROM_MEM;
				else
					next_state <= IDLE;
				end if;
				
			when others =>
				next_state <= IDLE;
				
		end case;
		
		current_state <= next_state;
	end if;

end process;


end architecture behavior;
