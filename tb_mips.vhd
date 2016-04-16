library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity tb_mips is
end entity;

architecture testbench of tb_mips is

signal clk : std_logic := '0';
signal PC_out, IR_out, address_cc_out, mem_address_out : std_logic_vector (ADDRESS_WIDTH-1 downto 0);
signal MDR_out, data_cache_cpu_out, data_cpu_cache_out, data_mem_cache_out, data_cache_mem_out : std_logic_vector (ADDRESS_WIDTH-1 downto 0);
signal IHc, DHc : std_logic;

	component mips
		port(	clk : in std_logic;
				PC_out, IR_out, address_cc_out, mem_address_out : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
				MDR_out, data_cache_cpu_out, data_cpu_cache_out, data_mem_cache_out, data_cache_mem_out : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
				IHc, DHc : out std_logic);
	end component;

begin
	UUT : mips Port map (clk, PC_out, IR_out, address_cc_out, mem_address_out, MDR_out, data_cache_cpu_out, data_cpu_cache_out, data_mem_cache_out, data_cache_mem_out, IHc, DHc);

	clk <= not clk after half_period;

end testbench;