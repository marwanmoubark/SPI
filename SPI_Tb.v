`timescale 1ns / 1ps

module SPI_Top_tb();

    reg clk, reset, tx_start;
    reg [7:0] master_tx_data, slave_tx_data;
    wire [7:0] master_rx_data, slave_rx_data;
    
    
    wire SS_n_sim, SCLK_sim, MISO_sim, MOSI_sim ,data_valid_sim;

    SPI_Top DUT (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .master_tx_data(master_tx_data),
        .slave_tx_data(slave_tx_data),
        .master_rx_data(master_rx_data),
        .slave_rx_data(slave_rx_data),
        .data_valid_sim(data_valid_sim),
        .SS_n_sim(SS_n_sim),
        .SCLK_sim(SCLK_sim),
        .MISO_sim(MISO_sim),
        .MOSI_sim(MOSI_sim)
    );
    
    always #5 clk = ~clk;

    task spi_transaction(input [7:0] master_sent, input [7:0] slave_sent);
        begin
            $display("\n--- Starting Transaction: Master sends %h, Slave sends %h ---", master_sent, slave_sent);
            
            master_tx_data = master_sent;
            slave_tx_data = slave_sent;

           @(posedge clk);
            wait (SS_n_sim == 1);
            #00;

            tx_start = 1;
            @(posedge clk);
            tx_start = 0;
            
        fork
            begin : timeout
                #5000;
                $display("ERROR: Timeout waiting for rx_valid");
                disable wait_rx;
            end
            begin : wait_rx

                @(posedge data_valid_sim);
                @(posedge clk);
                disable timeout;
            end
        join

            if (master_rx_data === slave_sent) begin
                $display("PASS: Master received correct data. Got %h, Expected %h", master_rx_data, slave_sent);
            end else begin
                $display("FAIL: Master received incorrect data. Got %h, Expected %h", master_rx_data, slave_sent);
            end

            if (slave_rx_data === master_sent) begin
                $display("PASS: Slave received correct data. Got %h, Expected %h", slave_rx_data, master_sent);
            end else begin
                $display("FAIL: Slave received incorrect data. Got %h, Expected %h", slave_rx_data, master_sent);
            end

            #50;
        end
    endtask

    initial begin

        clk = 0; reset = 1; tx_start = 0;
        master_tx_data = 8'h00; slave_tx_data = 8'h00;

        #20 reset = 0;
        #20;

        spi_transaction(8'h5A, 8'h5A);
        spi_transaction(8'h00, 8'hFF);
        spi_transaction(8'hFF, 8'h00);
        spi_transaction(8'h12, ~8'h12);
        $display("\n--- Starting Random Data Transactions ---");
        repeat (3) begin
            spi_transaction($random, $random);
        end

        $display("\n--- All tests completed. Finishing simulation. ---");
        #100 $finish;
    end

endmodule
