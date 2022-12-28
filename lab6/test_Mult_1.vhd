-- test_mult_1.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use std.textio.all ;
use ieee.std_logic_textio.all ;
use work.sim_mem_init.all;

entity test_Mult_1 is
end;

architecture test of test_Mult_1 is
  
component Mult_1
generic (
	input_size 					: integer := 4);
port (
	product						: out unsigned(2*input_size-1 downto 0);
	data_ready					: out std_logic;
	input_1						: in unsigned(input_size-1 downto 0);
	input_2						: in unsigned(input_size-1 downto 0);
	start						: in std_logic;
	reset						: in std_logic;
	clk							: in std_logic);
end component;

constant input_size : integer := 4;
-- signals to connect to the multiplier
signal input_1 					: unsigned(input_size-1 downto 0);
signal input_2 					: unsigned(input_size-1 downto 0);
signal data 					: unsigned(7 downto 0);
signal product	 				: unsigned(2*input_size-1 downto 0);
signal data_ready 				: std_logic := '0';
signal start 					: std_logic := '0';
signal reset 					: std_logic := '0';
signal clk 						: std_logic := '0';

constant in_fname 				: string := "input.csv";
file input_file 				: text;

begin
   
	-- test the multiplier
	dev_to_test : mult_1 
		generic map(input_size)
		port map (product, data_ready, input_1, input_2, start, reset, clk);
								
	clk_proc: process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process clk_proc;
	
	stimulus: process
	
	variable input_line			: line;
	variable WriteBuf 			: line ;
	variable in_char			: character;
	variable in_slv				: std_logic_vector(7 downto 0);
	variable ErrCnt 			: integer := 0 ;
	variable line_num 			: integer := 0;
		
	begin
			  
		file_open(input_file, in_fname, read_mode);
		wait for 10 ns;
		reset <= '0';
		
		while not(endfile(input_file)) loop
                
			readline(input_file,input_line);
        	
			-- let's read the first 10 characters in the row
			for i in 0 to 6 loop
				read(input_line,in_char);
				in_slv := std_logic_vector(to_unsigned(character'pos(in_char),8));
			  
				if(i = 3) then
					input_1 <= unsigned(ASCII_to_hex(in_slv));
				elsif(i = 4) then
					input_2 <= unsigned(ASCII_to_hex(in_slv));
				--elsif(i = 6) then
					--input_2(7 downto 4) <= unsigned(ASCII_to_hex(in_slv));
				--elsif(i = 7) then
					--input_2(3 downto 0) <= unsigned(ASCII_to_hex(in_slv));
				elsif(i = 6) then
					start <= in_slv(0);
				end if;
			end loop;
			
			wait for 20 ns;
						
			if((input_1*input_2 /= product) and (data_ready = '1') and (start = '0')) then
				write(WriteBuf, string'("ERROR:  multiplier failed at line = "));
				write(WriteBuf, line_num);
				write(WriteBuf, string'(".  expected = "));
				write(WriteBuf, std_logic_vector(input_1*input_2));
				write(WriteBuf, string'(", product = "));
				write(WriteBuf, std_logic_vector(product));
			
				writeline(Output, WriteBuf);
				ErrCnt := ErrCnt+1;
			end if; 
			line_num := line_num + 1;
		end loop;
		file_close(input_file);		

		if (ErrCnt = 0) then 
			report "SUCCESS!!!  Multiplier Test Completed!";
		else
			report "multiplier device is broken" severity warning;
		end if;
	end process stimulus;
end test;