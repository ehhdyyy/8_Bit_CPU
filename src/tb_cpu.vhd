library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cpu is end tb_cpu;

architecture sim of tb_cpu is
    -- Component Declaration for CPU
    signal clk, reset, hlt_out : std_logic := '0';
    signal pc_out : std_logic_vector(4 downto 0);
    signal acc_out : std_logic_vector(7 downto 0);

    begin
        dut: entity work.cpu
            port map(
                clk => clk,
                reset => reset,
                pc_out => pc_out,
                acc_out => acc_out,
                hlt_out => hlt_out
            );
        clk <= not clk after 5 ns;

        process begin
            reset <= '1'; wait for 12 ns; reset <= '0'; -- Apply reset
            wait until hlt_out = '1' for 200 ns;
            assert hlt_out = '1' report "CPU did not halt as expected" severity error;
            assert acc_out = x"0A" report "Final accumulator value incorrect, should be 10" severity error;
            assert pc_out = "00101" report "Final program counter value incorrect, should be 5" severity error;
            report "CPU test completed successfully" severity note;
            wait;
        end process;
    end sim;