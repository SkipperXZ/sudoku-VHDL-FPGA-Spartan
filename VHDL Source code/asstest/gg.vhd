----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:31:10 05/19/2018 
-- Design Name: 
-- Module Name:    gg - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gg is
	generic (	sec_cycle : integer := 20000000;
					digit_cycle : integer := 200000;
					pb_cycle : integer := 4000000
	);
	port(		Button_Start : in STD_LOGIC;
				Up		: in STD_LOGIC;
				Left  : in STD_LOGIC;
				Right : in STD_LOGIC;
				Down	: in STD_LOGIC;
				ADDv  : in STD_LOGIC;
				Reset : in STD_LOGIC;
				Submit: in STD_LOGIC;
				LED_RED : out STD_LOGIC;
				LED_GREEN : out STD_LOGIC;
				SEG_TIME		: out STD_LOGIC_VECTOR (6 downto 0);
				TIME_COM	: out STD_LOGIC_VECTOR (3 downto 0);
				SEG		: out STD_LOGIC_VECTOR (6 downto 0);
				SEG_FPGA		: out STD_LOGIC_VECTOR (6 downto 0);
				COM_FPGA		: out STD_LOGIC;
				--SEG_COM	: out STD_LOGIC_VECTOR (3 downto 0);
				common : out std_logic_vector (15 downto 0);
				CLK	: in STD_LOGIC
	);
end gg;

architecture Behavioral of gg is
	type dataout is array (3 downto 0,3 downto 0) of integer range 0 to 9;
	signal problem : dataout :=((7,7,7,7),(7,7,7,7),(7,7,7,7),(7,7,7,7));
	signal chprob : dataout :=((7,7,7,7),(7,7,7,7),(7,7,7,7),(7,7,7,7));
	signal chRight,chADDv,chDown,chLeft,chUp,chDe,ch,chend,goend,chRE : std_logic:='0';
	
	--signal i,j,k		: integer range 0 to 3:=0;
	signal Start_game : std_logic :='0';
	signal Set_Default : std_logic :='0';
	signal sumch		: integer range 0 to 16;
	signal sec_count	: integer range 0 to sec_cycle := 0;
	signal sel			: integer range 0 to 9 := 0;
	signal com			: integer range 0 to 15 :=0;
	
	signal S0         : integer range 0 to 10 :=0;
	signal S1         : integer range 0 to 10 :=0;
	signal M0         : integer range 0 to 10 :=0;
	signal M1         : integer range 0 to 10 :=0;
	signal timer_sec   : integer range 0 to 20000000 :=0;
	signal t          : integer range 0 to 9 :=0;
	signal t_com      : integer range 0 to 3 :=0;
