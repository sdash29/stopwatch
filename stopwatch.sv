module stopwatch(input logic MAX10_CLK1_50,
                 input logic[1:0] KEY,
					  input logic[9:0] SW,
					  output logic [9:0] LEDR,
                 output logic[7:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
			
logic rst,clkn,run,clk;
logic[8:0] second, minute,hour;
assign rst=!KEY[0];
fsm f0(MAX10_CLK1_50, KEY[1:0],rst,run);

clockdiv(MAX10_CLK1_50,rst,!KEY[1],clkn);
assign LEDR=run;


always_ff @(posedge clkn,posedge rst) begin
 if(rst) begin
 second<=0;
 minute<=0;
 hour<=0;
 end
 
 else begin
 
 if(run) begin
 if(second==59) begin
   second<=0;
	if(minute==59) begin
	 minute<=0;
	 
	 if(hour==23)hour<=0;
	 else hour<=hour+1;
	end
	
	else minute<=minute+1;
 end
 
 else second<=second+1;
 end
 
 else 
 second<=second;
 end
 
end

sevenseg u5(hour[7:0]/10,HEX5);
sevenseg u4(hour[7:0]%10,HEX4);
sevenseg u3(minute[7:0]/10,HEX3);
sevenseg u2(minute[7:0]%10,HEX2);
sevenseg u1(second[7:0]/10,HEX1);
sevenseg u0(second[7:0]%10,HEX0);
endmodule

module fsm(input logic clk,
           input logic[1:0] KEY,
           input logic rst,
           output logic run);

//fsm start

typedef enum logic[1:0]{s0,s1,s2}
statetype;
statetype presentstate,nextstate;
logic prev, press;
assign press = prev&!KEY[1];

//output 
always_comb begin
run=1;
 case(presentstate) 
  s0:run=0;
  s1:run=1;
  s2:run=0;
  default: run=1;
 endcase
end

//state transition
always_comb begin
 nextstate=presentstate;
 case(presentstate) 
 s0: begin
 if(press) nextstate=s1;
 else nextstate=s0;
 end
 
 s1: begin
 if(press) nextstate=s2;
 else nextstate=s1;
 end
 
 s2: begin
 if(press) nextstate=s1;
 else nextstate=s2;
 end
 
 default: nextstate=s0;
 endcase
end

always_ff @(posedge clk) begin
prev<=KEY[1];
if(rst)
presentstate<=s0;
else
presentstate<=nextstate;
end
//fsm end	
endmodule

module clockdiv(input logic clk,reset,start,
                output logic clk_out);
					 
logic[32:0] counter;

always_ff @(posedge clk,posedge reset) begin
 
 if(reset) begin
 counter<=0;
  clk_out<=0;
  end
 else if(counter==25000000)begin
    counter<=0;
	 clk_out<=~clk_out; 
  end
 else begin
   counter<=counter+1;
 end

end	
			
endmodule

module sevenseg(input logic[3:0] data,
                output logic[7:0] segments);
 always_comb
 case(data)
 //gfe_dcfa
 4'h0: segments =8'b11000000;
 4'h1: segments =8'b11111001;
 4'h2: segments =8'b10100100;
 4'h3: segments =8'b10110000;
 4'h4: segments= 8'b10011001;
 4'h5: segments= 8'b10010010;
 4'h6: segments= 8'b10000010;	
 4'h7: segments= 8'b11111000;	
 4'h8: segments= 8'b10000000;
 4'h9: segments= 8'b10011000;
 
 default: segments= 7'b1111111;
 endcase
				
endmodule			