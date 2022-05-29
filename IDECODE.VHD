-- ECE 3055 Computer Architecture and Operating Systems
--
-- MIPS Processor VHDL Behavioral Model
--			
--  Idecode module (implements the register file)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
-- 
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALUResultWb : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );

			Function_Opcode_In  : IN	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			Function_Opcode_Out  : OUT	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC;
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			WriteAddress		: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
			Instruction2016	: OUT   STD_LOGIC_VECTOR(4 downto 0);
			Instruction1511	: OUT   STD_LOGIC_VECTOR(4 downto 0);
			clock,reset	: IN 	STD_LOGIC );
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL D_read_data_1				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL D_read_data_2				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL D_Sign_extend				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL register_array				: register_file;
	SIGNAL write_data					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL D_Instruction1511,D_Instruction2016 : STD_LOGIC_VECTOR(4 downto 0);
BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	D_Instruction1511	<= Instruction( 15 DOWNTO 11 );
   	D_Instruction2016 	<= Instruction( 20 DOWNTO 16 );
	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );

					-- Read Register 1 Operation
	D_read_data_1 <= register_array( 
			      CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	D_read_data_2 <= register_array( 
			      CONV_INTEGER( read_register_2_address ) );
					-- Mux for Register Write Address

	write_data <= ALUResultWb( 31 DOWNTO 0 ) 
			WHEN ( MemtoReg = '0' ) 	ELSE read_data;
					-- Sign Extend 16-bits to 32-bits
    	D_Sign_extend <= X"0000" & Instruction_immediate_value
		WHEN Instruction_immediate_value(15) = '0'
		ELSE	X"FFFF" & Instruction_immediate_value;

	PROCESS
		BEGIN
			WAIT UNTIL clock'EVENT AND clock = '1';
			IF reset = '1' THEN
						-- Initial register values on reset are register = reg#
						-- use loop to automatically generate reset logic 
						-- for all registers
				FOR i IN 0 TO 31 LOOP
					register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
				END LOOP;
						-- Write back to register - don't write to register 0
			ELSIF RegWrite = '1' AND WriteAddress /= 0 THEN
				register_array( CONV_INTEGER( WriteAddress)) <= write_data;
			END IF;
	END PROCESS;

	PROCESS
		BEGIN
			WAIT UNTIL clock'EVENT AND clock = '1';
			IF reset = '1' THEN

				read_data_1 <= X"00000000";
				read_data_2 <= X"00000000";
				Sign_extend <= X"00000000";
				Instruction1511 <= "00000";
				Instruction2016 <= "00000";
				Function_Opcode_Out <= "000000";
			ELSE 
				Function_Opcode_Out <= Function_Opcode_In;
				read_data_1 <= D_read_data_1;
				read_data_2 <= D_read_data_2;
				Sign_extend <= D_Sign_extend;
				Instruction1511 <= D_Instruction1511;
				Instruction2016 <= D_Instruction2016;
			END IF;
	END PROCESS;

END behavior;


