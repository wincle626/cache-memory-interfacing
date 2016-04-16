library IEEE;
use IEEE.std_logic_1164.all;

package constants is

constant MEMORY_SIZE : integer := 4096;
constant ADDRESS_WIDTH : integer := 32;
constant DATA_WIDTH : integer := 32;
constant NUM_REGS : integer := 32;
constant SIZE_REGS : integer := 32;
constant DCACHE_NUM_SETS : integer := 8;
constant DCACHE_TAG_SIZE : integer := 25;
constant DCACHE_BLOCK_SIZE : integer := 4;
constant DCACHE_SET_SIZE : integer := 2;
constant DCACHE_INDEX_SIZE : integer := 3;
constant DCACHE_WORD_OFFSET : integer := 3;

type memoryarray is array(0 to MEMORY_SIZE-1) of std_logic_vector(7 downto 0);
type regs is array(0 to NUM_REGS-1) of std_logic_vector(SIZE_REGS-1 downto 0);
type blockd is array (0 to DCACHE_BLOCK_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

type dblock is record
	valid		:	std_logic;
	tag			:	std_logic_vector(DCACHE_TAG_SIZE-1 downto 0);
	blockdata	:	blockd;
end record dblock;

type blks is array (0 to DCACHE_SET_SIZE-1) of dblock;

type dset is record
	blocks		:	blks;
	lastused	:	std_logic_vector(0 downto 0);
end record dset;

type dcachearray is array(0 to DCACHE_NUM_SETS-1) of dset;


-- For the testbench
constant period : time := 4 ns;
constant half_period : time := 2 ns;

end constants;