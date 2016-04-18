library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity tb_bus is
end entity;

architecture testbench of tb_bus is
    signal clk : std_logic := '0';
    signal bus_data_l, bus_data_r : busdataarray (BUS_SIZE-1 downto 0);
    signal bus_control : buscontrolarray (BUS_SIZE-1 downto 0);

    component bus64w 
        port (  clk : in std_logic;
                bus_data_l : inout busdataarray (BUS_SIZE-1 downto 0);
                bus_data_r : inout busdataarray (BUS_SIZE-1 downto 0);
                bus_control : in buscontrolarray (BUS_SIZE-1 downto 0)); --left side wants to (1: read, 0: write) from/to the right side
    end component;


begin
  UUT : bus64w Port map (clk, bus_data_l, bus_data_r, bus_control);

  clk <= not clk after half_period;

  bus_control <= ('0', '1', others => '0');

  stim: process 
  begin
   bus_data_r(1) <= x"ffffffff";
   wait until clk='1';

   wait for 100 ns;

  end process;
end testbench;