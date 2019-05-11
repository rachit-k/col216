library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY Control_State_FSM IS
PORT (Clk: IN std_logic;
        Reset: IN std_logic;
        Step: IN std_logic;
        Instr: IN std_logic;
        Go: IN std_logic;
        I_Class: IN instr_class_type;
        I_Decoded: IN i_decoded_type;
        Execution_State: IN state_type;
        Control_State: OUT control_state_type);
        
END ENTITY;

ARCHITECTURE CSFSM OF Control_State_FSM IS

SIGNAL c_State: control_state_type;

BEGIN

Control_State <= c_State;

PROCESS(Clk, Reset)
BEGIN
    IF(Reset = '1') THEN
        c_State <= fetch;
    ELSIF(Execution_State = onestep OR Execution_State = oneinstr OR Execution_State = cont) THEN
        IF(Clk = '1' AND Clk'EVENT) THEN
            IF(c_State = fetch) THEN
                c_State <= decode;
            ELSIF(c_State = decode) THEN
                IF(I_Class = DP) THEN
                    c_State <= arith;
                ELSIF(I_Class = DT) THEN
                    c_State <= addr;
                ELSIF(I_Class = branch) THEN
                    c_State <= brn;
                ELSE c_State <= halt;
                END IF;
            ELSIF(c_State = arith) THEN
                c_State <= res2RF;
            ELSIF(c_State = res2RF) THEN
                c_State <= fetch;
            ELSIF(c_State = addr) THEN
                IF(I_Decoded = ldr) THEN
                    c_State <= mem_rd;
                ELSIF(I_Decoded = str) THEN
                    c_State <= mem_wr;
                ELSE c_State <= halt;
                END IF;
            ELSIF(c_State = mem_wr) THEN
                c_State <= fetch;
            ELSIF(c_State = mem_rd) THEN
                c_State <= mem2RF;
            ELSIF(c_State = mem2RF) THEN
                c_State <= fetch;
            ELSIF(c_State = brn) THEN
                c_State <= fetch;
            ELSIF(c_State = halt) THEN
                c_State <= fetch;
            END IF;
        END IF;
    END IF;
END PROCESS;

END ARCHITECTURE CSFSM;