library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;

entity dcache is
	port (	clk : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);  --from CPU
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);   --to CPU
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);	   -- from CPU
			mem_address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0); --to mem
			bus_in : in std_logic_vector (DATA_WIDTH-1 downto 0); 		--from mem
			bus_out : out std_logic_vector (DATA_WIDTH-1 downto 0);		--to mem
			rw_cache : in std_logic; 		--1: read, 0: write
			i_d_cache : in std_logic; 		--1: Instruction, 0: Data
			cache_enable : in std_logic;
			data_cache_ready : out std_logic;
			mem_enable : out std_logic;
			mem_rw : out std_logic;
			mem_data_ready : in std_logic;
			DHc : out std_logic);
end dcache;

architecture behavioral of dcache is
	signal cache : dcachearray;
	signal tag : std_logic_vector(DCACHE_TAG_SIZE-1 downto 0);
	signal index : std_logic_vector(DCACHE_INDEX_SIZE-1 downto 0);
	signal word_offset : std_logic_vector(DCACHE_WORD_OFFSET-1 downto 0);

begin
	process
		variable selected_set : integer;
		variable present_block : integer;
		variable present : boolean := false;
		variable selected_word_offset : integer;
	begin
	wait until cache_enable='1';
	if (i_d_cache = '0') then  --data cache
		data_cache_ready <= '0';
		tag <= address(31 downto 7);
		index <= address(6 downto 4);
		word_offset <= address(3 downto 2);
		selected_set := to_integer(unsigned(index));
		selected_word_offset := to_integer(unsigned(word_offset));

		if (cache(selected_set).blocks(0).tag = tag) and (cache(selected_set).blocks(0).valid = '1') then
			present_block := 0;
			present := true;
			DHc <= '1';
		elsif (cache(selected_set).blocks(1).tag = tag) and (cache(selected_set).blocks(1).valid = '1') then
		 	present_block := 1;
		 	present := true;
		 	DHc <= '1';
		else
			present := false;
			DHc <= '0';
		end if ;

		if rw_cache = '0' then  --write
			--write to memory
			mem_address <= address;
			mem_enable <= '1';
			mem_rw <= '0';
			bus_out <= data_in;
			wait for 32 ns;
			wait for 12 ns;
			mem_enable <= '0';
			wait for 100 ns;
		end if ;

		if present = false then --bring from memory
			present_block := to_integer(not cache(selected_set).lastused); --selected block --> LRU
			for i in 0 to CACHE_BLOCK_SIZE-1 loop --read four 4 words and save to cache
				mem_address <= std_logic_vector(unsigned(address) + i*4);
				mem_enable <= '1';
				mem_rw <= '1';
				wait for 16 ns;
				wait until mem_data_ready = '1';
				cache(selected_set).blocks(present_block).blockdata(i) <= bus_in;
				mem_enable <= '0';
				wait for 100 ns;
			end loop ;
		end if ;

		if rw_cache = '1' then --read
			data_out <= cache(selected_set).blocks(present_block).blockdata(selected_word_offset);
		elsif (rw_cache = '0') and (present = true) then -- write and hit, then write to cache
			cache(selected_set).blocks(present_block).blockdata(selected_word_offset) <= data_in;
		end if ;

		cache(selected_set).lastused <= std_logic(to_unsigned(present_block, 1)(0));
		wait until clk='1';
		data_cache_ready <= '1';

	end if ;

	end process;


end behavioral;