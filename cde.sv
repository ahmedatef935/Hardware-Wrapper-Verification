`timescale 1ns / 1ps

`include "reg_D.v"
`include "Cam_Top_level.v"
`include "inv_aes.v"
`include "aes.v"


module cde( input clk,
            input rst,
            input cam_start,
            input [127:0] pass,
            input start_dec,
            input start_enc,
            input [127:0] master_key ,
            input [127:0] account,
            input [255:0] data_flash,
            input flash_pass_reg,
            input flash_acc_reg,
            input flash_or_acc_reg,
            input flash_or_acc_sel,
            input pass_enc_reg,
            input new_old_pass_sel,
            input plain_reg,
            input local_master_reg,
            input local_master_sel,
            input out_reg,
            input write_en,
            input [3:0] write_add,
            input boot_lood,
            output match,
            output dec_done,
            output ready_encryption,
            output [255:0] write_data_flash,
            output [3:0] add_flash,
            output [127:0] final_output
    );
    parameter  ADDR_WIDTH =4;
    parameter loacal_key = 128'h00000000000000000000000000000000;
    
    
    wire dec_busy;
    //////////////////////// cam
    wire [127:0] out_flash_or_acc_sel; // choose between data flash or acc from chrom  
    wire [127:0] out_reg_flash_or_acc; // input fot din 
    //////////////////////
    //reg [127:0] reg_flash_account; // latch account in case write in flash 
    wire [127:0] out_reg_flash_account; // output latch 
    //////////////// 
     wire [ADDR_WIDTH-1:0] match_add; // out from cam in case match =1
    //////////////// decryption
    wire [127:0] out_reg_pass_enc;
    wire [127:0] out_decry;
    //////////encryption 
    wire [127:0] out_new_old_pass_sel;
    wire [127:0] out_reg_plain_reg;
     wire [127:0] out_encryption;
    ///////////// master key
    wire [127:0] out_local_master_sel;
    wire [127:0] out_local_master_reg;
    ///////////////
    wire [127:0] out_flash_pass_reg;
    ///////////////
   assign  out_flash_or_acc_sel = (flash_or_acc_sel ) ? account :  data_flash[255:128]   ; // select between data flash  or acc
   assign add_flash = (boot_lood)? match_add :  write_add  ; // select from write add or match_add in case boot or lood from flash in cam
   assign out_new_old_pass_sel = (new_old_pass_sel)? out_decry : pass ;
   assign out_local_master_sel = (local_master_sel)? master_key : loacal_key ;
   assign write_data_flash = { out_reg_flash_account ,out_flash_pass_reg};
   
   ///////////////////////////////////////////////////////////////////////////////////// 
    reg_D reg_flash_or_acc(clk,rst,flash_or_acc_reg,out_flash_or_acc_sel,out_reg_flash_or_acc);
    reg_D reg_flash_account(clk,rst,flash_acc_reg , out_reg_flash_or_acc , out_reg_flash_account);
    reg_D reg_flash_pass( clk ,rst , flash_pass_reg , out_encryption , out_flash_pass_reg);
    reg_D reg_pass_enc(clk,rst,pass_enc_reg , data_flash[127:0] , out_reg_pass_enc);
    reg_D reg_plain_reg (clk , rst , plain_reg , out_new_old_pass_sel  , out_reg_plain_reg );
    reg_D reg_local_master (clk , rst , local_master_reg , out_local_master_sel  , out_local_master_reg );
    reg_D reg_out_reg (clk , rst , out_reg , out_encryption  , final_output );
    /////////////////////////////////////////////////////////////////////////////////
    cam #(

       .DATA_WIDTH(128),
      
        .ADDR_WIDTH(ADDR_WIDTH)
      )
      cam_inst(
         .clk(clk),
         .rst(rst),
         .start(cam_start),
         .write_enable(write_en),
         .din(out_reg_flash_or_acc),
         .write_addr(write_add),
         .match(match),
         .match_addr(match_add)
      ); 
    //////////////////////////////////////////////////////////////////////////
    aes ENC (
        
       .plaintext(out_reg_plain_reg),
       .key(out_local_master_reg),
       .clk(clk),
       .reset(rst),
       .start(start_enc),
       .cipher_text(out_encryption),
       .ready(ready_encryption)
       );
       
       ///////////////////////////////////////
    inv_aes DEC(
        .clk(clk),
        .rest(rst),
        .start(start_dec),
        .plaintext1(out_reg_pass_enc),
        .local_key(loacal_key),
        .cipher_text(out_decry),
        .done(dec_done), 
        .busy(dec_busy)
        );
    /////////////////////////////////////////////////////////////////////////
endmodule