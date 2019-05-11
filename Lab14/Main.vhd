library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY Processor IS
PORT(Clk: IN std_logic;
        Reset: IN std_logic := '0';
        Step: IN std_logic := '0';
        Instr: IN std_logic := '0';
        Go: IN std_logic := '0';
        RF_Select: IN std_logic_Vector(3 downto 0);
        Display_Select: IN std_logic_vector(3 downto 0);
        LED_Output: OUT std_logic_vector(15 downto 0));
END ENTITY;

ARCHITECTURE P OF Processor IS

COMPONENT InstructionDecoder IS
PORT (Instruction: IN std_logic_vector(31 downto 0);
        I_Class: OUT instr_class_type;
        DP_Imm: OUT DP_type;
        I_Decoded: OUT i_decoded_type);
END COMPONENT;

COMPONENT Control_State_FSM IS
PORT (Clk: IN std_logic;
        Reset: IN std_logic;
        Step: IN std_logic;
        Instr: IN std_logic;
        Go: IN std_logic;
        I_Class: IN instr_class_type;
        I_Decoded: IN i_decoded_type;
        Execution_State: IN state_type;
        Control_State: OUT control_state_type);
END COMPONENT;

COMPONENT Execution_State_FSM IS
PORT (Clk: IN std_logic;
        Reset: IN std_logic;
        Step: IN std_logic;
        Instr: IN std_logic;
        Go: IN std_logic;
        I_Class: IN instr_class_type;
        Control_State: IN control_state_type;
        Execution_State: OUT state_type);
END COMPONENT;

COMPONENT RegisterFile IS
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
END COMPONENT;

COMPONENT ALU IS 
PORT (Clk: IN std_logic;
        ForcedCarry: IN std_logic := '0';
        Input1: IN std_logic_vector(31 downto 0);
        Input2: IN std_logic_vector(31 downto 0);
        ResultOutput:OUT std_logic_vector(31 downto 0);
        Control:IN std_logic_vector(3 downto 0);
        Flags:OUT std_logic_vector(3 downto 0);
        FlagWriteEnable: IN std_logic;
        shift_carry_set: IN std_logic;
        I_Decoded: IN i_decoded_type;
        Set_Bit: IN std_logic);
END COMPONENT;

COMPONENT debouncer IS
PORT (Clk: IN std_logic;
    push1, push2, push3, push4: IN std_logic;
    debounced_push1, debounced_push2, debounced_push3, debounced_push4: OUT std_logic);
END COMPONENT;

COMPONENT dist_mem_gen_0 IS --Data Memory (RAM)
PORT(a: IN std_logic_vector (7 downto 0);
        d: IN std_logic_vector (31 downto 0);
        clk: IN std_logic;
        we: IN std_logic;
        spo: OUT std_logic_vector (31 downto 0));
END COMPONENT;

COMPONENT Shifter IS 
PORT (Clk: IN std_logic;
        Shifter_Input: IN std_logic_vector(31 downto 0) := (others => '0');
        DP_Imm: IN DP_type;
        ShiftSpec: IN std_logic_vector(7 downto 0);
        RotSpec: IN std_logic_vector(3 downto 0);
        Rs: IN std_logic_vector(31 downto 0);
        shift_carry_set: OUT std_logic; 
        Shifter_Output:OUT std_logic_vector(31 downto 0));
END COMPONENT;

SIGNAL debounced_go: std_logic;
SIGNAL debounced_step: std_logic;
SIGNAL debounced_reset: std_logic;
SIGNAL debounced_instr: std_logic;
SIGNAL Control_State: control_state_type;
SIGNAL Execution_State: state_type;

SIGNAL ALU_Input1 : std_logic_vector(31 downto 0);
SIGNAL ALU_Input2 : std_logic_vector(31 downto 0);
SIGNAL ALU_ResultOutput : std_logic_vector(31 downto 0);
SIGNAL ALU_ForcedCarry :std_logic := '0';
SIGNAL ALU_Control : std_logic_vector(3 downto 0);
SIGNAL ALU_Flags : std_logic_vector(3 downto 0);
SIGNAL ALU_FlagWriteEnable: std_logic;

