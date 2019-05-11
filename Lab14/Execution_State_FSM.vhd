library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MyType.ALL;

ENTITY Execution_State_FSM IS
PORT (Clk: IN std_logic;
        Reset: IN std_logic;
        Step: IN std_logic;
        Instr: IN std_logic;
        Go: IN std_logic;
        I_Class: IN instr_class_type;
        Control_State: IN control_state_type;
        Execution_State: OUT state_type);
END ENTITY;

ARCHITECTURE ESFSM OF Execution_State_FSM IS

SIGNAL e_state: state_type;

BEGIN

Execution_State <= e_state;

PROCESS(Clk, Reset)
BEGIN 
        IF(Reset = '1') THEN
            e_state <= initial;
        ELSIF(Clk = '1' AND Clk'EVENT) THEN
        	IF(e_state = initial) THEN
        		IF(Step = '1') THEN
        			e_state <= onestep;
        		ELSIF(Instr = '1') THEN
        			e_state <= oneinstr;
        		ELSIF(Go = '1') THEN
        			e_state <= cont;
        		END IF;
        	ELSIF(e_state = onestep) THEN
        		e_state <= done;
        	ELSIF(e_state = oneinstr) THEN
        		IF(Control_State = res2RF OR Control_State = mem_wr OR Control_State = mem2RF OR Control_State = brn OR Control_State = halt) THEN
        			e_state <= done;
        		END IF;
        	ELSIF(e_state = cont) THEN
        		IF(Control_State = halt) THEN
        			e_state <= done;
				END IF;
			ELSIF(e_state = done) THEN
				IF(Step = '0' AND Instr = '0' AND Go = '0') THEN
					e_state <= initial;
				END IF;
        	END IF;
        END IF;
END PROCESS;

END ARCHITECTURE ESFSM;
