library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity icache is
	port (	clk : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);  --from CPU
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0) := (others => 'Z');   --to CPU
			mem_address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0) := (others => 'Z'); --to mem
			bus_in : in std_logic_vector (DATA_WIDTH-1 downto 0); 		--from mem
			rw_cache : in std_logic; 		--1: read, 0: write
			i_d_cache : in std_logic; 		--1: Instruction, 0: Data
			cache_enable : in std_logic;
			data_cache_ready : out std_logic := 'Z';
			mem_enable : out std_logic := 'Z';
			mem_rw : out std_logic := 'Z';
			mem_data_ready : in std_logic;
			IHc : out std_logic);
end icache;

architecture behavioral of icache is
	signal cache : icachearray := (others => ('0', (others => '0'), (others => (others => '0'))));
	signal tag : std_logic_vector(ICACHE_TAG_SIZE-1 downto 0);
	signal index : std_logic_vector(ICACHE_INDEX_SIZE-1 downto 0);
	signal word_offset : std_logic_vector(ICACHE_WORD_OFFSET-1 downto 0);

begin
	process
		variable selected_block : integer;
		variable selected_word_offset : integer;
	begin
		wait until cache_enable='1';
		data_out <= (others => 'Z');
		data_cache_ready <= 'Z';
		if (i_d_cache = '1') and (rw_cache = '1') then  --inst cache
			data_cache_ready <= '0';
			tag <= address(31 downto 9);
			index <= address(8 downto 4);
			word_offset <= address(3 downto 2);

			wait until clk='1'; --cache access 1 cycle

			selected_block := to_integer(unsigned(index));
			selected_word_offset := to_integer(unsigned(word_offset));

			if (cache(selected_block).tag /= tag) or (cache(selected_block).valid = '0') then --not present
				--bring block from memory
				IHc <= '0';
				for i in 0 to CACHE_BLOCK_SIZE-1 loop --read four 4 words and save to cache
					mem_address <= std_logic_vector(unsigned(std_logic_vector'(address(31 downto 4) & "0000")) + i*4);
					mem_enable <= '1';
					mem_rw <= '1';
					wait until mem_data_ready = '1';
					wait until clk='1';
					cache(selected_block).blockdata(i) <= bus_in;
					mem_address <= (others => 'Z');
					mem_enable <= '0';
					mem_rw <= 'Z';
					wait until mem_data_ready = '0';
				end loop ;
				cache(selected_block).valid <= '1';
			else
				IHc <= '1';
			end if ;

			data_out <= cache(selected_block).blockdata(selected_word_offset);
			wait until clk='1';
			data_cache_ready <= '1';

		end if;
	end process;

end behavioral;