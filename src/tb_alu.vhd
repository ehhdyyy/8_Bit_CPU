library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is end tb_alu;

architecture sim of tb_alu is
    -- Component Declaration for ALU
    signal a, b, result : std_logic_vector(7 downto 0);
    signal alu_op : std_logic_vector(1 downto 0);

    begin
        dut: entity work.alu
            port map(
                a => a,
                b => b,
                alu_op => alu_op,
                result => result
            );
        
        process begin
            a <= x"07"; b <= x"03";
            alu_op <= "00"; wait for 10 ns; assert result = x"0A" report "ADD failed" severity error;
            alu_op <= "01"; wait for 10 ns; assert result = x"04" report "SUB failed" severity error;
            alu_op <= "10"; wait for 10 ns; assert result = x"03" report "AND failed" severity error;
            alu_op <= "11"; wait for 10 ns; assert result = x"07" report "OR failed" severity error;
            report "All ALU tests passed" severity note;
            wait;
        end process;
    end sim;
