library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port(
        a       : in std_logic_vector(7 downto 0);  -- 8 bit input A
        b       : in std_logic_vector(7 downto 0);  -- 8 bit input B
        alu_op  : in std_logic_vector(1 downto 0);  -- 2 bit operation selection signal
        result  : out std_logic_vector(7 downto 0) -- 8 bit output result
    );
end alu;

architecture Behavioral of alu is 
begin
    process(a, b, alu_op)
    begin
        case alu_op is 
            when "00" => -- ADD
                result <= std_logic_vector(unsigned(a) + unsigned(b));
            when "01" => -- SUB
                result <= std_logic_vector(unsigned(a) - unsigned(b));
            when "10" => -- AND
                result <= a and b;
            when "11" => -- OR
                result <= a or b;
            when others =>
                result <= (others => '0'); -- Default case
        end case;
    end process;
end Behavioral;