begin
	
	 process(CLK) is
		begin
		if CLK'event and CLK = '1' then
			timer_sec <= timer_sec +1 ;
			
			if Start_game='1' and Reset='1' then
				S0<=0;
				S1<=0;
				M0<=0;
				M1<=0;
			end if;
			if Set_Default = '1' and Start_game='0' then
				S0<=0;
				S1<=0;
				M0<=0;
				M1<=0;
			end if;
			
			if timer_sec =1 and goend = '0' and Start_game='1' then
				
				S0 <= S0+1;
			end if;
			
			if S0 = 10 then
				S0 <= 0;
				S1 <= S1+1;
			end if;
			if S1 = 6 then
				S1 <= 0;
				M0 <= M0+1;
			end if;
			if M0  = 10 then
				M0 <= 0;
			   M1 <= M1+1;
			end if;
			if timer_sec mod 100000 = 0 then
				t_com <= t_com +1;
			end if;
			if t_com = 0 then
				TIME_COM <= "1110";
				t <= M1;
			elsif t_com = 1 then
				TIME_COM <= "1101";
				t <= M0;
			elsif t_com = 2 then
				TIME_COM <= "1011";
				t <= S1;
			elsif t_com = 3 then
				TIME_COM <= "0111";
				t <= S0;
			end if;
		end if;
	end process;

	process(CLK,Left,Right,Reset,Button_Start,Up,Down) is
	variable i,j,k,row,column : integer range 0 to 3 :=3;
	variable val,pp: integer range 0 to 15 := 0;
	variable blink : integer range 0 to 1 :=1;
	
	
	  begin
	  if CLK'event and CLK = '1' then
			sec_count<=sec_count+1;
			
			if Button_Start='1' and Start_game='0' then
				Set_Default <= '1';
			end if;
			if Set_Default = '1' and Start_game='0' and sec_count mod 8000000 = 0 then
			   
				if k = 3 then
					problem<=((3,3,3,3),(3,3,3,3),(3,3,3,3),(3,3,3,3));
					k:=2;
				elsif k = 2 then
					problem<=((2,2,2,2),(2,2,2,2),(2,2,2,2),(2,2,2,2));
					k:=1;
				elsif k = 1 then
					problem<=((1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1));
					k:=0;
				elsif k = 0 then
					--if----------==1
					pp:=sec_count mod 10;
					if pp = 0 then
						problem<=((0,2,0,0),(0,0,0,0),(0,0,0,1),(1,0,3,0));
						chprob<=((0,1,0,0),(0,0,0,0),(0,0,0,1),(1,0,1,0));
					elsif pp = 1 then
						problem <= ((0,0,0,0),(4,0,1,0),(0,0,2,0),(3,0,0,4));
						chprob  <=  ((0,0,0,0),(1,0,1,0),(0,0,1,0),(1,0,0,1));
					elsif pp = 2 then
						problem <= ((0,1,0,0),(0,0,0,4),(0,0,3,0),(3,0,0,0));
						chprob  <=  ((0,1,0,0),(0,0,0,1),(0,0,1,0),(1,0,0,0));
					elsif pp = 3 then
						problem <= ((0,0,2,0),(4,0,0,0),(0,0,0,3),(0,0,4,0));
						chprob  <=  ((0,0,1,0),(1,0,0,0),(0,1,0,1),(0,0,1,0));
					elsif pp = 4 then
						problem <= ((0,0,0,4),(3,0,0,0),(0,2,0,0),(0,0,2,0));
						chprob  <=  ((0,0,0,1),(1,0,0,0),(0,1,0,0),(0,0,1,0));
					elsif pp = 5 then
						problem <= ((0,2,0,0),(0,0,4,0),(1,0,0,0),(0,0,0,1));
						chprob  <=  ((0,1,0,0),(0,0,1,0),(1,0,0,0),(0,0,0,1));
					elsif pp = 6 then
						problem <= ((0,0,2,0),(0,1,0,0),(0,0,0,4),(4,0,0,0));
						chprob  <=  ((0,0,1,0),(0,1,0,0),(0,0,0,1),(1,0,0,0));
					elsif pp = 7 then
						problem <= ((0,1,2,0),(4,0,0,0),(0,0,0,3),(0,0,4,0));
						chprob  <=  ((0,1,1,0),(1,0,0,0),(0,0,0,1),(0,0,1,0));
					elsif pp = 8 then
						problem <= ((0,0,0,2),(0,0,0,3),(4,0,0,0),(3,0,0,0));
						chprob  <=  ((0,0,0,1),(0,0,0,1),(1,0,0,0),(1,0,0,0));
					elsif pp = 9 then
						problem <= ((0,0,0,4),(3,0,0,0),(0,2,0,0),(0,0,2,0));
						chprob  <=  ((0,0,0,1),(1,0,0,0),(0,1,0,0),(0,0,1,0));
					end if;
					pp:=10;
					LED_GREEN <= '0';
					LED_RED  <= '0';
					k:=3;
					chRE<='0';
					chRight <='0';
					chADDv <='0';
					chDown <='0';
					chLeft <='0';
					chUp <='0';
					chDe <='0';
					ch <='0';
					chDe<='1'; 
					Set_Default <= '0';
					Start_game <= '1';
					chend<='0';
					row := 0;
					column := 0;
					sumch <= 0;
					COM_FPGA<='1';
					goend<='0';
					val:=0;
					val:=problem(row,column);
				end if;
			end if;
			if Start_game = '1' and sec_count mod 10000000 =0 then
				chDe<='0';
			end if;
			-----------------------------------Start Game-------------------------
			--rows,columns,val
			if Start_game = '1' and chDe = '0' and goend = '0' then
				------------------Left--------
				if val > 4 then
					val:=0;
				end if;
				if Left = '0' and chLeft = '1' and sec_count mod 2000000 = 0 then
					chLeft<='0';
				--end if;
				elsif Left = '1' and chLeft = '0' then
					chLeft<='1';
					column:=column-1;
					if chprob(row,column)=1 then
						column:=column-1;
					end if;
					val:=problem(row,column);
				--end if;
				-------------------Up------------
				elsif Up = '0' and chUp ='1' and sec_count mod 2000000 = 0 then
					chUp<='0';
				--end if;
				elsif Up = '1' and chUp = '0' then
					chUp<='1';
					row:=row-1;
					if chprob(row,column)=1 then
						row:=row-1;
					end if;
					val:=problem(row,column);
				--end if;
				
				------------------Right--------
				elsif Right = '0' and chRight = '1' and sec_count mod 2000000 = 0 then
					chRight<='0';
				--end if;
				elsif Right = '1' and chRight = '0' then
					--val:=problem(row,column);
					chRight<='1';
					column:=column+1;
					if chprob(row,column)=1 then
						column:=column+1;
					end if;
					val:=problem(row,column);
				--end if;
				--------------------Down---------
				elsif Down = '0' and chDown='1' and sec_count mod 2000000 = 0  then
					chDown<='0';
				--end if;
				elsif Down = '1' and chDown='0' then
					chDown<='1';
					--val:=problem(row,column);
					row:=row+1;
					if chprob(row,column)=1 then
						row:=row+1;
					end if;
					val:=problem(row,column);
				--end if;
				---------+Valu-------------
				elsif ADDv = '0' and chADDv='1' and sec_count mod 2000000 = 0 then
					chADDv<='0';
				--end if;
				elsif ADDv = '1' and chADDv='0' then
					chADDv<='1';
					val:=val+1;
				end if;
				----------Submit---------------
				if Submit = '1' then
					problem(row,column)<=val;
				end if;
				----------Reset-------------
				if Reset='0' and chRE='1' and sec_count mod 2000000 = 0 then
					chRE<='0';
				end if;
				if Reset='1' and chRE = '0' then
						chRE<='1';
						row := 0;
						column := 0;
						val:=0;
						pp:=sec_count mod 10;
					if pp = 0 then
						problem<=((0,2,0,0),(0,0,0,0),(0,0,0,1),(1,0,3,0));
						chprob<=((0,1,0,0),(0,0,0,0),(0,0,0,1),(1,0,1,0));
					elsif pp = 1 then
						problem <= ((4,0,0,3),(0,1,0,0),(0,2,0,4),(0,0,0,0));
						chprob  <=  ((1,0,0,1),(0,1,0,0),(0,1,0,1),(0,0,0,0));
					elsif pp = 2 then
						problem <= ((0,0,0,3),(0,3,0,0),(4,0,0,0),(0,0,1,0));
						chprob  <=  ((0,0,0,1),(0,1,0,0),(1,0,0,0),(0,0,1,0));
					elsif pp = 3 then
						problem <= ((0,4,0,0),(3,0,0,1),(0,0,0,4),(0,2,0,0));
						chprob  <=  ((0,1,0,0),(1,0,0,1),(0,0,0,1),(0,1,0,0));
					elsif pp = 4 then
						problem <= ((0,2,0,0),(0,0,2,0),(0,0,0,3),(4,0,0,0));
						chprob  <=  ((0,1,0,0),(0,0,1,0),(0,0,0,1),(1,0,0,0));
					elsif pp = 5 then
						problem <= ((1,0,0,0),(0,0,0,1),(0,4,0,0),(0,0,2,0));
						chprob  <=  ((1,0,0,0),(0,0,0,1),(0,1,0,0),(0,0,1,0));
					elsif pp = 6 then
						problem <= ((0,0,0,4),(4,0,0,0),(0,0,1,0),(0,2,0,0));
						chprob  <=  ((0,0,0,1),(1,0,0,0),(0,0,1,0),(0,1,0,0));
					elsif pp = 7 then
						problem <= ((0,4,0,0),(3,0,0,0),(0,0,0,4),(0,2,1,0));
						chprob  <=  ((0,1,0,0),(1,0,0,0),(0,0,0,1),(0,1,1,0));
					elsif pp = 8 then
						problem <= ((0,0,0,3),(0,0,0,4),(3,0,0,0),(2,0,0,0));
						chprob  <=  ((0,0,0,1),(0,0,0,1),(1,0,0,0),(1,0,0,0));
					elsif pp = 9 then
						problem <= ((0,2,0,0),(0,0,2,0),(0,0,0,3),(4,0,0,0));
						chprob  <=  ((0,1,0,0),(0,0,1,0),(0,0,0,1),(1,0,0,0));
					end if;
					pp:=10;
					------------------------------------------------------------
				end if;
				
				----------Check SudoKuy-------------------------
				if Button_Start='1' then
					problem(row,column)<=val;
					chend<='0';
					-----------------------row----------------
					sumch <= 0;
					sumch<=problem(0,0)+problem(0,1)+problem(0,2)+problem(0,3);
					if sumch = 10 then
						sumch <= 0;
						sumch<=problem(1,0)+problem(1,1)+problem(1,2)+problem(1,3);
						if sumch = 10 then
							sumch <= 0;
							sumch<=problem(2,0)+problem(2,1)+problem(2,2)+problem(2,3);
							if sumch = 10 then
								sumch <= 0;
								sumch<=problem(3,0)+problem(3,1)+problem(3,2)+problem(3,3);
								if sumch = 10 then
									sumch <= 0;
									sumch<=problem(0,0)+problem(1,0)+problem(2,0)+problem(3,0);
									if sumch = 10 then
										sumch <= 0;
										sumch<=problem(0,1)+problem(1,1)+problem(2,1)+problem(3,1);
										if sumch = 10 then
											sumch <= 0;
											sumch<=problem(0,2)+problem(1,2)+problem(2,2)+problem(3,2);
											if sumch = 10 then
												sumch <= 0;
												sumch<=problem(0,3)+problem(1,3)+problem(2,3)+problem(3,3);
												if sumch = 10 then
													chend<='1';
												end if;
											end if;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;
					
	
					if problem(3,1)=problem(3,0) then
						chend<='0';
					end if;
					if problem(3,1)=0 or problem(3,0)=0 then
						chend<='0';
					end if;
					if chend = '1' then
						goend<='1';
						LED_GREEN <='1';
						LED_RED <= '0';
					else
						LED_RED <= '1';
					end if;
				end if;
				---------Blink-----------------
				if sec_count mod 12500000 =0 then
					blink:=blink+1;
				end if;
				
			end if;
			-----------------------------------END GAME-----------------------------
			if goend = '1' then
				if Reset='1' then
					Start_game <= '0';
					row := 0;
					column := 0;
					val:=0;
					problem<=((0,0,0,0),(0,0,0,0),(0,0,0,0),(0,0,0,0));
				end if;
			end if;
			-----------------------------------test-------------------------------
			if sec_count mod 10000 = 0 then
				com <= com+1;
				COM_FPGA<='1';
			end if;
			----------------------------com and Bright-----------------------------
			if com = 0 then
				common<="1111111111111110";
				if row = 0 and column = 0 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 0 and column = 0 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(0,0);
					--sel<=chprob(rowlv,0);
				end if;
			elsif com = 1 then
				common<="1111111111111101";
				--sel<=problem(rowlv,1);
				if row = 0 and column = 1 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 0 and column = 1 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(0,1);
					--sel<=chprob(rowlv,1);
				end if;
			elsif com = 2 then
				common<="1111111111111011";
				if row = 0 and column = 2 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 0 and column = 2 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(0,2);
					--sel<=chprob(rowlv,2);
				end if;
			elsif com = 3 then
				common<="1111111111110111";
				--sel<=problem(rowlv,3);
				if row = 0 and column = 3 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 0 and column = 3 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(0,3);
					--sel<=chprob(rowlv,3);
				end if;
				-------------------------------row1-----------------------------
			elsif com = 4 then
				common<="1111111111101111";
				--sel<=problem(rowlv,3);
				if row = 1 and column = 0 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 1 and column = 0 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(1,0);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 5 then
				common<="1111111111011111";
				--sel<=problem(rowlv,3);
				if row = 1 and column = 1 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 1 and column = 1 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(1,1);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 6 then
				common<="1111111110111111";
				--sel<=problem(rowlv,3);
				if row = 1 and column = 2 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 1 and column = 2 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(1,2);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 7 then
				common<="1111111101111111";
				COM_FPGA<='0';
				--sel<=problem(rowlv,3);
				if row = 1 and column = 3 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 1 and column = 3 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(1,3);
					--sel<=chprob(rowlv,3);
				end if;
				------------------------------row2------------------
			elsif com = 8 then
				common<="1111111011111111";
				--sel<=problem(rowlv,3);
				if row = 2 and column = 0 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 2 and column = 0 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(2,0);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 9 then
				common<="1111110111111111";
				--sel<=problem(rowlv,3);
				if row = 2 and column = 1 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 2 and column = 1 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(2,1);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 10 then
				common<="1111101111111111";
				--sel<=problem(rowlv,3);
				if row = 2 and column = 2 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 2 and column = 2 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(2,2);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 11 then
				common<="1111011111111111";
				--sel<=problem(rowlv,3);
				if row = 2 and column = 3 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 2 and column = 3 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(2,3);
					--sel<=chprob(rowlv,3);
				end if;
				---------------------row3------------------
			elsif com = 12 then
				common<="1110111111111111";
				--sel<=problem(rowlv,3);
				if row = 3 and column = 0 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 3 and column = 0 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(3,0);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 13 then
				common<="1101111111111111";
				--sel<=problem(rowlv,3);
				if row = 3 and column = 1 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 3 and column = 1 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(3,1);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 14 then
				common<="1011111111111111";
				--sel<=problem(rowlv,3);
				if row = 3 and column = 2 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 3 and column = 2 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(3,2);
					--sel<=chprob(rowlv,3);
				end if;
			elsif com = 15 then
				common<="0111111111111111";
				--sel<=problem(rowlv,3);
				if row = 3 and column = 3 and blink = 0 and chprob(row,column)=0 then
					sel<=0;
				elsif row = 3 and column = 3 and blink = 1 and chprob(row,column)=0 then
					if val = 0 then
						sel<=5;
					else
						sel<=val;
					end if;
				else
					sel<=problem(3,3);
					--sel<=chprob(rowlv,3);
				end if;
			end if;
			----------------------------ENDcom and Bright-----------------------------
			----------------------------------test--------------------------
	  end if;--CLK
	  end process ;
		
		SEG <="1110001" when sel=15 else--F
			"1111001" when sel=14 else--E
			"1011110" when sel=13 else--D
			"0111001" when sel=12 else--C
			"1111100" when sel=11 else--B
			"1110111" when sel=10 else--A	
			"1101111" when sel=9 else -- 9
			"1111111" when sel=8 else -- 8
			"0000111" when sel=7 else -- 7
			"1111101" when sel=6 else -- 6
			"1000000" when sel=5 else -- 5
			"1100110" when sel=4 else -- 4
			"1001111" when sel=3 else -- 3
			"1011011" when sel=2 else -- 2
			"0000110" when sel=1 else -- 1
			"0000000";
		SEG_FPGA<="1110001" when sel=15 else--F
			"1111001" when sel=14 else--E
			"1011110" when sel=13 else--D
			"0111001" when sel=12 else--C
			"1111100" when sel=11 else--B
			"1110111" when sel=10 else--A	
			"1101111" when sel=9 else -- 9
			"1111111" when sel=8 else -- 8
			"0000111" when sel=7 else -- 7
			"1111101" when sel=6 else -- 6
			"1000000" when sel=5 else -- 5
			"1100110" when sel=4 else -- 4
			"1001111" when sel=3 else -- 3
			"1011011" when sel=2 else -- 2
			"0000110" when sel=1 else -- 1
			"0000000";
		
		SEG_TIME<="1101111" when t=9 else -- 9
			"1111111" when t=8 else -- 8
			"0000111" when t=7 else -- 7
			"1111101" when t=6 else -- 6
			"1101101" when t=5 else -- 5
			"1100110" when t=4 else -- 4
			"1001111" when t=3 else -- 3
			"1011011" when t=2 else -- 2
			"0000110" when t=1 else -- 1
			"0111111";

end Behavioral;

