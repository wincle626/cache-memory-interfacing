library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity bus64w is
	port (	clk : in std_logic;
			bus_data_l : inout busdataarray (BUS_SIZE-1 downto 0);
			bus_data_r : inout busdataarray (BUS_SIZE-1 downto 0);
			bus_control : in buscontrolarray (BUS_SIZE-1 downto 0)); --left side wants to (1: read, 0: write) from/to the right side
end bus64w;

architecture behavioral of bus64w is

begin
	process
	begin
		wait until clk='1';

		for i in bus_control' range loop
			if bus_control(i) = '1' then
				bus_data_l(i) <= bus_data_r(i);
			else
				bus_data_r(i) <= bus_data_l(i);
			end if ;
		end loop;

	end process;
end behavioral;