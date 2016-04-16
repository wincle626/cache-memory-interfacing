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
constant CACHE_BLOCK_SIZE : integer := 4;
constant DCACHE_SET_SIZE : integer := 2;
constant DCACHE_INDEX_SIZE : integer := 3;
constant DCACHE_WORD_OFFSET : integer := 2;

constant ICACHE_TAG_SIZE : integer := 23;
constant ICACHE_NUM_BLOCKS : integer := 32;
constant ICACHE_INDEX_SIZE : integer := 5;
constant ICACHE_WORD_OFFSET : integer := 2;

type memoryarray is array(0 to MEMORY_SIZE-1) of std_logic_vector(7 downto 0);
type regs is array(0 to NUM_REGS-1) of std_logic_vector(SIZE_REGS-1 downto 0);

--caches
type cacheblock is array (0 to CACHE_BLOCK_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

--dcache (2 way associative, LRU)

type dblock is record
	valid		:	std_logic;
	tag			:	std_logic_vector(DCACHE_TAG_SIZE-1 downto 0);
	blockdata	:	cacheblock;
end record dblock;

type blks is array (0 to DCACHE_SET_SIZE-1) of dblock;

type dset is record
	blocks		:	blks;
	lastused	:	std_logic;
end record dset;

type dcachearray is array(0 to DCACHE_NUM_SETS-1) of dset;

--icache (DM)

type iblock is record
	valid		:	std_logic;
	tag			:	std_logic_vector(ICACHE_TAG_SIZE-1 downto 0);
	blockdata	:	cacheblock;
end record iblock;

type icachearray is array(0 to ICACHE_NUM_BLOCKS-1) of iblock;

--Aux functions
function to_integer( s : std_logic ) return integer;

-- For the testbench
constant period : time := 4 ns;
constant half_period : time := 2 ns;

end constants;

package body constants is

	function to_integer( s : std_logic ) return integer is
	begin
	  if s = '1' then
	    return 1;
	  else
	    return 0;
	  end if;
	end function;

end package body;