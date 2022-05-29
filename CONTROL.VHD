-- ECE 3055 Computer Architecture and Operating Systems
--
-- MIPS Processor VHDL Behavioral Model
--		
-- control module (implements MIPS control unit)
--
-- School of Electrical & Computer Engineering
-- Georgia Institute of Technology
-- Atlanta, GA 30332
-- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	SIGNAL Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	SIGNAL RegDst 		: OUT 	STD_LOGIC;
	SIGNAL ALUSrc 		: OUT 	STD_LOGIC;
	SIGNAL MemtoReg 	: OUT 	STD_LOGIC;
	SIGNAL RegWrite 	: OUT 	STD_LOGIC;
	SIGNAL MemRead 		: OUT 	STD_LOGIC;
	SIGNAL MemWrite 	: OUT 	STD_LOGIC;
	SIGNAL Branch 		: OUT 	STD_LOGIC;
	SIGNAL ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq 	: STD_LOGIC;
	SIGNAL D_RegDst : STD_LOGIC;
	SIGNAL D_ALUSrc : STD_LOGIC;
	SIGNAL DDD_MemtoReg, DD_MemtoReg, D_MemtoReg : STD_LOGIC;
	SIGNAL DDD_RegWrite, DD_RegWrite, D_RegWrite : STD_LOGIC;
	SIGNAL DD_MemRead, D_MemRead : STD_LOGIC;
	SIGNAL DD_MemWrite, D_MemWrite : STD_LOGIC;
	SIGNAL DD_Branch, D_Branch : STD_LOGIC;

	SIGNAL D_ALUOp : STD_LOGIC_VECTOR( 1 DOWNTO 0 );

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
  	D_RegDst    <=  R_format;
 	D_ALUSrc  	<=  Lw OR Sw;
	DDD_MemtoReg 	<=  Lw;
  	DDD_RegWrite 	<=  R_format OR Lw;
  	DD_MemRead 	    <=  Lw;
   	DD_MemWrite 	<=  Sw; 
 	DD_Branch       <=  Beq;
	D_ALUOp( 1 ) 	<=  R_format;
	D_ALUOp( 0 ) 	<=  Beq; 


	-- new process for module's pipeline registers
	PROCESS 
		BEGIN
			WAIT UNTIL clock'EVENT and clock='1';
			-- reset control signals to zero when reset = 1
			IF reset = '1' THEN
				
				RegDst <= '0';
				
				ALUSrc <= '0';

				DD_MemtoReg <= '0';
				D_MemtoReg <= '0';
				MemtoReg <= '0';

				DD_RegWrite <= '0';
				D_RegWrite <= '0';
				RegWrite <= '0';

				D_MemRead <= '0';
				MemRead <= '0';

				D_MemWrite <= '0';
				MemWrite <= '0';

				D_Branch <= '0';
				Branch <= '0';


				ALUOp <= "00";

			ELSE

				RegDst <= D_RegDst;

				ALUSrc <= D_ALUSrc;

				DD_MemtoReg <= DDD_MemtoReg;
				D_MemtoReg <= DD_MemtoReg;
				MemtoReg <= D_MemtoReg;

				DD_RegWrite <= DDD_RegWrite;
				D_RegWrite <= DD_RegWrite;
				RegWrite <= D_RegWrite;

				D_MemRead <= DD_MemRead;
				MemRead <= D_MemRead;

				D_MemWrite <= DD_MemWrite;
				MemWrite <= D_MemWrite;
				
				D_Branch <= DD_Branch;
				Branch <= D_Branch;

				ALUOp <= D_ALUOp;


			END IF;
	END PROCESS;

END behavior;


