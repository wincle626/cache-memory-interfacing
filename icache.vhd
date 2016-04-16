library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants.all;

entity icache is
	port (	clk : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);  --from CPU
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);   --to CPU
			mem_address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0); --to mem
			bus_in : in std_logic_vector (DATA_WIDTH-1 downto 0); 		--from mem
			rw_cache : in std_logic; 		--1: read, 0: write
			i_d_cache : in std_logic; 		--1: Instruction, 0: Data
			data_cache_ready : out std_logic;
			mem_enable : out std_logic;
			mem_rw : out std_logic;
			mem_data_ready : in std_logic);
end icache;

architecture behavioral of icache is
	signal cache : icachearray;
	signal tag : std_logic_vector(ICACHE_TAG_SIZE-1 downto 0);
	signal index : std_logic_vector(ICACHE_INDEX_SIZE-1 downto 0);
	signal word_offset : std_logic_vector(ICACHE_WORD_OFFSET-1 downto 0);

begin
	process
		variable selected_block : integer;
		variable selected_word_offset : integer;
	begin

	if (i_d_cache = '1') and (rw_cache = '1') then  --inst cache
		data_cache_ready <= '0';
		tag <= address(31 downto 9);
		index <= address(8 downto 4);
		word_offset <= address(3 downto 2);
		selected_block := to_integer(unsigned(index));
		selected_word_offset := to_integer(unsigned(word_offset));

		if (cache(selected_block).tag /= tag) or (cache(selected_block).valid = '0') then --not present
			--bring block from memory
			for i in 0 to CACHE_BLOCK_SIZE-1 loop --read four 4 words and save to cache
				mem_address <= std_logic_vector(unsigned(address) + i);
				mem_enable <= '1';
				mem_rw <= '1';
				wait for 16 ns;
				wait until mem_data_ready = '1';
				cache(selected_block).blockdata(i) <= bus_in;
				mem_enable <= '0';
				wait for 100 ns;
			end loop ;
		end if ;

		data_out <= cache(selected_block).blockdata(selected_word_offset);
		wait until clk='1';
		data_cache_ready <= '1';

	end if;
	end process;

end behavioral;