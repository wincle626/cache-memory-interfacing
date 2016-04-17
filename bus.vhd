library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity bus64w is
	port (	clk : in std_logic;
			bus_data_in : in busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --from chace
			bus_data_out : out busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --to cache
			bus_data_bir : inout busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --from/to mem
			bus_control : in buscontrolarray (BUS_SIZE-1 downto 0)); --cache wants to (1: read, 0: write->enable bir output) from/to the mem
end bus64w;

architecture behavioral of bus64w is
	signal a: busdataarray(BUS_SIZE-1 downto 0);
	signal b : busdataarray(BUS_SIZE-1 downto 0);
begin
	process(clk)
	begin
	    if clk = '1' and clk'event then  -- creates the flipflops
		    for i in bus_control' range loop
		    	a(i) <= bus_data_in(i);
		    	bus_data_out(i) <= b(i);
		    end loop;
	    end if;
	end process;

	process(bus_control, bus_data_bir)
	begin

		for i in bus_control' range loop
			if bus_control(i) = '1' then
				bus_data_bir(i) <= (others => 'Z');
				b(i) <= bus_data_bir(i);
			else
				bus_data_bir(i) <= a(i);
				b(i) <= bus_data_bir(i);
			end if ;
		end loop;

	end process;
end behavioral;