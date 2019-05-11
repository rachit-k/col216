library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY Multiplier IS 
PORT (Input1: IN std_logic_vector(31 downto 0) := (others => '0');
        Input2: IN std_logic_vector(31 downto 0) := (others => '0');
        ResultOutput:OUT std_logic_vector(63 downto 0) := (others => '0');
        I_Decoded: IN i_decoded_type);
END ENTITY;

ARCHITECTURE M of Multiplier IS

SIGNAL x1, x2: std_logic;
SIGNAL operand1, operand2: std_logic_vector(32 downto 0);
SIGNAL result_66: std_logic_vector(65 downto 0);

BEGIN

x1 <= Input1(31) WHEN I_Decoded = smull OR I_Decoded = smlal ELSE '0';
x2 <= Input2(31) WHEN I_Decoded = smull OR I_Decoded = smlal ELSE '0';

operand1 <= x1 & Input1;
operand2 <= x2 & Input2;

a_s <= signed(operand1);
b_s <= signed(operand2);
p_s <= a_s * b_s;
result_66 <= std_logic_vector(p_s);

ResultOutput <= result_66(63 downto 0);

END ARCHITECTURE;