SIGNAL Shifter_Input: std_logic_vector(31 downto 0);
SIGNAL Shifter_Output: std_logic_vector(31 downto 0);
SIGNAL shift_carry_set: std_logic := '0';

SIGNAL RF_Read1Data: std_logic_vector(31 downto 0);
SIGNAL RF_Read1Address : std_logic_vector(3 downto 0);
SIGNAL RF_Read2Data : std_logic_vector(31 downto 0);
SIGNAL RF_Read2Address : std_logic_vector(3 downto 0);
SIGNAL RF_WriteData : std_logic_vector(31 downto 0);
SIGNAL RF_WriteAddress : std_logic_vector(3 downto 0);
SIGNAL RF_WriteEnable: std_logic;
SIGNAL RF_ReadPCData: std_logic_vector(31 downto 0);
SIGNAL RF_WritePCData : std_logic_vector(31 downto 0);
SIGNAL RF_WritePCEnable: std_logic;

SIGNAL Instruction: std_logic_vector(31 downto 0) := (others => '0');
SIGNAL A: std_logic_vector(31 downto 0) := (others => '0');
SIGNAL B: std_logic_vector(31 downto 0) := (others => '0');
SIGNAL Result: std_logic_vector(31 downto 0) := (others => '0');
SIGNAL DR: std_logic_vector(31 downto 0) := (others => '0');

SIGNAL I_Class: instr_class_type;
SIGNAL I_Decoded: i_decoded_type;
SIGNAL DP_Imm: DP_type;

signal Imm8: std_logic_vector(31 downto 0); --for DP constant
signal Imm12: std_logic_vector(31 downto 0); --for DT offset
signal Imm24: std_logic_vector(31 downto 0); --for branch offset

SIGNAL Mem_WriteEnable: std_logic;
SIGNAL Mem_Address:  std_logic_vector(31 downto 0);
SIGNAL Mem_WriteData: std_logic_vector(31 downto 0);
SIGNAL Mem_ReadData: std_logic_vector(31 downto 0);

SIGNAL ES: std_logic_vector(2 downto 0);
SIGNAL CS: std_logic_vector(3 downto 0);
SIGNAL IDecoded: std_logic_vector(3 downto 0);


signal RF:RF_type := (others => "00000000000000000000000000000000");


BEGIN

debouncer_instance: debouncer port map(
    Clk=> Clk,
    push1 => go,
    push2 => step,
    push3 => instr,
    push4 => reset,
    debounced_push1=> debounced_go, 
    debounced_push2=> debounced_step,
    debounced_push3=> debounced_instr,
    debounced_push4=> debounced_reset
    );

control_state_FSM_instance: Control_State_FSM PORT MAP (
    Clk => Clk,
    Reset=> debounced_reset,
    Step=> debounced_step,
    Instr=> debounced_instr,
    Go => debounced_go,
    I_Class=> I_Class,
    I_Decoded => I_Decoded,
    Control_State=> Control_State,
    Execution_State => Execution_State);

execution_state_FSM_instance: Execution_State_FSM port map(
    Clk => Clk,
    Reset=> debounced_reset,
    Step=> debounced_step,
    Instr=> debounced_instr,
    Go=> debounced_go,
    I_Class => I_Class,
    Control_State => Control_State,
    Execution_State => Execution_State);
    
ALU_instance: ALU port map
(   Clk => Clk,
    ForcedCarry => ALU_ForcedCarry,
    Input1=> ALU_Input1,
    Input2=> ALU_Input2,
    ResultOutput=> ALU_ResultOutput,
    Control=> ALU_Control,
    FlagWriteEnable => ALU_FlagWriteEnable,
    I_Decoded=>I_Decoded,
    Set_Bit => Instruction(20),
    shift_carry_set => shift_carry_set,
    Flags=> ALU_Flags);

