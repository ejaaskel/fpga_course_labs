-------------------------------------------------------------------------------
-- File:		Mult_1.vhd
-- Engineer:	Jordan Christman
-- Description:	Mult_1 is a logically implemented multiplier
--				this solves multiplication through the use of shifts and adds.
-------------------------------------------------------------------------------

-- Lab 6 Tasks

-- 1) Fill in the "?" with the correct values
--
-- 2) Compile & Simulate Mult_1.vhd in ModelSim
--			* Note ModelSim will give you compiling
--			  error's if you do not change the "?"
-- 
-- 3) Implement Mult_1.vhd on your BASYS 2 board
--
-- 4) Complete the .ucf file in order to map the FPGA pins correctly
--
-- 5) Try and implement what you learned in lab 4 to display a
-- 	  the count value on the 7 segment displays. Can you get it
--	  to display on all 4 segments?

-- Note this is a much tougher lab beings that it incorporates State Machines
-- Processes, and if you complete task 5 then you are also dealing with 
-- component instantiations

-- I wish you the best of Luck! If you have any problems
-- don't hesitate to e-mail me!!

-- Use the comments to help you figure out how to
-- get this design to work
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity Declaration
entity Mult_1 is
generic (
	input_size		: integer := 4);
port (
	seg_out		: out std_logic_vector(6 downto 0);
	enable0		: out std_logic;
	enable1		: out std_logic;
	enable2		: out std_logic;
	enable3		: out std_logic;
	input_1					: in unsigned(input_size - 1 downto 0);
	input_2 				: in unsigned(input_size - 1 downto 0);
	start 					: in std_logic;
	reset 					: in std_logic;
	clk 					: in std_logic);
end Mult_1;

-- Architecture Body
architecture behavior of Mult_1 is



-- Note that the names of these signals
-- match up with the block diagram in the
-- Tasking sheet. I would suggest you use
-- that as a reference!

-- State Machine Signals (User Defined)
-- Check out the State Machine examples in the Reference section
-- Don't be afraid to send me an e-mail if you are stuck!
type state_type is(init, load, right_shift, done);
signal state, nxt_state	: state_type;

-- Control Signals
signal shift				: std_logic;
signal add					: std_logic;
signal load_data			: std_logic;

-- Data Signals
constant maxcount			: integer := input_size - 1;
signal input_1_reg			: unsigned(input_size - 1 downto 0) := (others => '0');
signal sum					: unsigned(input_size downto 0) := (others => '0');
signal product_reg			: unsigned(2*input_size - 1 downto 0) := (others => '0');
signal count 				: integer range 0 to maxcount + 1 := 0;
signal start_count_lead		: std_logic := '0';
signal start_count_follow	: std_logic := '0';
signal start_count			: std_logic := '0';

component Hex_to_7_Seg_top
port (
	seg_out		: out std_logic_vector(6 downto 0);
	enable0		: out std_logic;
	enable1		: out std_logic;
	enable2		: out std_logic;
	enable3		: out std_logic;
	hex_in_0	: in std_logic_vector(3 downto 0);
	hex_in_1	: in std_logic_vector(3 downto 0);
	clk 		: in std_logic;
	reset		: in std_logic);
end component;

begin
    seg_disp : Hex_to_7_Seg_top
        port map (seg_out => seg_out,
                  enable0 => enable0,
                  enable1 => enable1,
                  enable2 => enable2,
                  enable3 => enable3,                                
                  hex_in_0 => std_logic_vector(product_reg(2*input_size - 1 downto 4)),
                  hex_in_1 => std_logic_vector(product_reg(3 downto 0)),
                  clk => clk,
                  reset => reset);
	-- 2 process state machine
	------------------------------------
	-- state_proc assigns the next state
	-- 1st process of our state machine
	------------------------------------
	state_proc: process(clk)	-- ah another process! and another sensitivity list!
		begin
		if rising_edge(clk) then
			if(reset = '1') then
				state <= init;			-- remember types have to match up!
			else
				state <= nxt_state;
			end if;
		end if;
	end process state_proc;
	
	-----------------------------------
	-- state_machine determines what 
	-- our next state should be.
	-- Look at the state machine diagram
	-- in the task sheet for a reference
	-- 2nd process of our state machine
	-----------------------------------
	state_machine: process(state, start, start_count, count, product_reg(0))
		begin
		-- initialize nxt_state and control signals
		nxt_state <= state;
		shift <= '0';
		add <= '0';
		load_data <= '0';
		
		case state is
			when init =>
				if(start_count = '1') then
					nxt_state <= load;		-- remember types have to match up!
				else
					nxt_state <= init; -- look at the state machine diagram for reference
				end if;
			when load =>
				load_data <= '1';
				nxt_state <= right_shift;
			when right_shift =>
				shift <= '1';
				if(count /= maxcount) then				-- look at the state machine diagram for reference
					nxt_state <= right_shift;
				else
					nxt_state <= done;
				end if;
				if(product_reg(0) = '1') then
					add <= '1';
				end if;
			when done =>
				if(start = '0') then
					nxt_state <= init;
				else
					nxt_state <= done;
				end if;
			when others =>
				nxt_state <= init;
		end case;
	end process state_machine;
	
	---------------------------------------------------------------
	-- edge detection circuitry
	---------------------------------------------------------------
	-- start_count = '1' on the rising edge of the start input
	start_count <= start_count_lead and (not start_count_follow);
	
	-- Process that starts the state machine on the rising edge of
	-- our clock
	start_count_proc: process(clk)
		begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				start_count_lead <= '0';
				start_count_follow <= '0';
			else
				start_count_lead <= start;
				start_count_follow <= start_count_lead;
			end if;
		end if;
	end process start_count_proc;
	
	-- create counter to keep track of the adds and shifts
	-- does this look similar to the counter in lab 5?
	count_proc: process(clk)
		begin
		if(rising_edge(clk)) then
			if((start_count = '1') or (reset = '1')) then
				count <= 0;	-- what value do we reset too?
			elsif(state = right_shift) then
				count <= count + 1;
			end if;
		end if;
	end process count_proc;
	
	-- calculate the sum of the multiplication and the upper bits of the
	-- product register
	sum <= ('0' & product_reg(2*input_size - 1 downto input_size)) + ('0' & input_1_reg);
	
	----------------------------------------------
	-- define the multiplier process
	-- this process does the actual shifting
	---------------------------------------------
	mult_proc: process(clk)
		begin
		if(rising_edge(clk)) then
			if(reset = '1') then
				product_reg <= (others => '0');	-- how can we set all values to 0 in a single line?
				input_1_reg <= (others => '0');	-- how can we set all values to 0 in a single line?
			elsif(load_data = '1') then
				product_reg(input_size*2 - 1 downto input_size) <= (others => '0');
				product_reg(input_size -1 downto 0) <= input_2;	-- follow diagram on the task sheet
				input_1_reg <= input_1;
			elsif(add = '1') then
				product_reg <= sum(input_size downto 0) & product_reg(input_size - 1 downto 1);
			elsif(shift = '1') then	
				product_reg <= '0' & product_reg(input_size*2 - 1 downto 1);
			end if;
		end if;
	end process mult_proc;
end behavior;