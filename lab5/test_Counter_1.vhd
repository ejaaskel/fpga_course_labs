library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

use std.textio.all ;
use ieee.std_logic_textio.all ;

entity test_Counter_1 is
end;

architecture test of test_Counter_1 is

component Counter_1 is
	Generic (
		max_val							: integer := 2**30);
	Port (
		count	  						: out std_logic_vector(integer(ceil(log2(real(max_val))))-1 downto 0);
		clk     						: in std_logic;
		reset    						: in std_logic
	);
end component;

constant max_val						: integer := 10;
constant bit_depth						: integer := integer(ceil(log2(real(max_val))));

constant synch_reset					: boolean := true;
signal count_out						: std_logic_vector(bit_depth-1 downto 0) := (others => '0');
signal max_count_out       				: std_logic := '0';
signal reset_in		    				: std_logic := '1';
signal clk_in           				: std_logic := '0';

begin

dev_to_test : Counter_1 
	generic map (
		max_val => max_val)
	port map (
		count => count_out,
		clk => clk_in,
		reset => reset_in);
	
clk_proc : process
  begin
      wait for 10 ns;
      clk_in <= not clk_in;
end process clk_proc;

reset_proc : process
  begin
      wait for 15 ns;
      reset_in <= '0';
end process reset_proc;
	
end test;