Register_File_instance: RegisterFile port map (
    Clk => Clk,
    Reset=> debounced_reset,
    Read1Data => RF_Read1Data,
    Read1Address => RF_Read1Address,
    Read2Data => RF_Read2Data,
    Read2Address => RF_Read2Address,
    WriteData => RF_WriteData,
    WriteAddress => RF_WriteAddress,
    WriteEnable => RF_WriteEnable,
    ReadPCData => RF_ReadPCData,
    WritePCData => RF_WritePCData,
    WritePCEnable => RF_WritePCEnable,
    RF_Out=>RF);

InstructionDecoder_instance: InstructionDecoder Port Map(
    Instruction => Instruction,
    I_Class => I_Class,
    DP_Imm => DP_Imm,
    I_Decoded => I_Decoded);

Memory: dist_mem_gen_0 port map(
    we => Mem_WriteEnable,
    clk=>Clk,
    a=> Mem_Address(9 downto 2),
    d=>Mem_WriteData,
    spo=>Mem_ReadData
    );

shifter_instance: Shifter PORT MAP(
    Clk => Clk,
        Shifter_Input => Shifter_Input,
        DP_Imm => DP_Imm,
        ShiftSpec => Instruction(11 downto 4),
        RotSpec => Instruction(11 downto 8),
        Rs => RF_Read2Data,
        shift_carry_set=> shift_carry_set,
        Shifter_Output => Shifter_Output);

Imm8 <= "000000000000000000000000" & Instruction(7 downto 0);
Imm12 <= "00000000000000000000" & Instruction(11 downto 0);
Imm24 <= "00000000" & Instruction(23 downto 0);

Mem_Address <= RF_ReadPCData WHEN Control_State = fetch ELSE Result;

Mem_WriteData <= B;

ALU_Input1 <= RF_ReadPCData WHEN Control_State = fetch ELSE
                A WHEN Control_State = arith OR Control_State = addr ELSE
                "00" & RF_ReadPCData(31 downto 2);

ALU_Input2 <= "00000000000000000000000000000100" WHEN Control_State = fetch ELSE
                Shifter_Output WHEN Control_State = arith ELSE
                Imm12 WHEN Control_State = addr ELSE
                Imm24;

Shifter_Input <= B WHEN DP_Imm = reg ELSE Imm8;

ALU_ForcedCarry <= '1' WHEN Control_State = brn ELSE '0';

ALU_Control <= Instruction(24 downto 21) WHEN Control_State = arith ELSE "0101" WHEN Control_State = brn ELSE "0100";

RF_WritePCData <= ALU_ResultOutput WHEN Control_State = fetch ELSE
                  ALU_ResultOutput(29 downto 0) & "00";
                    
RF_Read1Address <= Instruction(19 downto 16);
            
RF_Read2Address  <= Instruction(3 downto 0) WHEN Control_State = decode ELSE
                    Instruction(11 downto 8) WHEN Control_State = arith ELSE  
                    Instruction(15 downto 12);

RF_WriteData <= Result WHEN Control_State = res2RF ELSE DR;

RF_WriteAddress <= Instruction(15 downto 12);

