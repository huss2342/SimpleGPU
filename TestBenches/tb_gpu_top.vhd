library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.gpu_pkg.all; --array_t

entity tb_gpu_top is
end entity tb_gpu_top;

architecture sim of tb_gpu_top is

   COMPONENT gpu_top
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC := '1';
            start           : in  STD_LOGIC;
            input_array_a   : in  array_t   							 := (others => (others => '0'));
            input_array_b   : in  array_t                       := (others => (others => '0'));
            operation_code  : in  STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
				result_array    : out array_t := (others => (others => '0'));
            gpu_top_done    : out STD_LOGIC := '0';
				gpu_result_done : out STD_LOGIC := '0'
        );
   end COMPONENT;

    signal clk             : STD_LOGIC := '0';
    signal reset           : STD_LOGIC := '1';
    signal start           : STD_LOGIC := '0';
    signal operation_code  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal gpu_top_done    : STD_LOGIC := '0';
	 SIGNAL gpu_result_done : STD_LOGIC := '0';
	 
    -- Arrays
    SIGNAL input_array_a   : array_t := (others => (others => '0'));
    SIGNAL input_array_b   : array_t := (others => (others => '0'));
    SIGNAL result_array    : array_t := (others => (others => '0'));

begin
   -- 20ns CLOCK
   clk <= not clk after 10 ns;

    -- Instantiate gpu_top
    UUT: gpu_top
        port map (
            clk              => clk,
            reset            => reset,
            start            => start,
            input_array_a    => input_array_a,
            input_array_b    => input_array_b,
            operation_code   => operation_code,
            result_array     => result_array,
            gpu_top_done     => gpu_top_done,
				gpu_result_done  => gpu_result_done
        );

    -- Testbench logic
    stim_proc: process
    begin
        -- Initialize input arrays
		  input_array_a(0) <= std_logic_vector(to_unsigned(53, 16)); 
		  input_array_a(1) <= std_logic_vector(to_unsigned(20, 16)); 
        -- The rest of the elements in input_array_a are initialized to zero by default

        input_array_b(0) <= std_logic_vector(to_unsigned(16, 16));
		  input_array_b(1) <= std_logic_vector(to_unsigned(400, 16)); 
        -- The rest of the elements in input_array_b are initialized to zero by default

        -- Start initialization by asserting the start signal
        start <= '1';
        wait for 10 ns;

        -- De-assert start signal if needed
        start <= '0';

        -- End the simulation
		  wait until gpu_result_done = '1';
		  
        wait;
    end process;
end architecture sim;
