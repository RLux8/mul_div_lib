LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY clk_res_gen_var IS
  GENERIC( 
    ONTIME    : time := 10 ns;
    OFFTIME   : time := 10 ns;
    RESETTIME : time := 35 ns
  );
  PORT( 
    clk   : OUT    std_logic;
    res_n : OUT    std_logic
  );
END clk_res_gen_var ;

ARCHITECTURE behav OF clk_res_gen_var IS
BEGIN
  osc: process is
  begin
    clk <= '0';
    wait for OFFTIME;
    clk <= '1';
    wait for ONTIME;
  end process osc;
  reset: process is
  begin
    res_n <= '0';
    wait for RESETTIME;
    res_n <= '1';
    wait;
  end process reset;
END ARCHITECTURE behav;