Mem_WriteEnable <= '1' WHEN (I_Decoded = str AND Control_State = mem_wr) AND (Execution_State = oneinstr OR Execution_State = onestep OR Execution_State = cont) ELSE '0';
RF_WritePCEnable <= '1' WHEN (Control_State = fetch OR (I_Decoded = br AND Control_State = brn) OR (I_Decoded = beq AND ALU_Flags(2) = '1' AND Control_State = brn) OR (I_Decoded = bne AND ALU_Flags(2) = '0' AND Control_State = brn)) AND (Execution_State = oneinstr OR Execution_State = onestep OR Execution_State = cont) ELSE '0';
RF_WriteEnable <= '1' WHEN ((Control_State = res2RF AND (I_Decoded = andd OR I_Decoded = eor OR I_Decoded = orr OR I_Decoded = mov OR I_Decoded = mvn OR I_Decoded = bic OR I_Decoded = add OR I_Decoded = adc OR I_Decoded = sub OR I_Decoded = rsb OR I_Decoded = sbc OR I_Decoded = rsc)) OR Control_State = mem2RF) AND (Execution_State = oneinstr OR Execution_State = onestep OR Execution_State = cont) ELSE '0';
ALU_FlagWriteEnable <= '1' WHEN Control_State = arith AND (Execution_State = oneinstr OR Execution_State = onestep OR Execution_State = cont) ELSE '0';


PROCESS(Clk)
    BEGIN
        IF(debounced_reset = '1') THEN
            Instruction <= "00000000000000000000000000000000";
            A<= "00000000000000000000000000000000";
            B<= "00000000000000000000000000000000";
            Result<= "00000000000000000000000000000000";
            DR <= "00000000000000000000000000000000";
    	ELSIF(Execution_State = cont OR Execution_State = onestep OR Execution_State = oneinstr) THEN
        	IF(clk = '1' AND clk'EVENT) THEN
        		IF(Control_State = fetch) THEN
        			Instruction <= Mem_ReadData;
        		ELSIF(Control_State = decode) THEN
        			A <= RF_Read1Data;
        			B <= RF_Read2Data;
            	ELSIF(Control_State = arith) THEN
            		Result <= ALU_ResultOutput;
            	ELSIF(Control_State = addr) THEN
            		Result <= ALU_ResultOutput;
            		B <= RF_Read2Data;
            	ELSIF(Control_State = mem_rd) THEN
            		DR <= Mem_ReadData;
                END IF;
        	END IF;
        END IF;
END PROCESS;

WITH Display_Select SELECT
LED_Output <= Instruction(31 downto 16) WHEN "1000",
                Instruction(15 downto 0) WHEN "0000",
                A(31 downto 16) WHEN "1001",
                A(15 downto 0) WHEN"0001",
                B(31 downto 16)WHEN "1010",
                B(15 downto 0)WHEN "0010",
                DR(31 downto 16) WHEN"1011",
                DR(15 downto 0)WHEN "0011",
                Result(31 downto 16) WHEN "1100",
                Result(15 downto 0)WHEN "0100",
                "0000000000000" & ES WHEN "1101",
                "000000000000" & CS WHEN "0101",
                RF(to_integer(unsigned(RF_Select)))(31 downto 16) WHEN "1111",
                RF(to_integer(unsigned(RF_Select)))(15 downto 0) WHEN "0111",
                "000000000000" & IDecoded WHEN "0110",
                "000000000000" & ALU_Flags WHEN Others;

WITH Execution_State SELECT
ES <= "000" WHEN initial,
        "001" WHEN onestep,
        "010" WHEN oneinstr,
        "011" WHEN cont,
        "111" WHEN OTHERS;
      
WITH Control_State SELECT
CS <= "0001" WHEN fetch,
        "0010" WHEN decode,
        "0011" WHEN arith,
        "0100" WHEN res2RF,
        "0101" WHEN addr,
        "0110" WHEN mem_wr,
        "0111" WHEN mem_rd,
        "1000" WHEN mem2RF,
        "1001" WHEN brn,
        "1010" WHEN OTHERS;
WITH I_Decoded Select
IDecoded <= "0001" WHEN add,
        "0010" WHEN sub,
        "0011" WHEN cmp,
        "0100" WHEN mov,
        "0101" WHEN str,
        "0110" WHEN ldr,
        "0111" WHEN br,
        "1000" WHEN beq,
        "1111" WHEN bne,
        "0000" WHEN OTHERS;
        
END ARCHITECTURE P;


        