library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY Shifter IS 
PORT (Clk: IN std_logic;
        Shifter_Input: IN std_logic_vector(31 downto 0) := (others => '0');
        DP_Imm: IN DP_type;
        ShiftSpec: IN std_logic_vector(7 downto 0);
        RotSpec: IN std_logic_vector(3 downto 0);
        Rs: IN std_logic_vector(31 downto 0); 
        shift_carry_set: OUT std_logic;
        Shifter_Output:OUT std_logic_vector(31 downto 0));
END ENTITY;

ARCHITECTURE shift OF Shifter IS 

SIGNAL Rotation_Int: integer;
SIGNAL Shift_Int: integer;

BEGIN 

Rotation_Int <= 2 * to_integer(unsigned(RotSpec));

WITH ShiftSpec(0) SELECT
Shift_Int <= to_integer(unsigned(ShiftSpec(7 downto 3))) WHEN '0',
                to_integer(unsigned(Rs(3 downto 0))) WHEN Others;

Shifter_Output <= std_logic_vector(unsigned(Shifter_Input) ror Rotation_Int) WHEN DP_Imm = imm ELSE
                    std_logic_vector(unsigned(Shifter_Input) sll Shift_Int) WHEN ShiftSpec(2 downto 1) = "00" ELSE
                    std_logic_vector(unsigned(Shifter_Input) srl Shift_Int) WHEN ShiftSpec(2 downto 1) = "01" ELSE
                    to_stdlogicvector(to_bitvector(Shifter_Input) sra Shift_Int) WHEN ShiftSpec(2 downto 1) = "10" ELSE
                    std_logic_vector(unsigned(Shifter_Input) ror Shift_Int);
                    
shift_carry_set <= '0' WHEN Rotation_Int = 0 OR Shift_Int = 0 ELSE
                   Shifter_Input((Rotation_Int -1) mod 32) WHEN DP_Imm = imm AND Rotation_Int = 0 ELSE
                  Shifter_Input((32 - Shift_Int) mod 32) WHEN ShiftSpec(2 downto 1) = "00" ELSE
                  Shifter_Input((Shift_Int -1)mod 32);          
END ARCHITECTURE shift;