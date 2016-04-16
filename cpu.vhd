library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity cpu is
	port (	clk : in std_logic;
			address : out std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			rw_cache : out std_logic; 		--1: read, 0: write
			i_d_cache : out std_logic; 		--1: Instruction, 0: Data
			--enable_cache : out std_logic; --necessary?
			data_cache_ready : in std_logic);
end cpu;

architecture behavioral of cpu is
signal PC : std_logic_vector (31 downto 0) := (others => '0');
signal IR : std_logic_vector (31 downto 0);
signal registers : regs;
signal rs, rt, rd : std_logic_vector (4 downto 0);
signal inm : std_logic_vector (15 downto 0);

	process
	begin
		address <= PC;
		rw_cache <= '1';
		wait until data_cache_ready='1';
		--address <= (others => 'Z');
		IR <= data_in;
		PC <= PC + 4;
		case IR(31 downto 26) is
			when "100011" =>		--LOAD
				rs <= IR(25 downto 21);
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				address <= (registers(to_integer(unsigned(rs))) + to_integer(unsigned(inm)));
				rw_cache <= '1';
				wait until data_cache_ready='1';
				--address <= (others => 'Z');
				registers(to_integer(unsigned(rt))) <= data_in;
			when "101011" =>		--STORE
				rs <= IR(25 downto 21);
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				rw_cache <= '0';
				address <= (registers(to_integer(unsigned(rs))) + to_integer(unsigned(inm)));
				--TODO: Add syncro cycles with cache

			when "000000" =>
				if IR(5 dowto 0) = "100000" then	--ADD
					rs <= IR(25 downto 21);
					rt <= IR(20 downto 16);
					rd <= IR(15 downto 11);
					registers(to_integer(unsigned(rd))) <= (registers(to_integer(unsigned(rs))) + registers(to_integer(unsigned(rt))));
				
				elsif IR(5 downto 0) = "001000" then	--JR
					rs <= IR(25 downto 21);
					PC <= registers(to_integer(unsigned(rs)));
				end if ;

			when "000100" => --BEQ
				rs <= IR(25 downto 21);
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				if registers(to_integer(unsigned(rs))) = registers(to_integer(unsigned(rt))) then
					PC <= PC + 4 + (to_integer(unsigned(inm)) sll 2);
				end if ;

			when "001101" => --XORI (ALU inm)
				rs <= IR(25 downto 21);
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				registers(to_integer(unsigned(rt))) <= (registers(to_integer(unsigned(rs))) xor to_integer(unsigned(inm)));

			when "000010"=>	--J
				inm <= IR(25 downto 0);
				PC <= PC + (to_integer(unsigned(inm)) sll 2);

			when "001000" => --ADDI
				rs <= IR(25 downto 21);
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				registers(to_integer(unsigned(rt))) <= (registers(to_integer(unsigned(rs))) + to_integer(unsigned(inm)));

			when "001111" => --LUI
				rt <= IR(20 downto 16);
				inm <= IR(15 downto 0);
				registers(to_integer(unsigned(rt))) <= (inm sll 16);

			when others =>
				PC <= 0;
		end case;
	end process;
end behavioral;
