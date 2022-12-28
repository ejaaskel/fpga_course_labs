--------------------------------- 
-- A PWM implementation in VHDL
---------------------------------
-- Librarys
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity
entity PWM is
Generic (
	bit_depth	: integer := 8;
	input_clk	: integer := 100000000; -- 100MHz
	freq		: integer := 50); -- 50Hz
Port (
	led 	    : out std_logic;
	resolution	: in std_logic_vector(bit_depth - 1 downto 0);
	clk			: in std_logic;
	enable		: in std_logic);
end PWM;

-- Architecture
architecture behavior of PWM is

-- Constants
constant max_freq_count	: integer := input_clk / freq;
constant pwm_step		: integer := max_freq_count / (2**bit_depth);

-- Signals
signal pwm_value		: std_logic := '0';
signal freq_count		: integer range 0 to max_freq_count := 0;
signal pwm_count		: integer range 0 to 2**bit_depth := 0;
signal max_pwm_count	: integer range 0 to 2**bit_depth := 0;
signal pwm_step_count	: integer range 0 to max_freq_count := 0;

begin
	-- Convert resolution to max_pwm_count
	max_pwm_count <= to_integer(unsigned(resolution));
	led <= pwm_value;
	
	-- Process that runs signal out at the correct frequency
	freq_counter : process(clk)
	begin
		if (rising_edge(clk)) then
			if (enable = '0') then
				if (freq_count < max_freq_count) then
					freq_count <= freq_count + 1;
					if (pwm_count < max_pwm_count) then
						pwm_value <= '1';
						if (pwm_step_count < pwm_step) then
							pwm_step_count <= pwm_step_count + 1;
						else
							pwm_step_count <= 0;
							pwm_count <= pwm_count + 1;
						end if;
					else
						pwm_value <= '0';
					end if;
				else
					freq_count <= 0;
					pwm_count <= 0;
				end if;
			else
				pwm_value <= '0';
			end if;
		end if;	
	end process freq_counter;

end behavior;