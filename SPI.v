module SPI_Top(
    input        clk,
    input        reset,
    input        tx_start,
    input [7:0]  master_tx_data,
    input [7:0]  slave_tx_data,
    
    output [7:0] master_rx_data,
    output [7:0] slave_rx_data,

//     //FOR SIMULATION
  output SS_n_sim ,
  output SCLK_sim ,
  output       data_valid_sim,
  output MISO_sim , MOSI_sim
);

wire MOSI, MISO, SCLK, SS_n;
wire data_valid;

// ----------------- Master ----------------- //
SPI_master master_inst (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),  
    .MISO(MISO),
    .tx_data(master_tx_data),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .rx_valid(data_valid),
    .rx_data(master_rx_data),
    .SS_n(SS_n)
);

// ----------------- Slave ----------------- //
SPI_Slave slave_inst (
    .reset(reset),
    .SCLK(SCLK),
    .SS_n(SS_n),
    .MOSI(MOSI),
    .tx_data(slave_tx_data),
    .MISO(MISO),
    .data_valid(data_valid),
    .rx_data(slave_rx_data)
);
assign SS_n_sim = SS_n;
assign SCLK_sim = SCLK;
assign MISO_sim = MISO;
assign MOSI_sim = MOSI;
assign data_valid_sim = data_valid;


endmodule
