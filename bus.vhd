library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity bus64w is
	port (	clk : in std_logic;
			bus_data_in : in busdataarray (BUS_SIZE-1 downto 0); --from chace
			bus_data_out : out busdataarray (BUS_SIZE-1 downto 0); --to cache
			bus_data_bir : inout busdataarray (BUS_SIZE-1 downto 0); --from/to mem
			bus_control : in buscontrolarray (BUS_SIZE-1 downto 0) := (others => '0'); --cache wants to (1: read, 0: write->enable bir output) from/to the mem
			bus_bir_ready : in buscontrolarray (BUS_SIZE-1 downto 0) := (others => '0');
			bus_out_ready : out buscontrolarray (BUS_SIZE-1 downto 0) := (others => '0'));
end bus64w;

architecture behavioral of bus64w is
	signal a: busdataarray(BUS_SIZE-1 downto 0);
	signal b : busdataarray(BUS_SIZE-1 downto 0);
	signal out_ready : buscontrolarray (BUS_SIZE-1 downto 0) := (others => '0');
	signal aux_out : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal aux_b : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
	process
	begin
	    wait until clk='1';
	 		--for i in 0 to BUS_SIZE-1 loop
	   -- 		a(i) <= bus_data_in(i);
		  --  	bus_data_out(i) <= b(i);
	   -- 	end loop ;
		    for i in bus_control' range loop
		    	a(i) <= bus_data_in(i);
		    	bus_data_out(i) <= b(i);
		    	aux_out <= b(BUS_SIZE-1);
		    	bus_data_out(BUS_SIZE-1) <= b(BUS_SIZE-1);
		    end loop;
		    bus_out_ready <= out_ready;
	end process;

	process(bus_control, bus_data_bir, bus_bir_ready)
	begin

		for i in bus_control' range loop
			out_ready(i) <= bus_bir_ready(i);
			if bus_control(i) = '1' then
				bus_data_bir(i) <= (others => 'Z');
				b(i) <= bus_data_bir(i);
			elsif bus_control(i) = '0' then
				bus_data_bir(i) <= a(i);
				b(i) <= bus_data_bir(i);
			else
				bus_data_bir(i) <= (others => 'Z');
				b(i) <= (others => 'Z');
			end if ;
		end loop;
			aux_b <= bus_data_bir(0);

	end process;
end behavioral;