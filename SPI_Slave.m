`timescale 1ns / 1ps
module SPI_Slave(
    input        reset,
    input        SCLK,       
    input        SS_n,       
    input        MOSI,       
    input  [7:0] tx_data,    
    input        data_valid,

    output reg   MISO,      
    output reg [7:0]  rx_data 
);

    reg [7:0] MISO_shift_reg;
    reg [7:0] MOSI_shift_reg;
    reg [3:0] bit_counter;

    always @(negedge SS_n or posedge reset) begin
        if (reset) begin
            MISO_shift_reg <= 8'b0;
            MOSI_shift_reg <= 8'b0;
            bit_counter    <= 0;
            MISO           <= 0;
        end else begin
            MISO_shift_reg <= tx_data;
            MOSI_shift_reg <= 8'b0;
            MISO           <= tx_data[0];
            bit_counter    <= 1;
        end
    end


    always @(posedge SCLK) begin
        if (~SS_n) begin
            MOSI_shift_reg <= {MOSI , MOSI_shift_reg[7:1]};
        end
    end

    always @(negedge SCLK) begin
        if (~SS_n) begin
            MISO        <= MISO_shift_reg[bit_counter];
            bit_counter <= bit_counter + 1;

            if (bit_counter == 4'd8)  
                MISO <= 1'b0;
        end
    end

    always @(posedge data_valid) begin
        rx_data <= MOSI_shift_reg;
    end

endmodule
