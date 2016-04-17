library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.constants.all;

entity memory is
	port(	clk : in std_logic;
			enable : in std_logic;
			rw : in std_logic;
			address : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
			data : inout std_logic_vector (DATA_WIDTH-1 downto 0);
			--data_in : in std_logic_vector (DATA_WIDTH-1 downto 0);
			--data_out : out std_logic_vector (DATA_WIDTH-1 downto 0);
			data_ready : out std_logic);
end memory;

architecture ram of memory is

--TODO: Make write for 4 words (block)?
signal mem : memoryarray := ("00001111", "00000000",  "00001001", "00100000",
								"00010100", "00000000", "00001010", "00100000",
								"01100100", "00000000", "01001001", "10101101",
								"01101000", "00000000", "01001010", "10101101",
								"01100100", "00000000", "01001011", "10001101",
								"01101000", "00000000", "01001100", "10001101",
								"11111111", "11111111", "01101101", "00110101",
								"00100000", "01100000", "00101010", "00000001",
								"00001000", "00000000", "00001110", "10001100",
								"00001010", "00000000", "00001111", "00100000",
								"00000001", "00000000", "11101111", "00100001",
								"00000001", "00000000", "11101001", "00010001",
								"00001010", "00000000", "00000000", "00001000",
								"11011100", "11111110", "00011000", "00111100",
								"00001000",	"00000000", "00000000", "00000000",
								others => (others => '0'));
signal address_buff_r, address_buff_w : std_logic_vector (ADDRESS_WIDTH-1 downto 0);

begin
	READ_MEM: process 		--READ
	begin
		wait until clk='1';
		if enable='1' and rw='1' then
			--Memory port access time: 4 cycles
			data_ready <= '0';
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			address_buff_r <= address;

			--Read time: 2 cycles
			wait until clk='1';
			wait until clk='1';
			data <= (mem(to_integer(unsigned(address_buff_r))+3) &
					 mem(to_integer(unsigned(address_buff_r))+2) &
					 mem(to_integer(unsigned(address_buff_r))+1) &
					 mem(to_integer(unsigned(address_buff_r))));
			data_ready <= '1';
		elsif rw='1' then
			data <= (others => 'Z');
			data_ready <= '0';
		end if;

	end process;

	WRITE_MEM: process 	--WRITE
	begin
		wait until clk='1';
		if enable='1' and rw='0' then
			--Memory port access time: 8 cycles
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			address_buff_w <= address;

			--Write time: 3 cycles
			wait until clk='1';
			wait until clk='1';
			wait until clk='1';
			mem(to_integer(unsigned(address_buff_w))) <= data(7 downto 0);
			mem(to_integer(unsigned(address_buff_w))+1) <= data(15 downto 8);
			mem(to_integer(unsigned(address_buff_w))+2) <= data(23 downto 16);
			mem(to_integer(unsigned(address_buff_w))+3) <= data(31 downto 24);
		end if;
	end process;

end ram;