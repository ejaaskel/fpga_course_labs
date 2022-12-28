library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

use std.textio.all ;
use ieee.std_logic_textio.all ;

entity test_PWM is
end;

architecture test of test_PWM is

component PWM is
	Generic (
		bit_depth	: integer := 8;
		input_clk	: integer := 50000000; -- 50MHz
		freq		: integer := 50); -- 50Hz
	Port (
		pwm_out 	: out std_logic;
		resolution	: in std_logic_vector(bit_depth - 1 downto 0);
		clk			: in std_logic;
		enable		: in std_logic);
end component;

-- Simulation constants
constant bit_depth			: integer := 4;
constant input_clk			: integer := 400;
constant freq				: integer := 5;

-- Simulation signals
signal pwm_out_sim					: std_logic := '0';
signal resolution_sim				: std_logic_vector(bit_depth-1 downto 0) := (others => '0');
signal clk_sim       				: std_logic := '0';
signal enable_sim		    		: std_logic := '1';

begin

resolution_sim <= "1000";

dev_to_test : PWM 
	generic map (
		bit_depth => bit_depth,
		input_clk => input_clk,
		freq => freq)
	port map (
	
		pwm_out => pwm_out_sim,
		resolution => resolution_sim,
		clk => clk_sim,
		enable => enable_sim);
	
clk_proc : process
  begin
      wait for 10 ns;
      clk_sim <= not clk_sim;
end process clk_proc;

reset_proc : process
  begin
      wait for 15 ns;
      enable_sim <= '0';
end process reset_proc;
	
end test;