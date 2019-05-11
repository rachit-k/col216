library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY ALU IS 
PORT (Clk: IN std_logic;
        ForcedCarry: IN std_logic := '0';
        Input1: IN std_logic_vector(31 downto 0) := (others => '0');
        Input2: IN std_logic_vector(31 downto 0) := (others => '0');
        ResultOutput:OUT std_logic_vector(31 downto 0) := (others => '0');
        Control:IN std_logic_vector(3 downto 0) := (others => '0');
        Flags:OUT std_logic_vector(3 downto 0) := (others => '0');
        FlagWriteEnable: IN std_logic;
        I_Decoded: IN i_decoded_type;
        shift_carry_set: IN std_logic;
        Set_Bit: IN std_logic);
END ENTITY;

ARCHITECTURE alu OF ALU IS 

signal temp_output: std_logic_vector(32 downto 0) := (others => '0');
signal ZFlag_temp, NFlag_temp, VFlag_temp, CFlag_temp: std_logic  := '0';
signal Actual_Set_Bit: std_logic;
signal Carry: std_logic_vector(32 downto 0);
signal Input1_temp, Input2_temp: std_logic_vector(32 downto 0) := (others => '0');
signal Flag_temp: std_logic_vector(3 downto 0):= (others => '0');
signal V_Set: std_logic;

BEGIN

ResultOutput <= temp_output(31 downto 0);
Actual_Set_Bit <= '1' WHEN Set_Bit = '1' OR I_Decoded = cmp OR I_Decoded = cmn OR I_Decoded = tst OR I_Decoded = teq ELSE '0';
Input1_temp <= '0' & Input1;
Input2_temp <= '0' & Input2;
Flags <= Flag_temp;

V_Set <= '1' WHEN I_Decoded = cmp OR I_Decoded = cmn OR I_Decoded = sub OR I_Decoded = rsb 
            OR I_Decoded = add OR I_Decoded = adc OR I_Decoded = sbc OR I_Decoded = rsc ELSE '0';

WITH Control SELECT
temp_output <= Input1_temp AND Input2_temp WHEN "0000",
                Input1_temp XOR Input2_temp WHEN "0001",
                Input1_temp + NOT(Input2_temp) + 1 WHEN "0010",
                NOT(Input1_temp) + Input2_temp + 1 WHEN "0011",
                Input1_temp + Input2_temp WHEN "0100",
                Input1_temp + Input2_temp +Carry  WHEN "0101",
                Input1_temp + NOT(Input2_temp) + Carry WHEN "0110",
                NOT(Input1_temp) - Input2_temp + Carry WHEN "0111",
                Input1_temp AND Input2_temp WHEN "1000",
                Input1_temp XOR Input2_temp WHEN "1001",
                Input1_temp + NOT(Input2_temp) + 1 WHEN "1010",
                Input1_temp + Input2_temp WHEN "1011",
                Input1_temp OR Input2_temp WHEN "1100",
                Input2_temp WHEN "1101",
                Input1_temp AND NOT(Input2_temp) WHEN "1110",
                NOT(Input2_temp) + Carry WHEN Others;

WITH temp_output(31 downto 0) SELECT
ZFlag_temp <= '1' WHEN "00000000000000000000000000000000",
           '0' WHEN Others;
VFlag_temp <= CFlag_temp xor NFlag_temp;


CFlag_temp <= temp_output(32) WHEN V_Set = '1' ELSE shift_carry_set;

NFlag_temp <= temp_output(31);


WITH ForcedCarry SELECT
Carry <= "000000000000000000000000000000001" WHEN '1',
            "00000000000000000000000000000000" & Flag_temp(1) WHEN Others;

PROCESS(Clk)
BEGIN
    IF(Clk = '1' AND Clk'EVENT) THEN
        IF(FlagWriteEnable = '1' AND V_Set = '1' AND Set_Bit = '1') THEN
            Flag_temp(0) <= VFlag_temp;
        END IF;
        IF(FlagWriteEnable = '1' AND Set_Bit = '1') THEN
            Flag_temp(1) <= CFlag_temp;
        END IF;
        IF(FlagWriteEnable = '1' AND Set_Bit = '1') THEN
            Flag_temp(2) <= ZFlag_temp;
        END IF;
        IF(FlagWriteEnable = '1' AND Set_Bit = '1') THEN
            Flag_temp(3) <= NFlag_temp;
        END IF;
    END IF;
END PROCESS;

END ARCHITECTURE alu;