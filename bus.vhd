library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity bus64w is
	port (	clk : in std_logic;
			bus_in : in std_logic_vector ((64*DATA_WIDTH)-1 downto 0);
			bus_out : out std_logic_vector ((64*DATA_WIDTH)-1 downto 0));
end bus64w;

architecture behavioral of bus64w is

begin
	process
	begin
		wait until clk='1';
		bus_out <= bus_in;
	end process;
end behavioral;