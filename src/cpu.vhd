library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is   -- 8 bit CPU
    port(
        clk     : in std_logic;                     -- Clock input
        reset   : in std_logic;                     -- Reset input
        pc_out  : out std_logic_vector(4 downto 0); -- 5 bit program counter output
        acc_out : out std_logic_vector(7 downto 0); -- 8 bit accumulator output
        hlt_out : out std_logic                     -- Halt output
    );
end cpu;

architecture Behavioral of cpu is 

    -- Component Declaration from ALU
    component alu is
        port(
            a       : in std_logic_vector(7 downto 0);  -- 8 bit input A
            b       : in std_logic_vector(7 downto 0);  -- 8 bit input B
            alu_op  : in std_logic_vector(1 downto 0);  -- 2 bit operation selection signal
            result  : out std_logic_vector(7 downto 0) -- 8 bit output result
        );
    end component;

    -- Memory Types: 32 locations x 8 bits
    type mem_type is array (0 to 31) of std_logic_vector(7 downto 0);
    
    -- Instruction Memory (ROM) - using demonstration program
    constant ROM: mem_type := (
        0 => "00000111", -- LDI 7
        1 => "01000000", -- STA 0 => RAM[0] = 7
        2 => "00000011", -- LDI 3 into ACC
        3 => "01100000", -- ADD 0 => ACC = 3 + RAM[0] = 10 <= 7 + 3
        4 => "01000001", -- STA 1 => RAM[1] = 10
        5 => "11100000", -- Halt
        others => "11100000"
    );

    -- Data Memory (RAM)
    signal RAM: mem_type := (others => (others => '0'));

    -- CPU Registers (Program Counter, Accumulator, Halt Flag)
    signal pc_reg : unsigned(4 downto 0) := (others => '0');         -- 5 bit program counter
    signal acc_reg: std_logic_vector(7 downto 0) := (others => '0'); -- 8 bit accumulator
    signal hlt_reg: std_logic := '0';                                -- Halt flag

    -- Instruction Decoding and Control Signals
    signal instruction : std_logic_vector(7 downto 0); -- Current instruction
    signal opcode      : std_logic_vector(2 downto 0); -- 3 bit opcode
    signal operand     : std_logic_vector(4 downto 0); -- 5 bit operand (address or immediate value)
    signal ram_dout    : std_logic_vector(7 downto 0); -- Data read from RAM
    signal imm_ext     : std_logic_vector(7 downto 0); -- Sign-extended immediate value 

    -- Control Unit Outputs
    signal alu_op      : std_logic_vector(1 downto 0); -- ALU operation selection
    signal alu_res  : std_logic_vector(7 downto 0); -- ALU result output
    signal acc_we     : std_logic; -- Accumulator write enable
    signal acc_src    : std_logic_vector(1 downto 0); -- 0: ALU result, 1: RAM data, 2: Immediate value
    signal ram_we     : std_logic; -- RAM write enable
    signal hlt_cmd    : std_logic; -- Halt command signal

    begin 
        
        -- Instantiate Instruction Fetch and Decode Process
        instruction <= ROM(to_integer(pc_reg));
        opcode <= instruction(7 downto 5);
        operand <= instruction(4 downto 0);
        ram_dout <= RAM(to_integer(unsigned(operand)));
        imm_ext <= (7 downto 5 => instruction(4)) & instruction(4 downto 0); -- Sign extension for immediate value

        -- Instantiate ALU
        alu_unit: alu
            port map(
                a => acc_reg,
                b => ram_dout,
                alu_op => alu_op,
                result => alu_res
            );
        
        -- CPU Control Logic
        process(opcode)
        begin
            -- Default control signals
            alu_op <= "00"; -- Default to ADD operation
            acc_we <= '0';
            acc_src <= "00"; -- Default to ALU result
            ram_we <= '0';
            hlt_cmd <= '0';

            -- Control logic based on opcode
            case opcode is 
                when "000" => -- Load Immediate Value into ACC
                    acc_we <= '1';
                    acc_src <= "10"; -- Select immediate value
                when "001" => -- Load from RAM into ACC
                    acc_we <= '1';
                    acc_src <= "01"; -- Select RAM data
                when "010" => -- Store ACC into RAM
                    ram_we <= '1';
                when "011" => -- Add RAM value to ACC
                    alu_op <= "00"; -- ADD operation
                    acc_we <= '1';
                    acc_src <= "00"; -- Select ALU result
                when "100" => -- Subtract RAM value from ACC
                    alu_op <= "01"; -- SUB operation
                    acc_we <= '1';
                    acc_src <= "00"; -- Select ALU result
                when "101" => -- AND RAM value with ACC
                    alu_op <= "10"; -- AND operation
                    acc_we <= '1';
                    acc_src <= "00"; -- Select ALU result
                when "110" => -- OR RAM value with ACC
                    alu_op <= "11"; -- OR operation
                    acc_we <= '1';
                    acc_src <= "00"; -- Select ALU result
                when "111" => -- Halt the CPU
                    hlt_cmd <= '1';
                when others =>
                    null; -- No operation for undefined opcodes
            end case;
        end process;

        -- CPU State Update Process
        process(clk, reset)
        begin
            if reset = '1' then
                pc_reg <= (others => '0');
                acc_reg <= (others => '0');
                hlt_reg <= '0';
                RAM <= (others => (others => '0'));
            elsif rising_edge(clk) then
                if hlt_cmd = '1' then
                    hlt_reg <= '1'; -- Set halt flag
                else
                    -- Update Program Counter
                    pc_reg <= pc_reg + 1;

                    -- Update Accumulator based on control signals
                    if acc_we = '1' then
                        case acc_src is
                            when "00" => acc_reg <= alu_res; -- ALU result
                            when "01" => acc_reg <= ram_dout; -- RAM data
                            when "10" => acc_reg <= imm_ext;  -- Immediate value
                            when others => null;
                        end case;
                    end if;

                    -- Write to RAM if enabled
                    if ram_we = '1' then
                        RAM(to_integer(unsigned(operand))) <= acc_reg;
                    end if;
                end if;
            end if;
        end process;

        -- Output Assignments
        pc_out <= std_logic_vector(pc_reg);
        acc_out <= acc_reg;
        hlt_out <= hlt_reg;

    end Behavioral;
