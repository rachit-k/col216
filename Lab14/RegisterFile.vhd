library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY RegisterFile IS
PORT (Clk: IN std_logic;
        Reset: IN std_logic;

        Read1Data: OUT std_logic_vector(31 downto 0);
        Read1Address: IN std_logic_vector(3 downto 0);
        Read2Data: OUT std_logic_vector(31 downto 0);
        Read2Address: IN std_logic_vector(3 downto 0);

        WriteData: IN std_logic_vector(31 downto 0);
        WriteAddress: IN std_logic_vector(3 downto 0);
        WriteEnable: IN std_logic;
       
       ReadPCData: OUT std_logic_vector(31 downto 0);
       WritePCData: IN std_logic_vector(31 downto 0);
       WritePCEnable: IN std_logic;
       RF_Out: OUT RF_type);
END ENTITY;

ARCHITECTURE RF OF RegisterFile IS

signal RF:RF_type := (others => "00000000000000000000000000000000");

BEGIN

RF_Out <= RF;

Read1Data <=  RF(to_integer(unsigned(Read1Address)));
Read2Data <=  RF(to_integer(unsigned(Read2Address)));
ReadPCData <=  RF(15);

PROCESS(Clk)
BEGIN 
    IF(Reset = '1') THEN
          RF <= (others => "00000000000000000000000000000000");
    ELSIF(Clk = '1' AND Clk'EVENT) THEN
        IF (WriteEnable = '1') THEN
           RF(to_integer(unsigned(WriteAddress))) <= WriteData;
        END IF;
        IF(WritePCEnable = '1') THEN
           RF(15) <= WritePCData;
        END IF;
    END IF;
END PROCESS;

END ARCHITECTURE RF;