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
			bus_data_l : inout busdataarray (BUS_SIZE-1 downto 0);
			bus_data_r : inout busdataarray (BUS_SIZE-1 downto 0);
			bus_control : in buscontrolarray (BUS_SIZE-1 downto 0)); --left side wants to (1: read, 0: write) from/to the right side
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

signal address_cc, mem_address_m, mem_address_c : std_logic_vector (ADDRESS_WIDTH-1 downto 0);
signal data_cache_cpu, data_cpu_cache, data_mem_cache_m, data_mem_cache_c, data_cache_mem_m, data_cache_mem_c : std_logic_vector (DATA_WIDTH-1 downto 0);
signal rw_cache, i_d_cache, data_cache_ready, mem_data_ready, mem_rw, mem_enable, cache_enable : std_logic;

signal bus_conex_l, bus_conex_r : busdataarray (BUS_SIZE-1 downto 0);
signal bus_control : buscontrolarray (BUS_SIZE-1 downto 0);

begin

	--Monitoring
	address_cc_out <= address_cc;
	mem_address_out <= mem_address_m;
	data_cache_cpu_out <= data_cache_cpu;
	data_cpu_cache_out <= data_cpu_cache;
	data_mem_cache_out <= data_mem_cache_m;
	data_cache_mem_out <= data_cache_mem_c;
	-------------------------------------

	--Conexions to bus
	bus_conex_l(0) <= mem_address_c;
	bus_conex_r(0) <= mem_address_m;

	bus_conex_l(1) <= data_mem_cache_c;
	bus_conex_r(1) <= data_mem_cache_m;

	bus_conex_l(2) <= data_cache_mem_c;
	bus_conex_r(2) <= data_cache_mem_m;

	bus_control <= ('0', '1', '0', others => '0');
	-------------------------------------


	cpu_elem: cpu
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, rw_cache, i_d_cache, cache_enable, data_cache_ready, PC_out, IR_out, MDR_out);

	icache_elem: icache
		port map (clk, address_cc, data_cache_cpu, mem_address_c, data_mem_cache_c, rw_cache, i_d_cache, 
				  cache_enable, data_cache_ready, mem_enable, mem_rw, mem_data_ready, IHc);

	dcache_elem: dcache
		port map (clk, address_cc, data_cache_cpu, data_cpu_cache, mem_address_c, data_mem_cache_c, data_cache_mem_c, 
			  	  rw_cache, i_d_cache, cache_enable, data_cache_ready, mem_enable, mem_rw, mem_data_ready, DHc);

	bus_elem: bus64w
		port map (clk, bus_conex_l, bus_conex_r, bus_control);

	memory_elem: memory
		port map (clk, mem_enable, mem_rw, mem_address_m, data_cache_mem_m, data_mem_cache_m, mem_data_ready);

end struct;