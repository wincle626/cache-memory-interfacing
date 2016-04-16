library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity dcache is
	port (	clk : in std_logic:
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);  --from CPU
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);   --to CPU
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);	   -- from CPU
			bus_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			bus_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			rw_cache : in std_logic; 		--1: read, 0: write
			i_d_cache : in std_logic; 		--1: Instruction, 0: Data
			--enable_cache : out std_logic; necessary?
			data_cache_ready : out std_logic);
end dcache;

architecture behavioral of dcache is
	signal cache : dcachearray;
	signal tag : std_logic_vector(DCACHE_TAG_SIZE-1 downto 0);
	signal index : std_logic_vector(DCACHE_INDEX_SIZE-1 downto 0);
	signal word_offset : std_logic_vector(DCACHE_WORD_OFFSET-1 downto 0);
	variable selected_set : integer;
	variable present_block : integer;
	variable present : boolean := false;

	process
	begin

	if i_d_cache = '0' then  --data cache
		data_cache_ready <= '0';
		tag <= address(31 downto 7);
		index <= address(6 downto 4);
		word_offset <= address(3 downto 2);
		selected_set <= to_integer(unsigned(index));
		selected_word_offset <= to_integer(unsigned(word_offset));

		if cache[selected_set].blocks[0].tag = tag & cache[selected_set].blocks[0].valid = 1 then
			present_block <= 0;
			present = true;
		elsif cache[selected_set].blocks[1].tag = tag & cache[selected_set].blocks[1].valid = 1 then
		 	present_block <= 1;
		 	present = true;
		else
			present = false;
		end if ;

		if rw_cache = 1 then --read
			if present = false then --bring from memory
				--todo read from memory and substitute LRU
			end if ;
			data_out <= cache[selected_set].blocks[present_block].blockdata[selected_word_offset];
		else  --write
			--todo: write to memory
			if present = false then --bring from memory
				--todo read from memory and substitute LRU
			end if ;
		end if ;
		wait until clk='1';
		data_cache_ready <= '1';
	end if ;

	end process;


end behavioral;