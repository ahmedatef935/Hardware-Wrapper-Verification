`timescale 1ns / 1ps
`include "cde.v"
`include "FSM.v"

module Top_level(
    input clk,
    input go,
    input rst,
    input [127:0] master_key,
    input [127:0] account,
    input [127:0] password,
    input [255:0] data_flash,
    input [3:0]   max_address,
    output[127:0] password_enc,
    output [255:0] write_data_flash,
    output [3:0] add_flash,
    output done,
    output flash_write,
    output boot_done_signal
    );
      
    wire flash_pass_reg, flash_acc_reg,flash_or_acc_reg;
    wire flash_or_acc_sel, pass_enc_reg,new_old_pass_sel;
    wire plain_reg, local_master_reg, local_master_sel;
    wire out_reg, write_en, boot_lood,match,ready_encryption;
    wire [3:0] write_add;
    wire start_dec,dec_done,start_enc,cam_start;
    cde L1( .clk(clk),
            .rst(rst),
            .cam_start(cam_start),
            .pass(password),
            .master_key (master_key),
            .account(account),
            .start_dec(start_dec),
            .dec_done(dec_done),
            .start_enc(start_enc),
            .data_flash(data_flash),
            .flash_pass_reg(flash_pass_reg),
            .flash_acc_reg(flash_acc_reg),
            .flash_or_acc_reg(flash_or_acc_reg),
            .flash_or_acc_sel(flash_or_acc_sel),
            .pass_enc_reg(pass_enc_reg),
            .new_old_pass_sel(new_old_pass_sel),
            .plain_reg(plain_reg),
            .local_master_reg(local_master_reg),
            .local_master_sel(local_master_sel),
            .out_reg(out_reg),
            .write_en(write_en),
            .write_add(write_add),
            .boot_lood(boot_lood),
            .match(match),
            .ready_encryption(ready_encryption),
            .write_data_flash(write_data_flash),
            .add_flash(add_flash),
            .final_output(password_enc)
            );

    FSM  L2(
                .clk(clk),
                .rst(rst),
                .match(match),
                .go(go),
                .enc_done(ready_encryption),
                .max_add(max_address),
                .cam_start(cam_start),
                .start_enc(start_enc),
                .boot_load_reg(boot_lood),
                .cam_write_en(write_en),
                .flash_write_en(flash_write),
                .flash_or_acc_sel(flash_or_acc_sel),
                .flash_or_acc_reg(flash_or_acc_reg),
                .pass_enc_reg(pass_enc_reg),
                .new_old_pass_sel(new_old_pass_sel),
                .plain_reg(plain_reg),
                .out_reg(out_reg),
                .start_dec(start_dec),
                .dec_done(dec_done),
                .flash_acc_reg(flash_acc_reg),
                .flash_pass_reg(flash_pass_reg),
                .local_master_sel(local_master_sel),
                .local_master_reg(local_master_reg),
                .done(done),
                .address_out(write_add), //da el address ele mtwsl b flash w cam f nafs el wa2t
                .boot_done_signal(boot_done_signal)
            );


endmodule