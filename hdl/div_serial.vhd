library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;


entity div_serial is
    generic(
        WIDTHS          :     positive := 32
    ); 
    port (
        clk, res_n    : in    std_logic;

        calc          : in    boolean;

        a             : in    std_logic_vector(WIDTHS - 1 downto 0);
        b             : in    std_logic_vector(WIDTHS - 1 downto 0);

        quotient      : out   std_logic_vector(WIDTHS - 1 downto 0);
        remain        : out   std_logic_vector(WIDTHS - 1 downto 0);

        busy          : out   boolean
    );
end entity div_serial;

architecture behav of div_serial is
    signal m_done : boolean;
    signal m_start : boolean;
    signal m_abort: boolean;

    signal m_r, next_m_r: std_logic_vector(WIDTHS-1 downto 0);
    signal m_r_shifted: std_logic_vector(WIDTHS downto 0);
    signal m_q, next_m_q: std_logic_vector(WIDTHS downto 0);
    signal m_cycle, next_m_cycle: natural range 0 to WIDTHS+1;

    signal q, next_q: std_logic;
    signal alur: std_logic_vector(WIDTHS downto 0);
    signal invcarry: std_logic;
begin
    m_start <= calc;

    mul_state_p: process(clk, res_n) is
    begin
        if res_n /= '1' then
            m_q <= (others => '0');
            m_r <= (others => '0');
            m_cycle <= 0;
            q      <= '0';
        else
            if (clk'event and clk = '1') then  
                m_q         <= next_m_q;
                m_r         <= next_m_r;
                m_cycle     <= next_m_cycle;
                q           <= next_q;
            end if;
        end if;
    end process mul_state_p;


    alur   <= std_logic_vector(unsigned('0' & m_r)   + unsigned(b)) when q = '0' and m_cycle = WIDTHS else
              std_logic_vector(unsigned(m_r_shifted) + unsigned(b)) when q = '0' else
              std_logic_vector(unsigned(m_r_shifted) - unsigned(b));

    invcarry <= not alur(WIDTHS);

    m_r_shifted <= m_r & m_q(WIDTHS);


    m_done <= m_cycle = 0;
    m_abort <= false;
    busy   <= (m_cycle /= 0 and m_cycle /= WIDTHS+1) or (m_cycle = 0 and m_start);
    mul_calc_p: process(all) is
    begin
        next_m_cycle    <= m_cycle;
        next_m_r        <= m_r;
        next_m_q        <= m_q;
        next_q          <= invcarry;

        if m_cycle = WIDTHS+1 and not m_start then
            next_m_cycle <= 0;
        end if;

        if m_start and m_cycle = 0 then
            next_m_cycle        <= 1;
            next_m_r            <= (others => '0');
            next_m_q            <= a(WIDTHS-1 downto 0) & '0';
            next_q              <= '1';
        else
            if m_cycle /= 0 and m_cycle /= WIDTHS and m_cycle /= WIDTHS+1 then
                next_m_q        <= m_q(WIDTHS-1 downto 0) & invcarry;
                next_m_r        <= alur(WIDTHS-1 downto 0);
                next_m_cycle    <= m_cycle + 1;
            elsif m_cycle = WIDTHS then
                if q = '0' then
                    next_m_r        <= alur(WIDTHS-1 downto 0);
                end if;
                next_m_q        <= m_q;
                next_m_cycle    <= m_cycle + 1;
            end if; 
        end if;
    end process mul_calc_p;

    quotient <= m_q(WIDTHS-1 downto 0);
    remain <= m_r;
end architecture behav;

