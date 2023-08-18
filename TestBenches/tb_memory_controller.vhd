LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_memory_controller IS
END tb_memory_controller;

ARCHITECTURE behavior OF tb_memory_controller IS

    -- Signal declarations
    SIGNAL address_a      : STD_LOGIC_VECTOR (9 DOWNTO 0) := (others => '0');
    SIGNAL address_b      : STD_LOGIC_VECTOR (9 DOWNTO 0) := (others => '0');
    SIGNAL data_a         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL data_b         : STD_LOGIC_VECTOR (15 DOWNTO 0) := (others => '0');
    SIGNAL inclock        : STD_LOGIC := '0';
    SIGNAL outclock       : STD_LOGIC := '0';
    SIGNAL wren_a         : STD_LOGIC := '0';
    SIGNAL wren_b         : STD_LOGIC := '0';
    SIGNAL write_protect  : STD_LOGIC := '0';
    SIGNAL reset          : STD_LOGIC := '1';
    SIGNAL q_a            : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL q_b            : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL read_activity  : STD_LOGIC;
    SIGNAL write_activity : STD_LOGIC;

BEGIN

    -- Clock generation
    PROCESS
    BEGIN
        wait for 5 ns;
        inclock <= not inclock;
        outclock <= not outclock;
    END PROCESS;

    -- Instantiating the memory_controller
    UUT: ENTITY work.memory_controller
    PORT MAP(
        address_a     => address_a,
        address_b     => address_b,
        data_a        => data_a,
        data_b        => data_b,
        inclock       => inclock,
        outclock      => outclock,
        wren_a        => wren_a,
        wren_b        => wren_b,
        write_protect => write_protect,
        reset         => reset,
        q_a           => q_a,
        q_b           => q_b,
        read_activity => read_activity,
        write_activity => write_activity
    );

    -- Test stimulus
    PROCESS
    BEGIN
        -- Reset the memory_controller
        reset <= '0'; wait for 10 ns;
        reset <= '1'; wait for 10 ns;
        
        -- Write data to memory for address_a
        address_a <= "0000000001";
        data_a <= "0000000000000001";
        wren_a <= '1'; wait for 10 ns;
        wren_a <= '0'; wait for 10 ns;

        -- Read data from memory for address_a
        address_a <= "0000000001";
        wait for 10 ns;

        -- Write data to memory for address_b
        address_b <= "0000000010";
        data_b <= "0000000000000010";
        wren_b <= '1'; wait for 10 ns;
        wren_b <= '0'; wait for 10 ns;

        -- Read data from memory for address_b
        address_b <= "0000000010";
        wait for 10 ns;

        -- Additional test cases and assertions can be added here

        -- End of simulation
        wait;
    END PROCESS;

END behavior;