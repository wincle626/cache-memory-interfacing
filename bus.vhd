library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity bus64w is
	port (	clk : in std_logic;
			bus_data_in : in busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --from chace
			bus_data_out : out busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --to cache
			bus_data_bir : inout busdataarray (BUS_SIZE-1 downto 0) := (others => (others => '0')); --from/to mem
			bus_control : in buscontrolarray (BUS_SIZE-1 downto 0) := (others => '0'); --cache wants to (1: read, 0: write->enable bir output) from/to the mem
			bus_bir_ready : in buscontrolarray (BUS_SIZE-1 downto 0) := (others => '0');
			bus_out_ready : out buscontrolarray (BUS_SIZE-1 downto 0) := (others => '0'));
end bus64w;

architecture behavioral of bus64w is
	signal a: busdataarray(BUS_SIZE-1 downto 0);
	signal b : busdataarray(BUS_SIZE-1 downto 0);
	signal aux_out : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal aux_b : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
	process(clk)
	begin
	    if clk = '1' and clk'event then  -- creates the flipflops
		    for i in bus_control' range loop
		    	a(i) <= bus_data_in(i);
		    	bus_data_out(i) <= b(i);
		    end loop;
		    aux_out <= b(0);
		    bus_out_ready <= (others => '1');
	    end if;
	end process;

	process(bus_control, bus_data_bir, bus_bir_ready)
	begin

		for i in bus_control' range loop
			bus_out_ready(i) <= '0';
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