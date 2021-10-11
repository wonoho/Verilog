`timescale 1ns/1ps
module pre_gen
(
input [0:63]p_hor,
input [0:63]p_ver,
input [0:7] p_point,
input clk,
input rst,
output reg [0:127]pre_sam,
output reg o_valid
);
reg [2:0] state;
reg [2:0] n_state;
reg [0:103] ref;
reg o_planar;
reg o_dc;
reg o_angular;
wire is_done;

integer i;
reg[5:0] mode;
reg[0:9] p_ver_sum;
reg[0:9] p_hor_sum;
reg[0:7] dc_val;
reg signed [0:3] idx;
reg[0:4] ifact;
wire o_done;
reg signed [0:6] angle;
reg signed [0:14]inv_angle;

localparam IDLE=3'b000;
localparam INTRA_PLA=3'b001;
localparam DC=3'b010;
localparam ANG_MODE=3'b011;
localparam DONE=3'b100;



always@(posedge clk,negedge rst) begin
	if(!rst) begin
		state<=IDLE;


	end
	else begin
		state<=n_state;


	end


end

always@(*) begin

	n_state=state;

	case(state)
	IDLE:begin
			n_state=INTRA_PLA;
			o_valid=1'b0;
			mode='b0;
	end
	INTRA_PLA:
	begin

			n_state=DC;
			o_valid=1'b1;

	end
	DC:
	begin
			n_state=ANG_MODE;
			o_valid=1'b1;

	end
	ANG_MODE:
	begin
		o_valid=1'b1;
		if(is_done) begin
			n_state=DONE;
		end


	end
	DONE: begin
		n_state=IDLE;


	end
	default: begin
		o_valid=1'bx;
		mode='bx;


	end



	endcase
end



always@(posedge clk) begin
 o_planar<=(state==INTRA_PLA)&(mode==0);
 o_dc<=(state==DC)&(mode==1);
 o_angular<=(state==ANG_MODE);
end

assign o_done=(state==DONE);
assign is_done=(mode==34)&(o_valid);







always@(*) begin
	if(mode==2) begin 
			angle= 32;
		    end
	 if(mode==3) begin 
	    		angle= 26;
	    	end
	 if(mode==4) begin 
	    		angle= 21;
	        end
	 if(mode==5) begin 
	    		angle= 17;
	        end
	 if(mode==6) begin 
	    		angle= 13;
	        end
	 if(mode==7) begin 
	    		angle= 9;
	        end
	 if(mode==8) begin 
	    		angle= 5;
	        end
	 if(mode==9) begin 
	    		angle= 2;
	        end

	 if(mode==10) begin 
	    		angle= 0;
	        end
	 if(mode==11) begin 
	    		angle= -2;
	        end
	 if(mode==12) begin 
	    		angle= -5;
	        end
	  if(mode==13) begin 
	    		angle= -9;
	        end
	 if(mode==14) begin 
	    		angle= -13;
	        end
	 if(mode==15) begin 
	    		angle= -17;
	        end
	 if(mode==16) begin 
	    		angle= -21;
	        end
	 if(mode==17) begin 
	    		angle= -26;
	        end
	 if(mode==18) begin 
	    		angle= -32;
	        end
	 if(mode==19) begin 
	    		angle= -26;
	        end
	 if(mode==20) begin 
	    		angle= -21;
	        end
	 if(mode==21) begin 
	    		angle= -17;
	        end
	 if(mode==22) begin 
	    		angle= -13;
	        end
	 if(mode==23) begin 
	    		angle= -9;
	        end
	 if(mode==24) begin 
	    		angle= -5;
	        end
	 if(mode==25) begin 
	    		angle= -2;
	        end
	 if(mode==26) begin 
	    		angle= 0;
	        end
	 if(mode==27) begin 
	    		angle= 2;
	        end
	 if(mode==28) begin 
	    		angle= 5;
	        end
	 if(mode==29) begin 
	    		angle= 9;
	        end
	 if(mode==30) begin 
	    		angle= 13;
	        end
	 if(mode==31) begin 
	    		angle= 17;
	        end
	 if(mode==32) begin 
	    		angle= 21;
	        end
	 if(mode==33) begin 
	    		angle= 26;
	        end
	 if(mode==34) begin 
				angle= 32;
		    end
	
	    end








always@(posedge clk,negedge rst) begin
	if(!rst) begin
		mode<='b0;


	end
	else if(o_valid) begin
		mode<=mode+1;


	end



end

always@(posedge clk) begin
		p_hor_sum=0;
		p_ver_sum=0;
		for(i=0;i<4;i=i+1)
		begin
			p_hor_sum=p_hor_sum+p_hor[i*8+:8];
			p_ver_sum=p_ver_sum+p_ver[i*8+:8];

		end

end
always@(*) begin
	if(mode==1) 
		dc_val=(p_hor_sum+p_ver_sum+4)>>3;
	else if(mode>=2 && mode<18) 
		ref={p_ver[24:31],p_ver[16:23],p_ver[8:15],p_ver[0:7],p_point,p_hor[0:63]};
	else if(mode>=18 && mode<35) 
		ref={p_hor[24:31],p_hor[16:23],p_hor[8:15],p_hor[0:7],p_point,p_ver[0:63]};
	else begin
		dc_val='bx;
		ref='bx;
	end


end

always@(posedge clk) begin

	if(mode==0) begin
		for(i=0;i<16;i=i+1)
		begin
			
				pre_sam[i*8+:8]<=((3-(i%4))*p_hor[(i/4)*8+:8]+(i%4+1)*p_ver[32:39]+(3-(i/4))*p_ver[(i%4)*8+:8]+(i/4+1)*p_hor[32:39]+4)>>3;


		end
	end
	else if(mode==1) begin
		pre_sam[0:7]<=(p_hor[0:7]+2*dc_val+p_ver[0:7]+2)>>2;
		for(i=1;i<16;i=i+1)
		begin
			if((i/4)==0)
			pre_sam[i*8+:8]<=(p_ver[(i%4)*8+:8]+3*dc_val+2)>>2;
			else if((i%4)==0)
			pre_sam[i*8+:8]<=(p_hor[(i/4)*8+:8]+3*dc_val+2)>>2;
			else
			pre_sam[i*8+:8]<=dc_val;


		end


	end
	else begin
		if(mode>=2 && mode<18) begin
			for(i=0;i<16;i=i+1) begin
				idx=((i%4+1)*angle)>>5;
				ifact=((i%4+1)*angle)&31;
				if(!ifact)
				pre_sam[i*8+:8]<=ref[(idx+5+(i/4))*8+:8];
				else
				pre_sam[i*8+:8]<=((32-ifact)*ref[(idx+5+(i/4))*8+:8]+ifact*ref[(idx+6+(i/4))*8+:8]+16)>>5;
			        


			end
		end

		else begin
			for(i=0;i<16;i=i+1) begin
				idx=((i/4+1)*angle)>>5;
				ifact=((i/4+1)*angle)&31;
				if(!ifact)
				pre_sam[i*8+:8]<=ref[(idx+5+(i%4))*8+:8];
                                else
				pre_sam[i*8+:8]<=((32-ifact)*ref[(idx+5+(i%4))*8+:8]+ifact*ref[(idx+6+(i%4))*8+:8]+16)>>5;


			end
		end
	end

	


end






endmodule


