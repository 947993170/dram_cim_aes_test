/*-----------------------------------------------------------------------------------
 AES (128-bit, encryption)
 
 File name   : UART_Interface_Controller.v
 Version     : 2.1
 Created     : 22/04/2020
 Updated     : 11/06/2020
 Desgined by : Kwen-Siong Chong
 
 Copyright (C) 2020 

 Some general information:
 ---------------------------------------------------------------------------------*/

`timescale 1 ns/1 ps 
module UART_Interface_Controller 
#(
parameter Counter_Parameter  = 10416, // Clock Frequency divided by Baudrate

parameter S00 = 4'b0000,
parameter S01 = 4'b0001,
parameter S02 = 4'b0010,
parameter S03 = 4'b0011,
parameter S04 = 4'b0100,
parameter S05 = 4'b0101,
parameter S06 = 4'b0110,
parameter S07 = 4'b0111,
parameter S08 = 4'b1000,
parameter S09 = 4'b1001,
parameter S10 = 4'b1010
)
(//inputs
                                  CLK,
                                  NRST,
                                  RX_UART,
                                  DOUT_AES,
                                  KVLD_AES,
                                  DVLD_AES,
                                  BUSY_AES,
                                  //outputs
                                  TX_UART,
                                  EN_AES,
								  RSTn_AES,
                                  KIN_AES,
								  DIN_AES,
							      KDRDY_AES
							      
							      );
								  
//Baudrate = 9600
//Clck     = 100MHz
//Counter  = 10416;
localparam integer HALF_BIT = Counter_Parameter >> 1;
localparam integer ONE_FOURTH_BIT = Counter_Parameter >> 2;
localparam integer ONE_EIGHTH_BIT = Counter_Parameter >> 3;
localparam integer ONE_SIXTEENTH_BIT = Counter_Parameter >> 4;
localparam integer ONE_32_BIT = Counter_Parameter >> 5;
localparam integer ONE_64_BIT = Counter_Parameter >> 6;
localparam integer ONE_128_BIT = Counter_Parameter >> 7;




 					  
input         CLK;  
(* mark_debug = "true" *) input         NRST;
(* mark_debug = "true" *) input         RX_UART;
input [127:0] DOUT_AES;
input         KVLD_AES;
input         DVLD_AES;
input         BUSY_AES;

output         TX_UART;
output         EN_AES;
output         RSTn_AES;
output [127:0] KIN_AES;
output [127:0] DIN_AES;
output         KDRDY_AES;


(* mark_debug = "true" *) reg         TX_UART;
(* mark_debug = "true" *) reg         EN_AES;
(* mark_debug = "true" *) reg         RSTn_AES;
(* mark_debug = "true" *) reg [127:0] KIN_AES;
(* mark_debug = "true" *) reg [127:0] DIN_AES;
(* mark_debug = "true" *) reg         KDRDY_AES;
reg         KDRDY_AES01;
reg         KDRDY_AES02;
reg         KDRDY_AES03;
reg         KDRDY_AES04;
reg         KDRDY_AES05;

reg         DVLD_AES01;
reg         DVLD_AES02;
reg         DVLD_AES03;
reg         DVLD_AES04;
reg         DVLD_AES05;

(* mark_debug = "true" *) reg [14:0] RX_CLK_Counter;
(* mark_debug = "true" *) reg [ 5:0] RX_Counter; 
(* mark_debug = "true" *) reg [ 3:0] RX_state;
(* mark_debug = "true" *) reg [ 7:0] RX_Header_REG;
reg        RX_UART1;
reg        RX_UART2;
reg [3:0] next_RX_state;


reg [14:0] TX_CLK_Counter;
reg [ 5:0] TX_Counter; 
reg [ 3:0] TX_state;
reg [ 3:0] next_TX_state;
 

/*********************************/
/**** Start of Receiving       ***/
/*********************************/
//RX Syncronizer
always @ (posedge CLK or negedge NRST)
  if (!NRST) 
      begin
        RX_UART1     <= #1 1;
        RX_UART2     <= #1 1;
      end
  else  
      begin
        RX_UART1     <= #1 RX_UART;
        RX_UART2     <= #1 RX_UART1;
      end

//RX CLK Counter
always @ (posedge CLK or negedge NRST)
	if (!NRST)
		RX_CLK_Counter <= 'd0;
	else if (RX_state == S00)
		RX_CLK_Counter <= 'd0;	   
	else if (RX_CLK_Counter == Counter_Parameter)
		if ((RX_state == S10) && (RX_UART2 == 1'b1))
			RX_CLK_Counter <= RX_CLK_Counter;
		else 
			RX_CLK_Counter <= 'd0;
//	else if (RX_state == S01) 
//		if (RX_UART2 == 0) 
//			RX_CLK_Counter <= #1 RX_CLK_Counter + 1;
//		else 
//			RX_CLK_Counter <= #1 RX_CLK_Counter;
//	else if (RX_state == S10)
//		if (RX_UART2 == 1)
//			RX_CLK_Counter <= #1 RX_CLK_Counter + 1;
//		else 
//			RX_CLK_Counter <= #1 RX_CLK_Counter;
	else 
		RX_CLK_Counter <= RX_CLK_Counter + 1;


                	   
//RX Counter
always @ (posedge CLK or negedge NRST)
  if (!NRST)
      RX_Counter     <= #1 0;
  else if (RX_state == S00 )
           RX_Counter <= #1 0;
	   else if ((RX_state == S09) && (RX_CLK_Counter == Counter_Parameter))
		        RX_Counter <= #1 RX_Counter + 1;	   
	        else  
			      RX_Counter <= #1 RX_Counter;


//Capturing the RX Data
always @ (posedge CLK or negedge NRST)
  if (!NRST)
      begin
        RX_Header_REG <= #1 0;
		    KIN_AES    <= #1 0;
		    DIN_AES    <= #1 0;
	    end
//  else if (RX_CLK_Counter == 100)  //Capture the datat at 100th clock 
  else if (RX_CLK_Counter == HALF_BIT)  //Capture the datat at middle
           if (RX_Counter == 0)
               begin 
                 case (RX_state)
			           S02    : RX_Header_REG[0] <= #1 RX_UART2; 
				         S03    : RX_Header_REG[1] <= #1 RX_UART2;
			           S04    : RX_Header_REG[2] <= #1 RX_UART2;
				         S05    : RX_Header_REG[3] <= #1 RX_UART2;
				         S06    : RX_Header_REG[4] <= #1 RX_UART2;
			        	 S07    : RX_Header_REG[5] <= #1 RX_UART2;
				         S08    : RX_Header_REG[6] <= #1 RX_UART2;
				         S09    : RX_Header_REG[7] <= #1 RX_UART2;
				         default: RX_Header_REG    <= #1 RX_Header_REG;
                 endcase
               end	
	        else if ((RX_Counter != 0) & (RX_Counter < 17))   
		                begin
                      case (RX_state)                               
					            S02    : KIN_AES[(RX_Counter - 1)*8]   <= #1 RX_UART2;
				              S03    : KIN_AES[(RX_Counter - 1)*8+1] <= #1 RX_UART2;
			                S04    : KIN_AES[(RX_Counter - 1)*8+2] <= #1 RX_UART2;
				              S05    : KIN_AES[(RX_Counter - 1)*8+3] <= #1 RX_UART2;
				              S06    : KIN_AES[(RX_Counter - 1)*8+4] <= #1 RX_UART2;
			                S07    : KIN_AES[(RX_Counter - 1)*8+5] <= #1 RX_UART2;
			                S08    : KIN_AES[(RX_Counter - 1)*8+6] <= #1 RX_UART2;
				              S09    : KIN_AES[(RX_Counter - 1)*8+7] <= #1 RX_UART2;
				              default: KIN_AES <= #1 KIN_AES;
                      endcase                                   
				           end
				       else 
	                 begin
                     case (RX_state)               
					           S02    : DIN_AES[(RX_Counter - 17)*8]   <= #1 RX_UART2;
				             S03    : DIN_AES[(RX_Counter - 17)*8+1] <= #1 RX_UART2;
				             S04    : DIN_AES[(RX_Counter - 17)*8+2] <= #1 RX_UART2;
				             S05    : DIN_AES[(RX_Counter - 17)*8+3] <= #1 RX_UART2;
				             S06    : DIN_AES[(RX_Counter - 17)*8+4] <= #1 RX_UART2;
				             S07    : DIN_AES[(RX_Counter - 17)*8+5] <= #1 RX_UART2;
				             S08    : DIN_AES[(RX_Counter - 17)*8+6] <= #1 RX_UART2;
				             S09    : DIN_AES[(RX_Counter - 17)*8+7] <= #1 RX_UART2;
				             default: DIN_AES <= #1 DIN_AES;
                     endcase                                              
				           end
	    else
		  begin
        RX_Header_REG <= #1 RX_Header_REG;
		    KIN_AES       <= #1 KIN_AES;
		    DIN_AES       <= #1 DIN_AES;
		  end
 
 
//Generating the Control Signals for AES operation
always @ (negedge CLK or negedge NRST)
  if (!NRST)
      RSTn_AES    <= #1 0;
  else if ((RX_Counter == 1) & (RX_Header_REG[0] == 1))
		       RSTn_AES <= #1 0;
	     else 
           RSTn_AES <= #1 1;
			
always @ (negedge CLK or negedge NRST)
  if (!NRST)
      EN_AES    <= #1 0;
  else if (RX_Counter == 30)
		       EN_AES <= #1 1;
		
always @ (negedge CLK or negedge NRST)
  if (!NRST)
      begin
	    KDRDY_AES01  <= #1 0;
		KDRDY_AES02  <= #1 0;
		KDRDY_AES03  <= #1 0;
		KDRDY_AES04  <= #1 0;
		KDRDY_AES05  <= #1 0;
        KDRDY_AES    <= #1 0;
	  end
  else if (RX_Counter == 33)
           begin
	         KDRDY_AES01  <= #1 1;
		     KDRDY_AES02  <= #1 0;
		     KDRDY_AES03  <= #1 0;
		     KDRDY_AES04  <= #1 0;
		     KDRDY_AES05  <= #1 0;		   
		     KDRDY_AES    <= #1 0;
           end 		   
       else
         begin	   
	       	 KDRDY_AES01  <= #1 0;
		     KDRDY_AES02  <= #1 KDRDY_AES01;
		     KDRDY_AES03  <= #1 KDRDY_AES02;
		     KDRDY_AES04  <= #1 KDRDY_AES03;
		     KDRDY_AES05  <= #1 KDRDY_AES04;		   
		     KDRDY_AES    <= #1 KDRDY_AES05;	
	     end
	
		
		 
// Sequential Logic for the current RX_state logic 
always @ (posedge CLK or negedge NRST)
  if (!NRST)
      RX_state <= #1 S00;
  else
      RX_state <= #1 next_RX_state;
 

// Combinational Logic for the next RX_state logic  
always @ (RX_state or RX_UART2 or RX_CLK_Counter or RX_Counter)
  case (RX_state)
    S00 : begin
            if ((RX_UART2 && RX_UART1 && RX_UART) == 0) //First Check 
                next_RX_state = S01;           
		    else 
			    next_RX_state = S00;
          end
    S01 : begin
            // Validate the start bit at the midpoint of the bit period.  If the
            // serial line has already returned high by HALF_BIT, the start bit
            // was spurious and reception should restart from the idle state.
            if ((RX_CLK_Counter == HALF_BIT) && (RX_UART2 == 1'b1))
                next_RX_state = S00;  // false start bit
            else if (RX_CLK_Counter == Counter_Parameter)
                next_RX_state = S02;  // proceed to data reception
            else
                next_RX_state = S01;  // continue waiting within start bit
          end
    S02 : begin          
	        if (RX_CLK_Counter == Counter_Parameter) // For first Data Bit 
                next_RX_state = S03;
            else 
                next_RX_state = S02;		   
          end
    S03 : begin          
	       if (RX_CLK_Counter == Counter_Parameter) // For Second Data Bit 
               next_RX_state = S04;
           else 
               next_RX_state = S03;		   
          end
    S04 : begin          
	       if (RX_CLK_Counter == Counter_Parameter) // For Third Data Bit 
               next_RX_state = S05;
           else 
               next_RX_state = S04;		   
          end
    S05 : begin          
	       if (RX_CLK_Counter == Counter_Parameter) // For Forth Data Bit 
               next_RX_state = S06;
           else 
               next_RX_state = S05;		   
          end
    S06 : begin          
	       if (RX_CLK_Counter == Counter_Parameter) // For Fifth Data Bit 
               next_RX_state = S07;
           else 
               next_RX_state = S06;		   
         end	
    S07 : begin          
	       if (RX_CLK_Counter == Counter_Parameter) // For Sixth Data Bit 
               next_RX_state = S08;
           else 
               next_RX_state = S07;		   
         end
    S08 : begin          
	       if (RX_CLK_Counter == Counter_Parameter) // For Seventh Data Bit 
               next_RX_state = S09;
           else 
               next_RX_state = S08;		   
         end
    S09 : begin          
	       if ((RX_CLK_Counter == Counter_Parameter)) // For Eighth Data Bit 
               if (RX_Counter == 32)  
                   next_RX_state = S00;
               else 
                   next_RX_state = S10;		 
           else
		     next_RX_state = S09;		
          end		 
    S10 : begin
			if (RX_CLK_Counter == Counter_Parameter)   
                next_RX_state = S01;  //Finish Counting
            else 
                next_RX_state = S10; 	//Must wait until the counting is done		
          end		  
default : begin        
            next_RX_state = S00; 
          end	
  endcase
/*********************************/
/**** End of Receiving         ***/
/*********************************/





/*********************************/
/**** Start of Transmiting     ***/
/*********************************/
//TX CLK Counter
always @ (posedge CLK or negedge NRST)
  if (!NRST)
      TX_CLK_Counter     <= #1 0;
  else if (TX_state == S00)   
		        TX_CLK_Counter <= #1 0;	   
	      else if (TX_CLK_Counter == Counter_Parameter)
                 TX_CLK_Counter <= #1 0;
             else  
			           TX_CLK_Counter <= #1 TX_CLK_Counter + 1;
                	   
//TX Counter
always @ (posedge CLK or negedge NRST)
  if (!NRST)
      TX_Counter <= #1 0;
  else if (TX_state == S00 )
           TX_Counter <= #1 0;
	   else if ((TX_state == S09) && (TX_CLK_Counter == Counter_Parameter))
		           TX_Counter <= #1 TX_Counter + 1;	   
          else  
			         TX_Counter <= #1 TX_Counter;

//Transmtting the TX Data
always @ (posedge CLK or negedge NRST)
  if (!NRST)
      begin
        TX_UART <= #1 1;
	    end
	    
//  else TX_UART <= RX_UART;

  else if (TX_state == S01)
           TX_UART <= #1 0;
       else if ((TX_state == S00) | (TX_state == S10))
                 TX_UART <= #1 1;
             else   
               begin 
                 case (TX_state)
			           S02    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8]; 
				         S03    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8 + 1]; 
			             S04    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8 + 2]; 
				         S05    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8 + 3]; 
				         S06    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8 + 4]; 
			        	 S07    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8 + 5]; 
				         S08    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8 + 6]; 
				         S09    : TX_UART <= #1  DOUT_AES[(TX_Counter)*8 + 7]; 
				         default: TX_UART <= #1  1;
                 endcase
               end	
	  		 
// Sequential Logic for the current RX_state logic 
always @ (posedge CLK or negedge NRST)
  if (!NRST)
      TX_state <= #1 S00;
  else
      TX_state <= #1 next_TX_state;
 

always @ (negedge CLK or negedge NRST)
  if (!NRST)
      begin
	    DVLD_AES01  <= #1 0;
		DVLD_AES02  <= #1 0;
		DVLD_AES03  <= #1 0;
		DVLD_AES04  <= #1 0;
		DVLD_AES05  <= #1 0;
	  end
  else 
      begin 
	    DVLD_AES01  <= #1 DVLD_AES;
		DVLD_AES02  <= #1 DVLD_AES01;
		DVLD_AES03  <= #1 DVLD_AES02;
		DVLD_AES04  <= #1 DVLD_AES03;
		DVLD_AES05  <= #1 DVLD_AES04;
	  end


// Combinational Logic for the next RX_state logic  
always @ (TX_state or DVLD_AES05 or TX_CLK_Counter or TX_Counter)
  case (TX_state)
    S00 : begin
            if ((DVLD_AES05 == 1)) // AES Output available
                next_TX_state = S01;           
		        else 
			          next_TX_state = S00;
          end
    S01 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating START Bit 
                next_TX_state = S02;
            else 
                next_TX_state = S01;		   
          end
    S02 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating First Data Bit 
                next_TX_state = S03;
            else 
                next_TX_state = S02;		   
          end
    S03 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating Second Data Bit 
                next_TX_state = S04;
            else 
                next_TX_state = S03;		   
          end
    S04 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating Third Data Bit 
                next_TX_state = S05;
            else 
                next_TX_state = S04;		   
          end
    S05 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating Forth Data Bit 
                next_TX_state = S06;
            else 
                next_TX_state = S05;		   
          end	
    S06 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating Fifth Data Bit 
                next_TX_state = S07;
            else 
               next_TX_state = S06;		   
          end
    S07 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating Sixth Data Bit 
               next_TX_state = S08;
            else 
               next_TX_state = S07;		   
          end
    S08 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating Sixth Data Bit 
               next_TX_state = S09;
            else 
               next_TX_state = S08;		   
          end
    S09 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Generating Eighth Data Bit 
                if (TX_Counter == 15)  
                    next_TX_state = S00;
                else 
                    next_TX_state = S10;		 
            else
               next_TX_state = S09;		
          end	
    S10 : begin          
	          if (TX_CLK_Counter == Counter_Parameter) // Waiting for next
                next_TX_state = S01;
            else 
                next_TX_state = S10;		   
          end            
default : begin        
            next_TX_state = S00; 
          end	
  endcase
/*********************************/
/**** End of Tranmiting        ***/
/*********************************/



endmodule
