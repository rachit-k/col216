library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY InstructionDecoder IS
PORT (Instruction: IN std_logic_vector(31 downto 0);
		I_Class: OUT instr_class_type;
		DP_Imm: OUT DP_type;
        I_Decoded: OUT i_decoded_type);
END ENTITY;

ARCHITECTURE ID OF InstructionDecoder is

signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit : std_logic; --Immediate bit
signal instr_class : instr_class_type;

BEGIN  

cond <= Instruction(31 downto 28);
F_field <= Instruction(27 downto 26);
I_bit <= Instruction(25);

WITH F_field SELECT
instr_class <= DP WHEN "00",
				DT WHEN "01",
				branch WHEN "10",
				unknown WHEN Others;

I_Decoded <= halt WHEN Instruction = "0000000000000000000000000000000000000000" ELSE
                andd WHEN instr_class = DP AND Instruction(24 downto 21) = "0000" ELSE
				eor WHEN instr_class = DP AND Instruction(24 downto 21) = "0001" ELSE
				sub WHEN instr_class = DP AND Instruction(24 downto 21) = "0010" ELSE
				rsb WHEN instr_class = DP AND Instruction(24 downto 21) = "0011" ELSE
				add WHEN instr_class = DP AND Instruction(24 downto 21) = "0100" ELSE
				adc WHEN instr_class = DP AND Instruction(24 downto 21) = "0101" ELSE
				sbc WHEN instr_class = DP AND Instruction(24 downto 21) = "0110" ELSE
				rsc WHEN instr_class = DP AND Instruction(24 downto 21) = "0111" ELSE
				tst WHEN instr_class = DP AND Instruction(24 downto 21) = "1000" ELSE
				teq WHEN instr_class = DP AND Instruction(24 downto 21) = "1001" ELSE
				cmp WHEN instr_class = DP AND Instruction(24 downto 21) = "1010" ELSE
				cmn WHEN instr_class = DP AND Instruction(24 downto 21) = "1011" ELSE
				orr WHEN instr_class = DP AND Instruction(24 downto 21) = "1100" ELSE
				mov WHEN instr_class = DP AND Instruction(24 downto 21) = "1101" ELSE
				bic WHEN instr_class = DP AND Instruction(24 downto 21) = "1110" ELSE
				mvn WHEN instr_class = DP AND Instruction(24 downto 21) = "1111" ELSE
				ldr WHEN instr_class = DT AND (Instruction(24 downto 20) = "11001" OR Instruction(24 downto 20) = "10001") ELSE
				str WHEN instr_class = DT AND (Instruction(24 downto 20) = "11000" OR Instruction(24 downto 20) = "10000") ELSE
				beq WHEN instr_class = branch AND cond = "0000" ELSE
				bne WHEN instr_class = branch AND cond = "0001"  ELSE
				br WHEN instr_class = branch AND cond = "1110" ELSE
				unknown;

I_Class <= halt WHEN Instruction = "0000000000000000000000000000000000000000" ELSE
            DP WHEN instr_class = DP ELSE 
            DT WHEN instr_class = DT ELSE 
            branch WHEN instr_class = branch ELSE
            unknown;

DP_Imm <= reg WHEN I_bit = '0' ELSE imm;

END ARCHITECTURE;