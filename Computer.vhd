library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Computer is
	port(
		clk : in std_logic
	);
end Computer;

architecture behavorial of Computer is

	--	Constants:
	constant T0 : std_logic_vector(3 downto 0) := "0001";
	constant T1 : std_logic_vector(3 downto 0) := "0010";
	constant T2 : std_logic_vector(3 downto 0) := "0100";
	constant T3 : std_logic_vector(3 downto 0) := "1000";

	constant	C_LDA : std_logic_vector(3 downto 0) := "0110";
	constant	C_STA : std_logic_vector(3 downto 0) := "0111";
	constant	C_BUN : std_logic_vector(3 downto 0) := "1000";
	constant	C_BSA : std_logic_vector(3 downto 0) := "1001";
	constant	C_DSZ : std_logic_vector(3 downto 0) := "1010";
	constant	C_LDC : std_logic_vector(3 downto 0) := "1011";
	constant	C_RET : std_logic_vector(3 downto 0) := "1100";
	constant	C_BZ  : std_logic_vector(3 downto 0) := "1101";
	constant	C_BC  : std_logic_vector(3 downto 0) := "1110";

	constant	C_CLA : std_logic_vector(7 downto 0) := "00000001";
	constant	C_CLS : std_logic_vector(7 downto 0) := "00000010";
	constant	C_CMA : std_logic_vector(7 downto 0) := "00000100";
	constant	C_SRA : std_logic_vector(7 downto 0) := "00001000";
	constant	C_SLA : std_logic_vector(7 downto 0) := "00010000";
	constant	C_INC : std_logic_vector(7 downto 0) := "00100000";
	constant	C_HALT : std_logic_vector(7 downto 0) := "01000000";
                      
	constant	C_INP : std_logic_vector(7 downto 0) := "00000001";
	constant	C_OUT : std_logic_vector(7 downto 0) := "00000010";
	constant	C_SKI : std_logic_vector(7 downto 0) := "00000100";
	constant	C_SKO : std_logic_vector(7 downto 0) := "00001000";
	constant	C_ION : std_logic_vector(7 downto 0) := "00010000";
	constant	C_IOF : std_logic_vector(7 downto 0) := "00100000";
	constant	C_SFI : std_logic_vector(7 downto 0) := "01000000";
	constant	C_SFO : std_logic_vector(7 downto 0) := "10000000";

	constant	fetch : std_logic_vector(7 downto 0) := "00000000";
	constant	direct : std_logic_vector(7 downto 0) := "00000001";
	constant	indirect : std_logic_vector(7 downto 0) := "00000010";
	constant	execution : std_logic_vector(7 downto 0) := "00000011";
	constant	interrupt : std_logic_vector(7 downto 0) := "00000100";
	constant	fetch_done : std_logic_vector(7 downto 0) := "00000101";
	constant	execute_memory_reference : std_logic_vector(7 downto 0) := "00000110";
	constant	execute_register_reference : std_logic_vector(7 downto 0) := "00000111";
	constant	execute_io_reference : std_logic_vector(7 downto 0) := "00001000";
	constant	alu_execution : std_logic_vector(7 downto 0) := "00001001";
	constant	execution_end : std_logic_vector(7 downto 0) := "00001010";
	constant	halt : std_logic_vector(7 downto 0) := "00001011";
	
	signal mbr_dec,ram_rd, ram_wr, counter_clr, mux_2_10_sel, mux_2_16_sel, i0_load, i0_out, i1_load, i1_out : std_logic;
	signal pc_load, pc_inc, pc_clr, ar_load, ar_inc, mar_load, mar_clr, mbr_load, cr_load, inp_load, opr_load, outr_load, ac_load, ac_inc, ac_clr, ac_sr, ac_sl, mbr_inc : std_logic;
 	signal INF, Z_flag, C_flag, FGI, FGO : std_logic;
	signal counter_out, I, mux_4_sel : std_logic_vector(1 downto 0);
	signal bus_sel : std_logic_vector(2 downto 0);
	signal dec_2_out, opr_out : std_logic_vector(3 downto 0);
	signal ac_out, alu_out, inverter_out, mux_4_out, cr_out, inp_in, inp_out, outr_out : std_logic_vector(7 downto 0);
	signal pc_out, ar_out, mux_2_10_out, mar_out : std_logic_vector(9 downto 0);
	signal data, dec_4_out, ram_out, mbr_out, mux_2_16_out : std_logic_vector(15 downto 0);

	signal begin_ram : std_logic := '1';
	signal begin_alu : std_logic := '0';
	
	signal state : std_logic_vector(7 downto 0) := "00000000";
	
	
	component Register_Generic is
		generic (n : integer);
		port(
			clk : in std_logic;
			load : in std_logic;
			inc : in std_logic;
			dec : in std_logic;
			clr : in std_logic;
			sr : in std_logic;
			sl : in std_logic;
			data_in : in std_logic_vector(n-1 downto 0);
			data_out : out std_logic_vector(n-1 downto 0)
		);
		end component Register_Generic;
		
	
	component Generic_Decoder is
		generic (n : integer);
		port(
			input : in std_logic_vector (n-1 downto 0);
			output : out std_logic_vector ((2**n)-1 downto 0)
		);
	end component Generic_Decoder;
	
	component Bus_Component is
		port(
			pc : in std_logic_vector(9 downto 0);
			ar : in std_logic_vector(9 downto 0);
			inp : in std_logic_vector(7 downto 0);
			mbr : in std_logic_vector(15 downto 0);
			ac : in std_logic_vector(7 downto 0);
			sel : in std_logic_vector(2 downto 0);
			output : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component DFF is
		port(
			clk : in std_logic;
			en : in std_logic;
			d : in std_logic;
			q : out std_logic
		);
	end component DFF;

	component Ram is
		port(
			init : in std_logic;
			rd : in std_logic;
			wr : in std_logic;
			address : in std_logic_vector(9 downto 0);
			data_in : in std_logic_vector(15 downto 0);
			data_out : out std_logic_vector(15 downto 0)
		);
	end component Ram;
	
	component Inverter is
		port(
			data_in : in std_logic_vector(7 downto 0);
			data_out : out std_logic_vector(7 downto 0)
		);
	end component Inverter;

	component Generic_Mux is
		generic(n : natural);
		port(
			i0 : in std_logic_vector(n-1 downto 0);
			i1 : in std_logic_vector(n-1 downto 0);
			sel : in std_logic;
			output : out std_logic_vector(n-1 downto 0)
		);
	end component Generic_Mux;

	component Mux_4 is
		port(
			i0 : in std_logic_vector(7 downto 0);
			i1 : in std_logic_vector(7 downto 0);
			i2 : in std_logic_vector(7 downto 0);
			i3 : in std_logic_vector(7 downto 0);
			sel : in std_logic_vector(1 downto 0);
			output : out std_logic_vector(7 downto 0)
		);
	end component Mux_4;

	component ALU is
		port(
			input_ready : in std_logic;
			operation : in std_logic_vector(3 downto 0);
			data_in_ac : in std_logic_vector(7 downto 0);
			data_in_bus : in std_logic_vector(7 downto 0);
			data_out : out std_logic_vector(7 downto 0)
		);
	end component ALU;
	
	component Counter is
		port(
			clk : in std_logic;
			clr : in std_logic;
			data_out : out std_logic_vector(1 downto 0)
		);
	end component Counter;

begin
	process(clk)
		variable init : boolean := true;
		
	begin
		if(init = true) then
			init := false;
			begin_ram <= '0';
			counter_clr <= '1';
		end if;
		
		if(rising_edge(clk)) then
			case state is
				when fetch =>
					counter_clr <= '0';
					case dec_2_out is
						when T0 =>
							mux_2_10_sel <= '0';
							mar_load <= '1';

						when T1 =>
							mar_load <= '0';
							pc_inc <= '1';
							ram_rd <= '1';
							mux_2_16_sel <= '0';
							mbr_load <= '1';
							
						when T2 =>
							pc_inc <= '0';
							ram_rd <= '0';
							mbr_load <= '0';
							I0_load <= '1';
							I1_load <= '1';
							opr_load <= '1';
							ar_load <= '1';
							bus_sel <= "011";

						when T3 =>
							I0_load <= '0';
							I1_load <= '0';
							opr_load <= '0';
							ar_load <= '0';
							state <= fetch_done;

						when others =>
					end case;

				when fetch_done =>
					if(I1_out = '1') then
						if(I0_out = '0') then
							counter_clr <= '1';
							state <= execute_memory_reference;
						else
							if(opr_out(3) = '0') then
								state <= execute_register_reference;
								counter_clr <= '1';
							else
								state <= execute_io_reference;
								counter_clr <= '1';
							end if;
						end if;
					elsif(I0_out = '1') then
						counter_clr <= '1';
						state <= indirect;
					else
						counter_clr <= '1';
						state <= direct;
					end if;

				when direct =>
					counter_clr <= '0';
					case dec_2_out is
						when T0 =>
							mux_2_10_sel <= '1';
							mar_load <= '1';

						when T1 =>
							mar_load <= '0';
							ram_rd <= '1';
							mux_2_16_sel <= '0';
							mbr_load <= '1';
							counter_clr <= '1';
							state <= execute_memory_reference;

						when others =>
					end case;

				when execute_memory_reference =>
					counter_clr <= '0';
					ram_rd <= '0';
					mbr_load <= '0';
					case dec_2_out is
						when T0 =>
							if(unsigned(opr_out) > 5) then
								case opr_out is
									when C_LDA =>
										mux_4_sel <= "00";
										ac_load <= '1';
										state <= execution_end;

									when C_STA =>
										mar_load <= '1';
										mux_2_10_sel <= '1';
										mbr_load <= '1';
										mux_2_16_sel <= '1';
										bus_sel <= "100";
									
									when T3 =>
										bus_sel <= "001";
										pc_load <= '1';
										state <= execution_end;
	
									when C_BSA =>
										bus_sel <= "000";
										mux_2_16_sel <= '1';
										mbr_load <= '1';
										mar_load <= '1';
										mux_2_10_sel <= '1';
		
									when C_DSZ =>
										mbr_dec <= '1';

									when C_LDC =>
										cr_load <= '1';
										bus_sel <= "011";
										state <= execution_end;

									when C_RET =>
										-- RET

									when C_BZ =>
										if(Z_flag = '1') then
											pc_inc <= '1';
										else
											pc_load <= '1';
											bus_sel <= "011";
										end if;
										state <= execution_end;

									when C_BC =>
										if(C_flag = '1') then
											pc_inc <= '1';
										else
											pc_load <= '1';
											bus_sel <= "011";
										end if;
										state <= execution_end;
	
									when others =>
								end case;
							else
								state <= alu_execution;
							end if;

						when T1 =>
							case opr_out is
								when C_STA =>
									ram_wr <= '1';
									mar_load <= '0';
									mbr_load <= '0';
									state <= execution_end;

								when C_BSA =>
									ram_wr <= '1';
									ar_inc <= '1';
									mbr_load <= '0';
									mar_load <= '0';
				
								when C_DSZ =>
									mbr_dec <= '0';
									ram_wr <= '1';
									ac_load <= '1';
									bus_sel <= "011";
										
								when others =>
							end case;
						when T2 =>
							case opr_out is
								when C_BSA =>
									ram_wr <= '0';
									ar_inc <= '0';
									pc_load <= '1';
									bus_sel <= "001";
									state <= execution_end;
								
								when C_DSZ =>
									ram_wr <= '0';
									ac_load <= '0';
									if(ac_out = "00000000") then
										pc_inc <= '1';
									end if;
									state <= execution_end;

								when others =>
							end case;

						when others =>
					end case;

				when alu_execution =>
					ac_load <= '1';
					begin_alu <= '1';
					mux_4_sel <= "01";	
					state <= execution_end;

				when execute_register_reference =>
					counter_clr <= '0';
					case dec_2_out is
						when T0 =>
							case mbr_out(7 downto 0) is
								when C_CLA =>
									ac_clr <= '1';
									state <= execution_end;

								when C_CLS =>
									Z_flag <= '1';
									C_flag <= '1';
									state <= execution_end;
			
								when C_CMA =>
									ac_load <= '1';
									mux_4_sel <= "10";
									state <= execution_end;
												
								when C_SRA =>
									ac_sr <= '1';
									state <= execution_end;
									
								when C_SLA =>
									ac_sl <= '1';
									state <= execution_end;
									
								when C_INC =>
									ac_inc <= '1';
									state <= execution_end;
									
								when C_HALT =>
									state <= halt;
									
								when others =>
							end case;
						when others =>
					end case;

				when execute_io_reference =>
					counter_clr <= '0';
					case dec_2_out is
						when "0001" =>
							case mbr_out(7 downto 0) is
								when C_INP =>
									ac_load <= '1';
									bus_sel <= "010";
									mux_4_sel <= "00";
									FGI <= '0';
									state <= execution_end;

								when C_OUT =>
									bus_sel <= "100";
									outr_load <= '1';
									FGO <= '0';
									state <= execution_end;
			
								when C_SKI =>
									if(FGI = '1') then
										pc_inc <= '1';
									end if;
									state <= execution_end;
												
								when C_SKO =>
									if(FGO = '1') then
										pc_inc <= '1';
									end if;
									state <= execution_end;
									
								when C_ION =>
									inf <= '1';
									state <= execution_end;
									
								when C_IOF =>
									inf <= '0';
									state <= execution_end;
									
								when C_SFI =>
									FGI <= '1';
									state <= execution_end;

								when C_SFO =>
									FGO <= '1';
									state <= execution_end;
									
								when others =>
							end case;
						when others =>
					end case;

				when execution_end =>
					outr_load <= '0';
					ac_inc <= '0';
					ac_sr <= '0';
					ac_sl <= '0';
					ac_clr <= '0';
					cr_load <= '0';
					pc_inc <= '0';
					ram_wr <= '0';
					ac_load <= '0';
					pc_load <= '0';
					begin_alu <= '0';
					counter_clr <= '1';
					if(inf = '0') then
						state <= fetch;
					else
						state <= interrupt;
					end if;

				when indirect =>
					counter_clr <= '0';
					case dec_2_out is
						when "0001" =>
							mux_2_10_sel <= '1';
							mar_load <= '1';

						when T1 =>
							mar_load <= '0';
							ram_rd <= '1';
							mux_2_16_sel <= '0';
							mbr_load <= '1';
							
						when T2 =>
							ram_rd <= '0';
							mbr_load <= '0';
							ar_load <= '1';
							bus_sel <= "011";
							state <= direct;

						when others =>
					end case;

				when interrupt =>
					counter_clr <= '0';
					case dec_2_out is
						when "0001" =>
							mbr_load <= '1';
							bus_sel <= "000";
							mux_2_16_sel <= '1';
							inf <= '0';
	
						when T1 =>
							mbr_load <= '0';
							pc_clr <= '1';
							mar_clr <= '1';

						when T2 =>
							pc_clr <= '0';
							mar_clr <= '0';
							ram_wr <= '1';
							pc_inc <= '1';

						when T3 =>
							ram_wr <= '0';
							pc_inc <= '0';
							counter_clr <= '1';
							state <= fetch;
		
						when others =>
					end case;

				when others =>
			end case;
		end if;
	end process;
	
	bus_comp : Bus_Component port map(sel => bus_sel, pc => pc_out, ar => ar_out, inp => inp_out, mbr => mbr_out, ac => ac_out, output => data);
	seq_counter : Counter port map(clk => clk, clr => counter_clr, data_out => counter_out);
	dec_2 : Generic_Decoder generic map (n => 2) port map(input => counter_out, output => dec_2_out);

	PC : Register_Generic generic map (n => 10) port map(clk => clk, data_in => data(9 downto 0), data_out => pc_out, load => pc_load, inc => pc_inc, dec => '0', clr => pc_clr, sr => '0', sl => '0');
	AR : Register_Generic generic map (n => 10) port map(clk => clk, data_in => data(9 downto 0), data_out => ar_out, load => ar_load, inc => ar_inc, dec => '0', clr => '0', sr => '0', sl => '0');
	mux_2_10 : Generic_Mux generic map (n => 10) port map(i0 => PC_out, i1 => AR_out, sel => mux_2_10_sel, output => mux_2_10_out);
	MAR : Register_Generic generic map (n => 10) port map(clk => clk, data_in => mux_2_10_out, data_out => mar_out, load => mar_load, inc => '0', dec => '0', clr => mar_clr, sr => '0', sl => '0');
	Memory : Ram port map(init => begin_ram, rd => ram_rd, wr => ram_wr, address => mar_out, data_in => mbr_out, data_out => ram_out);
	mux_2_16 : Generic_Mux generic map (n => 16) port map(i0 => ram_out, i1 => data, sel => mux_2_16_sel, output => mux_2_16_out);
	MBR : Register_Generic generic map (n => 16) port map(clk => clk, data_in => mux_2_16_out, data_out => mbr_out, load => mbr_load, inc => mbr_inc, dec => mbr_dec, clr => '0', sr => '0', sl => '0');
	CR : Register_Generic generic map (n => 8) port map(clk => clk, data_in => data(7 downto 0), data_out => cr_out, load => cr_load, inc => '0', dec => '0', clr => '0', sr => '0', sl => '0');
	INP : Register_Generic generic map (n => 8) port map(clk => clk, data_in => inp_in, data_out => inp_out, load => inp_load, inc => '0', dec => '0', clr => '0', sr => '0', sl => '0');
	OUTR : Register_Generic generic map (n => 8) port map(clk => clk, data_in => data(7 downto 0), data_out => outr_out, load => outr_load, inc => '0', dec => '0', clr => '0', sr => '0', sl => '0');
	I0_component : DFF port map(clk => clk, en => I0_load, d => data(14), q => I0_out);
	I1_component : DFF port map(clk => clk, en => I1_load, d => data(15), q => I1_out);

	OPR : Register_Generic generic map (n => 4) port map(clk => clk, data_in => data(13 downto 10), data_out => opr_out, load => opr_load, inc => '0', dec => '0', clr => '0', sr => '0', sl => '0');
	dec_4 : Generic_Decoder generic map (n => 4) port map(input => OPR_out, output => dec_4_out);
	ALU_Component : ALU port map(input_ready => begin_alu, operation => opr_out, data_in_ac => ac_out, data_in_bus => data(7 downto 0), data_out => alu_out);
	mux_4_component : Mux_4 port map(i0 => data(7 downto 0), i1 => alu_out, i2 => inverter_out, i3 => "00000000", sel => mux_4_sel, output => mux_4_out);
	invert : Inverter port map(data_in => ac_out, data_out => inverter_out);
	AC : Register_Generic generic map (n => 8) port map(clk => clk, data_in => mux_4_out, data_out => ac_out, load => ac_load, inc => ac_inc, dec => '0', clr => ac_clr, sr => ac_sr, sl => ac_sl);
end behavorial;