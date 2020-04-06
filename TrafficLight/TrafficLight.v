/*
Autor: Jack0v
State machine that implements the logic of the a trafficlights.
Source video: https://youtu.be/cyX45Y37nOs
	!!!WARNING!!!
	This project was tested for EP4CE6E22C8 by QurtusII 9.1SP2.
	Before compiling, specify the pins of the your FPGA. Example:
	//(*chip_pin = "11"*) input anB
*/
/*
Автор: Jack0v
Автомат реализующий логику работы светофора.
Исходное видео: https://youtu.be/cyX45Y37nOs
	!!!ВНИМАНИЕ!!!
	Этот проект тестировался под EP4CE6E22C8 в QurtusII 9.1SP2.
	Перед компиляцией укажи выводы своей ПЛИС. Пример:
	//(*chip_pin = "11"*) input anB
*/
//(C) Jack0v, 2020
module TrafficLight((*chip_pin = "00"*)output nRQ,
					(*chip_pin = "00"*)output nEQ,
					(*chip_pin = "00"*)output nGQ,
					(*chip_pin = "00"*)output nTY,
						(*chip_pin = "00"*) input anB,
							(*chip_pin = "00"*) input C);

	//делитель частоты
	reg [23:0]CTCQ;
	reg C1_5HzQ;
	always @(posedge C)
	begin
		CTCQ <= CTCQ + 1'd1;
		if(&CTCQ[22:0]) begin C1_5HzQ <= !C1_5HzQ; end
	end

	//УУ
	wire R_GY, S_GY, R_EY, S_EY, R_RY, S_RY, R_CTY, INC_CTY, R_BY;
	CD CD(	//управляющие сигналы
			.R_GY(R_GY), .S_GY(S_GY),
			.R_EY(R_EY), .S_EY(S_EY),
			.R_RY(R_RY), .S_RY(S_RY),
			.R_CTY(R_CTY), .INC_CTY(INC_CTY),
			.R_BY(R_BY),
				//осведомительные сигналы
				.B(TFrontBQ),
				.CTEq0(~|CTQ), .CTEq1(CTQ == 5'd1), .CTEq4(CTQ == 5'd4), .CTEq15(CTQ == 5'd15),
					.C(C1_5HzQ));

	reg B0Q, B1Q, TFrontBQ; reg [4:0]CTQ;
	reg GQ, EQ, RQ;
	always @(posedge C1_5HzQ)
	begin
		//Запоминание нарастающего фронта
		B0Q <= !anB;
		B1Q <= B0Q;
		if(R_BY) begin TFrontBQ <= 0; end
			else begin if(B0Q & !B1Q) begin TFrontBQ = 1'd1; end end
		//Зелёный
		if(R_GY) begin GQ <= 0; end
			else begin if(S_GY) begin GQ <= 1'd1; end end
		//Жёлтый
		if(R_EY) begin EQ <= 0; end
			else begin if(S_EY) begin EQ <= 1'd1; end end
		//Красный
		if(R_RY) begin RQ <= 0; end
			else begin if(S_RY) begin RQ <= 1'd1; end end
		//СЧ
		if(R_CTY) begin CTQ <= 0; end
			else begin if(INC_CTY) begin CTQ <= CTQ + 1'd1; end end
	end
	assign {nGQ, nEQ, nRQ} = ~{GQ, EQ, RQ};
	assign nTY = ~|CTQ;
endmodule

module CD(	//управляющие сигналы
			output reg R_GY, S_GY,
			output reg R_EY, S_EY,
			output reg R_RY, S_RY,
			output reg R_CTY, INC_CTY,
			output reg R_BY,
				//осведомительные сигналы
				input B,
				input CTEq0, CTEq1, CTEq4, CTEq15,
					input C);

	parameter 	a0 = 0, a1 = 1, a2 = 2, a3 = 3,
				a4 = 4, a5 = 5, a6 = 6, a7 = 7;

	reg [3:0]aY;
	reg [3:0]aQ;
	always @(posedge C) begin aQ <= aY; end
	
	always @*
	begin
		case(aQ)
			a0:
			begin
				aY = a1;
				R_GY	= 0;
				S_GY	= 1'd1;
				R_EY	= 0;
				S_EY	= 0;
				R_RY	= 0;
				S_RY	= 0;
				R_CTY	= 0;
				INC_CTY	= 1'd1;
				R_BY	= 0;
			end
			a1:
			begin
				if(!CTEq0)
				begin
					aY = a1;
					R_GY	= 0;
					S_GY	= 0;
					R_EY	= 0;
					S_EY	= 0;
					R_RY	= 0;
					S_RY	= 0;
					R_CTY	= 0;
					INC_CTY	= 1'd1;
					R_BY	= 0;
				end
					else
					begin
						if(CTEq0)
						begin
							aY = a2;
							R_GY	= 0;
							S_GY	= 0;
							R_EY	= 0;
							S_EY	= 0;
							R_RY	= 0;
							S_RY	= 0;
							R_CTY	= 0;
							INC_CTY	= 0;
							R_BY	= 0;
						end
							else
							begin
								aY = a7;
								R_GY	= 0;
								S_GY	= 0;
								R_EY	= 0;
								S_EY	= 0;
								R_RY	= 0;
								S_RY	= 0;
								R_CTY	= 0;
								INC_CTY	= 0;
								R_BY	= 0;
							end
					end
			end
			a2:
			begin
				if(!B)
				begin
					aY = a2;
					R_GY	= 0;
					S_GY	= 0;
					R_EY	= 0;
					S_EY	= 0;
					R_RY	= 0;
					S_RY	= 0;
					R_CTY	= 0;
					INC_CTY	= 0;
					R_BY	= 0;					
				end
					else
					begin
						if(B & !CTEq4)
						begin
							aY = a3;
							R_GY	= 1'd1;
							S_GY	= 0;
							R_EY	= 0;
							S_EY	= 0;
							R_RY	= 0;
							S_RY	= 0;
							R_CTY	= 0;
							INC_CTY	= 1'd1;
							R_BY	= 0;
						end
							else
							begin
								if(B & CTEq4)
								begin
									aY = a4;
									R_GY	= 1'd1;
									S_GY	= 0;
									R_EY	= 0;
									S_EY	= 1'd1;
									R_RY	= 0;
									S_RY	= 0;
									R_CTY	= 1'd1;
									INC_CTY	= 0;
									R_BY	= 0;
								end
									else
									begin
										aY = a7;
										R_GY	= 0;
										S_GY	= 0;
										R_EY	= 0;
										S_EY	= 0;
										R_RY	= 0;
										S_RY	= 0;
										R_CTY	= 0;
										INC_CTY	= 0;
										R_BY	= 0;
									end
							end
					end
			end
			a3:
			begin
				aY = a2;
				R_GY	= 0;
				S_GY	= 1'd1;
				R_EY	= 0;
				S_EY	= 0;
				R_RY	= 0;
				S_RY	= 0;
				R_CTY	= 0;
				INC_CTY	= 0;
				R_BY	= 0;
			end
			a4:
			begin
				if(!CTEq1)
				begin
					aY = a4;
					R_GY	= 0;
					S_GY	= 0;
					R_EY	= 0;
					S_EY	= 0;
					R_RY	= 0;
					S_RY	= 0;
					R_CTY	= 0;
					INC_CTY	= 1'd1;
					R_BY	= 0;
				end
					else
					begin
						if(CTEq1)
						begin
							aY = a5;
							R_GY	= 0;
							S_GY	= 0;
							R_EY	= 1'd1;
							S_EY	= 0;
							R_RY	= 0;
							S_RY	= 1'd1;
							R_CTY	= 1'd1;
							INC_CTY	= 0;
							R_BY	= 0;
						end
							else
							begin
								aY = a7;
								R_GY	= 0;
								S_GY	= 0;
								R_EY	= 0;
								S_EY	= 0;
								R_RY	= 0;
								S_RY	= 0;
								R_CTY	= 0;
								INC_CTY	= 0;
								R_BY	= 0;
							end
					end
			end
			a5:
			begin
				if(!CTEq15)
				begin
					aY = a5;
					R_GY	= 0;
					S_GY	= 0;
					R_EY	= 0;
					S_EY	= 0;
					R_RY	= 0;
					S_RY	= 0;
					R_CTY	= 0;
					INC_CTY	= 1'd1;
					R_BY	= 0;
				end
					else
					begin
						if(CTEq15)
						begin
							aY = a6;
							R_GY	= 0;
							S_GY	= 0;
							R_EY	= 0;
							S_EY	= 1'd1;
							R_RY	= 0;
							S_RY	= 0;
							R_CTY	= 1'd1;
							INC_CTY	= 0;
							R_BY	= 0;
						end
							else
							begin
								aY = a7;
								R_GY	= 0;
								S_GY	= 0;
								R_EY	= 0;
								S_EY	= 0;
								R_RY	= 0;
								S_RY	= 0;
								R_CTY	= 0;
								INC_CTY	= 0;
								R_BY	= 0;
							end
					end
			end
			a6:
			begin
				aY = a1;
				R_GY	= 0;
				S_GY	= 1'd1;
				R_EY	= 1'd1;
				S_EY	= 0;
				R_RY	= 1'd1;
				S_RY	= 0;
				R_CTY	= 0;
				INC_CTY	= 1'd1;
				R_BY	= 1'd1;
			end
			default:
			begin
				aY = a0;
				R_GY	= 0;
				S_GY	= 0;
				R_EY	= 0;
				S_EY	= 0;
				R_RY	= 0;
				S_RY	= 0;
				R_CTY	= 0;
				INC_CTY	= 0;
				R_BY	= 0;
			end
		endcase
	end
endmodule