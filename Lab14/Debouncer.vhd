library IEEE;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY debouncer IS
PORT (Clk: IN std_logic;
    push1, push2, push3, push4: IN std_logic;
    debounced_push1, debounced_push2, debounced_push3, debounced_push4: OUT std_logic);
END ENTITY;

ARCHITECTURE d OF debouncer IS

SIGNAL slow_clock: std_logic := '0';
SIGNAL count: std_logic_vector(19 downto 0) := (others => '0');

BEGIN

PROCESS(Clk)
BEGIN
    IF(Clk = '1' AND Clk'EVENT) THEN
        count <= count +1;
    END IF;
END PROCESS;

PROCESS(count)
BEGIN
    IF(count = "00000000000000000000") THEN
        slow_clock <= '0';
    ELSIF(count = "10000000000000000000") THEN
        slow_clock <= '1';
    END IF;
END PROCESS;

PROCESS(slow_clock)
BEGIN
    IF(slow_clock = '1' AND slow_clock'EVENT) THEN
        debounced_push1 <= push1;
        debounced_push2 <= push2;
        debounced_push3 <= push3;
        debounced_push4 <= push4;
    END IF;
END PROCESS;

END ARCHITECTURE d;
