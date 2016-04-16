library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity mips is
	port(	clk : in std_logic);
end mips;

architecture struct of mips is
component cpu
	port (	clk : in std_logic;
			address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			rw_cache : out std_logic; 		--1: read, 0: write
			i_d_cache : out std_logic; 		--1: Instruction, 0: Data
			--enable_cache : out std_logic; --necessary?
			data_cache_ready : in std_logic);
end component;

component icache
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
end component;

component dcache
	port (	clk : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);  --from CPU
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);   --to CPU
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);	   -- from CPU
			mem_address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0); --to mem
			bus_in : in std_logic_vector (DATA_WIDTH-1 downto 0); 		--from mem
			bus_out : out std_logic_vector (DATA_WIDTH-1 downto 0);		--to mem
			rw_cache : in std_logic; 		--1: read, 0: write
			i_d_cache : in std_logic; 		--1: Instruction, 0: Data
			data_cache_ready : out std_logic;
			mem_enable : out std_logic;
			mem_rw : out std_logic;
			mem_data_ready : in std_logic);
end component;

component memory 
	port(	clk : in std_logic;
			enable : in std_logic;
			rw : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			data_ready : out std_logic);
end component;

signal address_cc, mem_address : std_logic_vector (ADDRESS_WIDTH-1 downto 0);
signal data_cache_cpu, data_cpu_cache, data_mem_cache, data_cache_mem : std_logic_vector (DATA_WIDTH-1 downto 0);
signal rw_cache, i_d_cache, data_cache_ready, mem_data_ready, mem_rw, mem_enable : std_logic;

begin
	cpu1: cpu
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, rw_cache, i_d_cache, data_cache_ready);

	icache1: icache
		port map (clk, address_cc, data_cache_cpu, mem_address, data_mem_cache, rw_cache, 
				  i_d_cache, data_cache_ready, mem_enable, mem_rw, mem_data_ready);

	dcache1: dcache
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, mem_address, data_mem_cache, 
				  data_cache_mem, rw_cache, i_d_cache, data_cache_ready, mem_enable, mem_rw, mem_data_ready);

	memory1: memory
		port map (clk, mem_enable, mem_rw, mem_address, data_cache_mem, data_mem_cache, mem_data_ready);

end struct;