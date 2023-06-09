/*
------Mix Column Module------
input : 
	1- in -128 bit wire- (state)
output : 
	1- out -128 bit register- (output)
Description :
	- the module consists of 7 functions, one in which it multiplies by 2, 
	  the 2nd one multiplies by 3 (using modular arithmetic), the 3rd one
	  multiplies and adds with [02 03 01 01] over GF(2^8), the 4th one
	  multiplies and adds with [01 02 03 01] over GF(2^8), the 5th one
	  multiplies and adds with [01 01 02 03] over GF(2^8), the 6th one
	  multiplies and adds with [03 01 01 02] over GF(2^8), the last one
	  is the output matrix
*/



 `timescale 1ns / 1ps

module inv_Mix_Column(input wire[127:0]in, output reg[127:0]out1);
wire [127:0]out;
  
  function [7:0] mul_2(input [7:0] byteg);  // multiply by 2 "x" 
    begin 
	 


      if(byteg[7]==1'b0)		// if MSB = 0, SLL by 1
        mul_2 = byteg<<1;
      else
        mul_2 = (byteg<<1)^(8'h1b); // if MSB = 1, SLL by 1 XOR 1B
		 
    end
	 
  endfunction

function [7:0] mul_4(input [7:0] byteg); 
    begin
	
      mul_4=mul_2(mul_2(byteg));
			
    end
  endfunction

  
   function [7:0] mul_8(input [7:0] byteg);  // multiply by 4 "x^2" 
    begin 
	 
      mul_8=mul_2(mul_4(byteg));
		
    end
  endfunction


  
  function [7:0] mul_9(input [7:0] byteg);  // multiply by 9 "x^3+1" 
    begin 
       
        mul_9 = mul_8(byteg)^byteg;
		
    end
  endfunction
  
  function [7:0] mul_11(input [7:0] byteg);  // multiply by 11 "x^3+x+1" 
    begin 
      
        mul_11 = mul_9(byteg)^mul_2(byteg);
		  
    end
  endfunction

  function [7:0] mul_13(input [7:0] byteg);  // multiply by 13 "x^3+x^2+1" 
    begin 
   
        mul_13 =  mul_9(byteg)^mul_4(byteg);

    end
  endfunction
  
  function [7:0] mul_14(input [7:0] byteg);  // multiply by 13 "x^3+x^2+x" 
    begin 
      
        mul_14 = mul_2(byteg)^mul_4(byteg)^mul_8(byteg);
	
    end
  endfunction


  function [7:0] mix_column0(input [31:0] word); 	// 1st matrix's column 
    begin
	
      mix_column0 = mul_9(word[7:0])^mul_13(word[15:8])^mul_11(word[23:16])^mul_14(word[31:24]); // multiplying and adding with [0E 0B 0D 09] over GF(2^8)

	 end
  endfunction

  function [7:0] mix_column1(input [31:0] word);	// 2nd matrix's column 
    begin
      mix_column1 = mul_13(word[7:0])^mul_11(word[15:8])^mul_14(word[23:16])^mul_9(word[31:24]); // multiplying and adding with [09 0E 0B 0D] over GF(2^8)
    end
  endfunction

  function [7:0] mix_column2(input [31:0] word);	// 3rd matrix's column 
    begin
      mix_column2 = mul_11(word[7:0])^mul_14(word[15:8])^mul_9(word[23:16])^mul_13(word[31:24]);  // multiplying and adding with [0D 09 0E 0B] over GF(2^8)
    end
  endfunction

  function [7:0] mix_column3(input [31:0] word);	// 4th matrix's column 
    begin
      mix_column3 = mul_14(word[7:0])^mul_9(word[15:8])^mul_13(word[23:16])^mul_11(word[31:24]); // multiplying and adding with [0B 0D 09 0E] over GF(2^8)
   end
  endfunction

  function [0:31] mix_column(input [0:31] word);	// output matrix 
    begin
	
      mix_column = {mix_column0(word),mix_column1(word),mix_column2(word),mix_column3(word)};
	
    end
  endfunction

assign out = {mix_column(in[127:96]), mix_column(in[95:64]), mix_column(in[63:32]), mix_column(in[31:0])};
always@*
begin
out1=out;
end
endmodule


//
//128'h7cf22bab6b30767701fe7b6f0763c567

//
//128'h7cf22bab6b30767701fe7b6f0763c567
