library IEEE;
use IEEE.std_logic_1164.all;

package constants is

constant MEMORY_SIZE : integer := 4096;
constant ADDRESS_WIDTH : integer := 32;
constant DATA_WIDTH : integer := 32;
constant NUM_REGS : integer := 32;
constant SIZE_REGS : integer := 32;

type memoryarray is array(0 to MEMORY_SIZE-1) of std_logic_vector(7 downto 0);
type regs is array(0 to NUM_REGS-1) of std_logic_vector(SIZE_REGS-1 downto 0);

-- For the testbench
constant period : time := 4 ns;
constant half_period : time := 2 ns;

end constants;