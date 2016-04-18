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

component bus64w is
	port (	clk : in std_logic;
			bus_data_in : in busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --from chace
			bus_data_out : out busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --to cache
			bus_data_bir : inout busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --from/to mem
			bus_control : in buscontrolarray (BUS_SIZE-1 downto 0); --cache wants to (1: read, 0: write->enable bir output) from/to the mem
			bus_bir_ready : in buscontrolarray (BUS_SIZE-1 downto 0);
			bus_out_ready : out buscontrolarray (BUS_SIZE-1 downto 0));
end component;

component memory is
	port(	clk : in std_logic;
			enable : in std_logic;
			rw : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			data : inout std_logic_vector (DATA_WIDTH-1 downto 0);
			--data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			--data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			data_ready : out std_logic);
end component;

signal address_cc, mem_address_m, mem_address_c : std_logic_vector (ADDRESS_WIDTH-1 downto 0);
signal data_cache_cpu, data_cpu_cache, data_mem_cache_c, data_bir_mem, data_cache_mem_c : std_logic_vector (DATA_WIDTH-1 downto 0);
signal rw_cache, i_d_cache, data_cache_ready, mem_data_ready, mem_rw, mem_enable, cache_enable : std_logic;

signal bus_conex_in, bus_conex_out, bus_conex_bir : busdataarray (BUS_SIZE-1 downto 0);
signal bus_control, bus_bir_ready, bus_out_ready : buscontrolarray (BUS_SIZE-1 downto 0);

begin

	--Monitoring
	address_cc_out <= address_cc;
	mem_address_out <= mem_address_m;
	data_cache_cpu_out <= data_cache_cpu;
	data_cpu_cache_out <= data_cpu_cache;
	data_mem_cache_out <= data_bir_mem;
	data_cache_mem_out <= data_cache_mem_c;
	-------------------------------------

	--Conexions to mem bus
	mem_address_m <= mem_address_c;

	--Conexions to data bus
	bus_conex_in <= (data_cache_mem_c, others => (others => '0'));
	bus_conex_out <= (data_mem_cache_c, others => (others => '0'));
	bus_conex_bir <= (data_bir_mem, others => (others => '0'));
	bus_control <= (mem_rw, others => '0');
	bus_bir_ready <= (mem_data_ready, others => '0');


	-------------------------------------


	cpu_elem: cpu
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, rw_cache, i_d_cache, cache_enable, data_cache_ready, PC_out, IR_out, MDR_out);

	icache_elem: icache
		port map (clk, address_cc, data_cache_cpu, mem_address_c, data_mem_cache_c, rw_cache, i_d_cache,
				  cache_enable, data_cache_ready, mem_enable, mem_rw, bus_out_ready(BUS_SIZE-1), IHc);

	dcache_elem: dcache
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, mem_address_c, data_mem_cache_c, data_cache_mem_c,
			  	  rw_cache, i_d_cache, cache_enable, data_cache_ready, mem_enable, mem_rw, bus_out_ready(BUS_SIZE-1), DHc);

	bus_elem: bus64w
		port map (clk, bus_conex_in, bus_conex_out, bus_conex_bir, bus_control, bus_bir_ready, bus_out_ready);

	memory_elem: memory
		port map (clk, mem_enable, mem_rw, mem_address_m, data_bir_mem, mem_data_ready);

end struct;