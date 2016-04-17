library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity mips is
	port(	clk : in std_logic;
			PC_out, IR_out, address_cc_out, mem_address_out : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			MDR_out, data_cache_cpu_out, data_cpu_cache_out, data_mem_cache_out, data_cache_mem_out : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			IHc, DHc : out std_logic);
end mips;

architecture struct of mips is
component cpu
	port (	clk : in std_logic;
			address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			rw_cache : out std_logic; 		--1: read, 0: write
			i_d_cache : out std_logic; 		--1: Instruction, 0: Data
			cache_enable : out std_logic;
			data_cache_ready : in std_logic;
			PC_out : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			IR_out : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			MDR_out : out std_logic_vector (DATA_WIDTH-1 downto 0));
end component;

component icache
	port (	clk : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);  --from CPU
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);   --to CPU
			mem_address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0); --to mem
			bus_in : in std_logic_vector (DATA_WIDTH-1 downto 0); 		--from mem
			rw_cache : in std_logic; 		--1: read, 0: write
			i_d_cache : in std_logic; 		--1: Instruction, 0: Data
			cache_enable : in std_logic;
			data_cache_ready : out std_logic;
			mem_enable : out std_logic;
			mem_rw : out std_logic;
			mem_data_ready : in std_logic;
			IHc : out std_logic);
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
			cache_enable : in std_logic;
			data_cache_ready : out std_logic;
			mem_enable : out std_logic;
			mem_rw : out std_logic;
			mem_data_ready : in std_logic;
			DHc : out std_logic);
end component;

component bus64w
	port (	clk : in std_logic;
			bus_in : in std_logic_vector ((64*DATA_WIDTH)-1 downto 0);
			bus_out : out std_logic_vector ((64*DATA_WIDTH)-1 downto 0));
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

signal address_cc, mem_address1, mem_address2 : std_logic_vector (ADDRESS_WIDTH-1 downto 0);
signal data_cache_cpu, data_cpu_cache, data_mem_cache1, data_mem_cache2, data_cache_mem1, data_cache_mem2 : std_logic_vector (DATA_WIDTH-1 downto 0);
signal rw_cache, i_d_cache, data_cache_ready, mem_data_ready, mem_rw, mem_enable, cache_enable : std_logic;

signal bus_aux_1, bus_aux_2 : bussss;
signal bus_signal : std_logic_vector (31 downto 0);
begin

	--Monitoring
	address_cc_out <= address_cc;
	mem_address_out <= mem_address;
	data_cache_cpu_out <= data_cache_cpu;
	data_cpu_cache_out <= data_cpu_cache;
	data_mem_cache_out <= data_mem_cache;
	data_cache_mem_out <= data_cache_mem;
	-------------------------------------

	--Conexions to bus
	bus_aux_1(0) <= mem_address1;
	bus_aux_2(0) <= mem_address2;

	bus_aux_1(1) <= data_mem_cache1;
	bus_aux_2(1) <= data_mem_cache2;

	bus_aux_1(2) <= data_cache_mem1;
	bus_aux_2(2) <= data_cache_mem2;

	--el bus de address ponerlo siempre como cache->memory, el de data_cache_mem igual y el otro al revés
	-------------------------------------


	cpu_elem: cpu
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, rw_cache, i_d_cache, cache_enable, data_cache_ready, PC_out, IR_out, MDR_out);

	icache_elem: icache
		port map (clk, address_cc, data_cache_cpu, mem_address1, data_mem_cache1, rw_cache, i_d_cache, 
				  cache_enable, data_cache_ready, mem_enable, mem_rw, mem_data_ready, IHc);

	dcache_elem: dcache
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, mem_address1, data_mem_cache1, data_cache_mem1, 
			  	  rw_cache, i_d_cache, cache_enable, data_cache_ready, mem_enable, mem_rw, mem_data_ready, DHc);

	bus_elem: bus 
		port map (bus_aux_1, bus_aux2);

	memory1: memory
		port map (clk, mem_enable, mem_rw, mem_address2, data_cache_mem2, data_mem_cache2, mem_data_ready);

end struct;