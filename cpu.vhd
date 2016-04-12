library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity cpu is
	port (	clk : in std_logic:
			address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			rw_cache : out std_logic; --1: read, 0: write
			--enable_cache : out std_logic; necessary?
			data_cache_ready : in std_logic);
end cpu;

architecture behavioral of cpu is
signal PC : std_logic_vector (31 downto 0) <= '0';
signal IR : std_logic_vector (31 downto 0);
signal registers : regs;
signal rs, rt, rd : std_logic_vector (4 downto 0);
signal inm : std_logic_vector (15 downto 0);

	FETCH: process
	begin
		address <= PC;
		rw_cache <= '1';
		wait until data_cache_ready='1';
		--address <= (others => 'Z');
		IR <= data_in;
		case IR(31 downto 16) is
			when "100011" =>	--LOAD
				rs <= IR(25 downto 21);
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				address <= (registers(to_integer(unsigned(rs))) + to_integer(unsigned(inm)));
				rw_cache <= '1';
				wait until data_cache_ready='1';
				--address <= (others => 'Z');
				registers(to_integer(unsigned(rt))) <= data_in;
				PC <= PC + 4;
			when "101011" =>
				--STORE
				rs <= IR(25 downto 21);
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				rw_cache <= '0';
				address <= (registers(to_integer(unsigned(rs))) + to_integer(unsigned(inm)));
				--TODO: Add syncro cycles with cache

				PC <= PC + 4;
			when "000000" =>
				--ALU REGISTERS
			when "000100" =>
				--BEQ
			when "001101" =>
				--XORI (ALU inm)
			when "000010"=>
				--J
			--when ...
			when others =>

		end case;

	end process;


end behavioral;