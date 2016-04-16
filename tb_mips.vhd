library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity tb_memory is
end entity;

architecture testbench of tb_memory is

	component mips
		port(	clk : in std_logic);
	end component;
	
begin
	UUT : memory Port map (clk, enable, rw, address, data_in, data_out, data_ready);

	clk <= not clk after half_period;

end testbench;