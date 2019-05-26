module sram_array_k3
#(
    parameter KER_SIZE = 3,
    parameter DW       = 32, // Data width (nbits)
    parameter NW       = 32, // Number of words
    parameter AW       = $clog2(NW)
)
(
    input logic clk,
    input logic rstn,
    input logic [AW-1:0] a, // same for read and write    
    input logic [KER_SIZE-1:0] wen, // active high
    input logic [KER_SIZE-1:0] ren, // active high
    input logic [DW-1:0] d,
    output logic [(KER_SIZE-1)*DW-1:0] q
);

logic [DW-1:0] q_wire [KER_SIZE-1:0];
logic [KER_SIZE-1:0] write_en_D1;

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        write_en_D1 <= '0;
    end
    else begin
        write_en_D1 <= wen;
    end
end

genvar i;
generate
    for (i = 0; i < (KER_SIZE); i++) begin
        array #(
            .DW (DW),
            .NW (NW),
            .AW (AW)
        ) sram_inst (
            .clk (clk),
            .cen (!(wen[i] || ren[i])),
            .gwen (!(wen[i])),
            .a (a),
            .d (d),
            .q (q_wire[i])
        );
    end
endgenerate

// reorder rows
always_comb begin
    case (1'b1)
        write_en_D1[0] : q = {q_wire[2],q_wire[1]};
        write_en_D1[1] : q = {q_wire[0],q_wire[2]};
        write_en_D1[2] : q = {q_wire[1],q_wire[0]};
        default :        q = '0;
    endcase
end

endmodule

module sram_array_k5
#(
    parameter KER_SIZE = 5,
    parameter DW = 32, // Data width (nbits)
    parameter NW = 32, // Number of words
    parameter AW = $clog2(NW)
)
(
    input logic clk,
    input logic rstn,
    input logic [AW-1:0] a, // same for read and write    
    input logic [KER_SIZE-1:0] wen, // active high
    input logic [KER_SIZE-1:0] ren, // active high
    input logic [DW-1:0] d,
    output logic [(KER_SIZE-1)*DW-1:0] q
);

logic [DW-1:0] q_wire [KER_SIZE-1:0];
logic [KER_SIZE-1:0] write_en_D1; // delayed write enable because of 1 cycle delay of sram

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        write_en_D1 <= '0;
    end
    else begin
        write_en_D1 <= wen;
    end
end

genvar i;
generate
    for (i = 0; i < (KER_SIZE); i++) begin
        array #(
            .DW (DW),
            .NW (NW),
            .AW (AW)
        ) sram_inst (
            .clk (clk),
            .cen (!(wen[i] || ren[i])),
            .gwen (!(wen[i])),
            .a (a),
            .d (d),
            .q (q_wire[i])
        );
    end
endgenerate

// reorder rows
always_comb begin
    case (1'b1)
        write_en_D1[0] : q = {q_wire[4],q_wire[3],q_wire[2],q_wire[1]};
        write_en_D1[1] : q = {q_wire[0],q_wire[4],q_wire[3],q_wire[2]};
        write_en_D1[2] : q = {q_wire[1],q_wire[0],q_wire[4],q_wire[3]};
        write_en_D1[3] : q = {q_wire[2],q_wire[1],q_wire[0],q_wire[4]};
        write_en_D1[4] : q = {q_wire[3],q_wire[2],q_wire[1],q_wire[0]};
        default :        q = '0;
    endcase
end

endmodule

module sram_array_k2
#(
    parameter KER_SIZE = 3,
    parameter DW = 32, // Data width (nbits)
    parameter NW = 32, // Number of words
    parameter AW = $clog2(NW)
)
(
    input logic clk,
    input logic rstn,
    input logic [AW-1:0] a, // same for read and write
    input logic [KER_SIZE-1:0] wen, // active high
    input logic [KER_SIZE-1:0] ren, // active high
    input logic [DW-1:0] d,
    output logic [(KER_SIZE-1)*DW-1:0] q
);

logic [DW-1:0] q_wire [KER_SIZE-1:0];
logic [KER_SIZE-1:0] write_en_D1;

always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        write_en_D1 <= '0;
    end
    else begin
        write_en_D1 <= wen;
    end
end

genvar i;
generate
    for (i = 0; i < (KER_SIZE); i++) begin
        array #(
            .DW (DW),
            .NW (NW),
            .AW (AW)
        ) sram_inst (
            .clk (clk),
            .cen (!(wen[i] || ren[i])),
            .gwen (!(wen[i])),
            .a (a),
            .d (d),
            .q (q_wire[i])
        );
    end
endgenerate

// reorder rows
always_comb
begin
    case (1'b1)
        write_en_D1[0] : q = {q_wire[1]};
        write_en_D1[1] : q = {q_wire[0]};
        default :        q = '0;
    endcase
end

endmodule

module array
#(
    parameter DW = 32,
    parameter NW = 32,
    parameter AW = 10 
) 
(
    input logic clk,
    input logic cen, // enable active low
    input logic gwen, // global write enable active low
    input logic [AW-1:0] a,
    input logic [DW-1:0] d,
    output logic [DW-1:0] q
);

logic [DW-1:0] data [0:NW-1];

// write
always @(posedge clk) begin
    if (~cen & ~gwen) begin
        data[a] <= d;
    end
    else begin
        data[a] <= data[a];
    end
end

// read
always @(posedge clk) begin
    if (~cen) begin
        q <= data[a];
    end
    else begin
        q <= q;
    end
end

endmodule
