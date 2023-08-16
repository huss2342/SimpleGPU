library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ppu is
end tb_ppu;

architecture test of tb_ppu is

component ppu
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        operation    : in  STD_LOGIC_VECTOR(7 downto 0);
        input_a      : in  STD_LOGIC_VECTOR(15 downto 0);
        input_b      : in  STD_LOGIC_VECTOR(15 downto 0);
        output_data  : out STD_LOGIC_VECTOR(15 downto 0);
        start_signal : in  STD_LOGIC;
        done_signal  : out STD_LOGIC
    );
end component;

signal reset : std_logic := '1';
signal clk, start, done : std_logic := '0';
signal operation : std_logic_vector(7 downto 0) := "00000000";
signal input_a, input_b, output_data : std_logic_vector(15 downto 0) := (others => '0');

begin
	 -- 5NS CLOCK
    clk <= not clk after 20 ns;

    -- INTERNAL CONNECTIONS
	 UUT: ppu port map (
        clk          => clk,
        reset        => reset,
        operation    => operation,
        input_a      => input_a,
        input_b      => input_b,
        output_data  => output_data,
        start_signal => start,
        done_signal  => done
    );
	 
	 
process(clk)
    variable count: integer := 0;
begin
    if rising_edge(clk) then
        count := count + 1;

        if count = 1 then
            start <= '1';
            input_a <= "0000001100000000";
            input_b <= "0000000000000011";
            operation <= "00000000";
        end if;
    end if;
end process;


end test;
