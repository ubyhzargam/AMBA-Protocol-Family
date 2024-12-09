// MASTER
module apb_master(input [8:0] read_addr, write_addr,
                  input [7:0] read_data,wdata,
                  input transfer, pclk, presetn,pready,read, write,
                  output reg [8:0] paddr,
                  output reg [7:0] pwdata,read_data_out,
                  output reg pwrite,penable,
                  output psel1,psel2,
                  output pslverr);
                  
reg setup_error,invalid_setup_error,invalid_read_addr,invalid_write_addr, invalid_write_data;

reg [1:0] ps,ns;

parameter idle=2'b00, setup=2'b01, access=2'b10;

always@(posedge pclk)
begin
if(!presetn)
ps<=idle;
else
ps<=ns;
end

always@(transfer,ps,pready)
begin
if(!presetn)ps<=idle;
else
begin
pwrite=write;
case(ps)
idle : begin penable=0;
       if(!transfer) ns=idle;
       else ns=setup;
       end
setup : begin penable=0;
       if(read==1'b1&&write==1'b0)
       begin
       paddr=read_addr;
       end
       else if(read==1'b0&&write==1'b1)
       begin
       paddr=write_addr;
       pwdata=wdata;
       end
       if(transfer && !pslverr)
       ns=access;
       else
       ns=idle;
       end
access : begin 
         if(psel1||psel2)
         penable=1;
         if(transfer && !pslverr)
         begin
         if(pready)
         begin
         if(read==1'b0 && write ==1'b1)
         ns=setup;
         else if(read==1'b1 && write ==1'b0)
         begin
         ns=setup;
         read_data_out=read_data;
         end
         end
         else
         ns=access;
         end
         else ns=idle;
         end
default : ns=idle;
endcase
end
end

assign {psel1,psel2}=((ps!=idle)?(paddr[8]?({1'b0,1'b1}):({1'b1,1'b0})):(2'd0));
       
always@(*)
begin
if(!presetn)
begin
setup_error=0;
invalid_setup_error=0;
invalid_read_addr=0;
invalid_write_addr=0;
invalid_write_data=0;
end
if(read_addr==9'dx && read==1'b1 && write == 1'b0 && (ps==setup || ps==access))
invalid_read_addr=1;
else
invalid_read_addr=0;
if(write_addr==9'dx && read==1'b0 && write == 1'b1 && (ps==setup || ps==access ))
invalid_write_addr=1;
else
invalid_write_addr=0;
if(wdata==8'dx && read==1'b0 && write == 1'b1 && (ps==setup || ps==access ))
invalid_write_data=1;
else
invalid_write_data=0;
if(ps==idle && ns==access)
setup_error=1;
else
setup_error=0;
if(ps==setup)
begin
if(pwrite)
begin
    if(paddr==write_addr && pwdata==wdata)
    setup_error=0;
    else
    setup_error=1;
end
else if(read)
begin
    if(paddr==read_addr)
    setup_error=0;
    else
    setup_error=1;   
end
end
else setup_error=0;
invalid_setup_error = setup_error | invalid_read_addr | invalid_write_addr | invalid_write_data;
end
assign pslverr=invalid_setup_error;
endmodule


// SLAVE

module slave(input pclk, presetn,pwrite,psel,penable,
             input [7:0] pwdata,paddr,
             output [7:0] prdata,
             output reg pready);
             
reg [7:0] mem[63:0];
reg [7:0] addr;

assign prdata=mem[addr];

always@(*)
begin
if(!presetn)pready=0;
else if(psel && !penable && !pwrite)
pready=0;
else if(psel && penable && !pwrite)
begin
pready=1;
addr=paddr;
end
else if(psel && !penable && pwrite)
pready=0;
else if(psel && penable && pwrite)
begin
pready=1;
mem[addr]=pwdata;
end
else
pready=0;
end
endmodule

// TOP MODULE

module apb_top(input pclk,presetn,transfer,read,write,
               input [8:0] apb_write_paddr, apb_read_paddr,
               input [7:0] apb_write_data,
               output pslverr,
               output [7:0] apb_read_data_out);

wire [7:0] PWDATA,PRDATA,PRDATA1,PRDATA2;
wire [8:0]PADDR;
wire PREADY,PREADY1,PREADY2,PENABLE,PSEL1,PSEL2,PWRITE;

assign PREADY = PADDR[8] ? PREADY2 : PREADY1 ;
  assign PRDATA = (read&&(~write)) ? (PADDR[8] ? PRDATA2 : PRDATA1) : 8'dx ;

  apb_master m(apb_read_paddr, apb_write_paddr,
                  PRDATA,apb_write_data,
                  transfer, pclk, presetn,PREADY,read, write,
                  PADDR,
                  PWDATA,PRDATA,
                  PWRITE,PENABLE,
                  PSEL1,PSEL2,
                  pslverr);
                  
slave s1(pclk, presetn,PWRITE,PSEL1,PENABLE,
             PWDATA,PADDR[7:0],
             PRDATA1,
             PREADY1);
             
slave s2(pclk, presetn,PWRITE,PSEL2,PENABLE,
             PWDATA,PADDR[7:0],
             PRDATA2,
             PREADY2);            

endmodule


             
