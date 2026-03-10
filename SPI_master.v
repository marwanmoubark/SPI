`timescale 1ns / 1ps
module SPI_master #(
    parameter SYS_FREQ = 100_000_000,
    parameter SCLK_FREQ = 10_000_000
)(
    input           clk,
    input           reset,

    input           tx_start,
    input           MISO,
    input  [7:0]    tx_data,

    output reg      MOSI,
    output          SCLK,
    output reg      rx_valid,
    output reg [7:0] rx_data,
    output reg      SS_n
);
// One-hot encoding 
localparam IDLE  = 4'b0001;
localparam START = 4'b0010;
localparam DATA  = 4'b0100;
localparam STOP  = 4'b1000;

    reg [2:0] C_state, N_state;

    reg [7:0] MOSI_shift_reg;
    reg [7:0] MISO_shift_reg;

    reg [3:0] bit_counter; 
    wire SCLK_reg;
    assign SCLK = SCLK_reg;

    SPI_CLOCK #(
        .SYS_FREQ (SYS_FREQ),
        .SCLK_FREQ (SCLK_FREQ)
    ) u_SPI_CLOCK (
        .clk   (clk),
        .reset (reset),
        .enable(~SS_n),
        .SCLK  (SCLK_reg)
    );

    always @(*) begin
        case (C_state)
            IDLE : N_state = tx_start ? START : IDLE ;

            START: N_state = (SS_n) ? IDLE : DATA;

            DATA : N_state = (bit_counter == 4'd9) ? STOP : DATA;

            STOP : N_state = IDLE;

            default: N_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            C_state        <= IDLE;
            SS_n           <= 1'b1;
            rx_valid       <= 1'b0;
            MOSI           <= 1'b0;
            bit_counter    <= 4'd1;
            MOSI_shift_reg <= 8'b0;
            MISO_shift_reg <= 8'b0;
        end else begin
            C_state <= N_state;

            case (C_state)
                IDLE: begin
                    rx_valid       <= 1'b0;
                    if (~tx_start) begin
                        SS_n           <= 1'b1;
                        MOSI_shift_reg <= 8'b0; 
                        MISO_shift_reg <= 8'b0;
                        bit_counter    <= 4'd1;
                        //MOSI           <= 1'b0;
                    end
                    else SS_n           <= 1'b0;
                end

                START: begin
                    MOSI_shift_reg <= tx_data;  
                    MISO_shift_reg <= 8'b0;

                end

                DATA: begin
                end

                STOP: begin
                    SS_n     <= 1'b1;
                    rx_valid <= 1'b1;
                    rx_data <= MISO_shift_reg; 
                end
            endcase
        end
    end

    always @(posedge SCLK_reg) begin
        if (C_state == DATA) begin
            MISO_shift_reg <= { MISO , MISO_shift_reg[7:1]};
        end
    end

    always @(negedge SCLK_reg) begin
        if (C_state == DATA) begin
            bit_counter <= bit_counter + 1'b1;
                if (bit_counter == 4'd9) begin 
                    MOSI <= 1'b0;
                end

                else MOSI <= MOSI_shift_reg[bit_counter];

        end
    end
    always @(negedge SS_n) begin
        MOSI = tx_data[0];
    end

endmodule
