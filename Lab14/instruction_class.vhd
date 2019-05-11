library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package MyType is 
type instr_class_type is (DP, DT, branch, halt, unknown);
type i_decoded_type is (andd, eor, sub, rsb, add, adc, sbc, rsc, tst, teq, cmp, cmn, orr, mov, bic, mvn, ldr,str,beq,bne,br,halt,unknown);
type DP_type is (reg, imm);
type state_type is (initial, onestep, oneinstr, cont, done);
type RF_type is array (0 to 15) of std_logic_vector (31 downto 0);
type control_state_type is (fetch, decode, arith, res2RF, addr, mem_wr, mem_rd, mem2RF, brn, halt);
end package;