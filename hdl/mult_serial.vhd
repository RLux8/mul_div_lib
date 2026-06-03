library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity mult_serial is
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
end entity mult_serial;

architecture behav of mult_serial is
    signal start_mul: boolean;
    signal next_m_accu, m_accu: std_logic_vector(result'range);
    signal m_done : boolean;
    signal m_start : boolean;
    signal m_abort: boolean;

    signal m_a, next_m_a: std_logic_vector(result'range);
    signal m_b, next_m_b: std_logic_vector(b'range);
    signal m_cycle, next_m_cycle: natural range 0 to 33;
begin
    m_start <= calc;


    mul_state_p: process(clk, res_n) is
    begin
        if res_n /= '1' then
            m_a <= (others => '0');
            m_b <= (others => '0');
            m_accu <= (others => '0');
            m_cycle <= 33;
        else
            if (clk'event and clk = '1') then  
                m_a         <= next_m_a;
                m_b         <= next_m_b;
                m_accu      <= next_m_accu;
                m_cycle     <= next_m_cycle;
            end if;
        end if;
    end process mul_state_p;


    m_done <= m_cycle = 0;
    m_abort <= m_b = x"00000000";
    busy   <= (m_cycle /= 0 and m_cycle /= 33) or (m_cycle = 0 and m_start);
    mul_calc_p: process(all) is
    begin
        next_m_cycle    <= m_cycle;
        next_m_accu     <= m_accu;
        next_m_a        <= m_a;
        next_m_b        <= m_b;

        if m_cycle = 33 and not m_start then
            next_m_cycle <= 0;
        end if;

        if m_start and m_cycle = 0 then
            next_m_cycle        <= 1;
            next_m_a            <= (others => '0');
            next_m_b            <= b;
            next_m_a(a'range)   <= a;
            next_m_accu         <= (others => '0');
        else
            if m_cycle /= 0 and m_cycle /= 33 then
                next_m_a        <= m_a(m_a'left - 1 downto 0) & '0';
                next_m_accu     <= std_logic_vector(unsigned(m_accu) + unsigned(m_a)) when m_b(0) = '1' else
                                   next_m_accu;
                next_m_b        <= '0' & m_b(m_b'left downto 1);

                if m_cycle = 32 or m_abort then
                    next_m_cycle <= 33;
                else
                    next_m_cycle    <= m_cycle + 1;
                end if;
            end if; 
        end if;
    end process mul_calc_p;

    result <= m_accu;
end architecture behav;

