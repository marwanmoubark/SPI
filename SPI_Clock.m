module SPI_CLOCK #(parameter SYS_FREQ = 100000000,SCLK_FREQ = 10000000 )  //SYSTEM FREQUENCY = 50MHZ , SCLK FREQUENCY = 20MHZ ;
(
    input clk,
    input reset, enable, 
    output reg SCLK 
    );

    reg [2:0] CLK_counter ;
    localparam K = SYS_FREQ / (2 * SCLK_FREQ) ; 

    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            SCLK <= 0 ;
            CLK_counter <= 0 ;
        end
        else if(enable) begin
            if (CLK_counter == (K-1)) begin  
            SCLK <= ~SCLK ;
            CLK_counter <= 0 ;
            end
            else CLK_counter <= CLK_counter + 1 ;  
        end
        else SCLK <= 0;
    end
endmodule
