

library ieee; 
    use ieee.std_logic_1164.all;
    use ieee.math_real.uniform;
    use ieee.math_real.floor;
    use ieee.numeric_std.all;

library mul_div_lib;
    use mul_div_lib.div_serial;
    use mul_div_lib.mult_serial;

entity muldiv_tb is
end entity muldiv_tb;

architecture mixed of muldiv_tb is
    component div_serial is
    generic(
        WIDTHS          :     positive := 32
    ); 
    port (
        clk, res_n    : in    std_logic;

        calc          : in    boolean;

        a             : in    std_logic_vector(WIDTHS - 1 downto 0);
        b             : in    std_logic_vector(WIDTHS - 1 downto 0);

        quotient          : out   std_logic_vector(WIDTHS - 1 downto 0);
        remain        : out   std_logic_vector(WIDTHS - 1 downto 0);

        busy          : out   boolean
    );
    end component div_serial;

    component mult_serial is
        generic(
            WIDTHS          :     positive := 32
        ); 
        port (
            clk, res_n    : in    std_logic;

            calc          : in    boolean;

            a             : in    std_logic_vector(WIDTHS - 1 downto 0);
            b             : in    std_logic_vector(WIDTHS - 1 downto 0);

            result        : out   std_logic_vector(2*WIDTHS - 1 downto 0);

            busy          : out   boolean
        );
    end component mult_serial;

    COMPONENT clk_res_gen_var
        GENERIC (
            ONTIME    : time := 10 ns;
            OFFTIME   : time := 10 ns;
            RESETTIME : time := 35 ns
        );
        PORT (
            clk   : OUT    std_logic;
            res_n : OUT    std_logic
        );
    END COMPONENT;

    signal clk: std_logic;
    signal res_n: std_logic;


    constant CALC_SIZE: positive := 10;
    subtype word_t is std_logic_vector(CALC_SIZE-1 downto 0);
    subtype dword_t is std_logic_vector(2*CALC_SIZE-1 downto 0);
    signal tv_a: word_t;
    signal tv_b: word_t;

    signal calc_start: boolean;

    signal div_q: word_T;
    signal div_remain: word_T;
    signal exp_div_q: word_T;
    signal exp_div_remain: word_T;
    signal mul_res: dword_T;
    signal exp_mul_res: dword_T;

    signal div_busy: boolean;
    signal mul_busy: boolean;
    signal either_busy: boolean;
begin

    idiv_dut: div_serial
        generic map(
            WIDTHS => CALC_SIZE
        ) 
        port map(
            clk => clk,
            res_n => res_n,

            calc => calc_start,

            a => tv_a,
            b => tv_b,

            quotient => div_q,
            remain => div_remain,  

            busy => div_busy
        );

    imul_dut: mult_serial
        generic map(
            WIDTHS => CALC_SIZE
        ) 
        port map(
            clk => clk,
            res_n => res_n,

            calc => calc_start,

            a => tv_a,
            b => tv_b,

            result => mul_res,

            busy => mul_busy
        );


    iclk: clk_res_gen_var
        port map(
            clk     => clk,
            res_n   => res_n
        );

    either_busy <= div_busy or mul_busy;

    exp_mul_res         <= std_logic_vector(unsigned(tv_a) * unsigned(tv_b));
    exp_div_q           <= std_logic_vector(unsigned(tv_a) / unsigned(tv_b));
    exp_div_remain      <= std_logic_vector(unsigned(tv_a) rem unsigned(tv_b));

    testvec_p: process
        variable seed1 : positive;
        variable seed2 : positive;
        variable x : real;
        variable y : integer;
    begin
        seed1 := 1;
        seed2 := 1;
        calc_start <= false;
        wait until res_n = '1';
        for n in 1 to 1_000_000 loop
            uniform(seed1, seed2, x);
            tv_a <= std_logic_vector(to_unsigned(integer(floor(x * 2.0 ** CALC_SIZE)), CALC_SIZE));
            uniform(seed1, seed2, x);
            tv_b <= std_logic_vector(to_unsigned(integer(floor(x * 2.0 ** CALC_SIZE)), CALC_SIZE));
            calc_start <= true;
            wait until rising_edge(clk);
            wait until either_busy = false;
            calc_start <= false;
            wait until falling_edge(clk);
            assert unsigned(mul_res) = unsigned(tv_a) * unsigned(tv_b) report "damn" severity warning;
            assert unsigned(div_q)   = unsigned(tv_a) / unsigned(tv_b) report "damn" severity warning;
            wait until rising_edge(clk);
        end loop;
    end process testvec_p;



end architecture mixed;