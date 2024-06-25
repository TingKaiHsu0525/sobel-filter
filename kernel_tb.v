`timescale 1ns/1ns

//module sobel_testbench();
module kernel_tb;

reg [7:0] In0, In1, In2, In3, In4, In5, In6, In7;
wire result;



parameter cycle = 5;
parameter row_size = 512;
parameter column_size = 512;

reg rstn, clk;
reg [7:0] mem0 [0:(row_size*column_size)-1];
reg  mem1 [0:(row_size*column_size)-1];
reg [7:0]data;

integer i,j,Up,Mid,Down;
integer  p;
integer handle1;

// Hints !!!!
// design and let input only needed 3x3 pixels when clock rising to the sobel_fillter moudle
// after process you will get 1 pixel output
// inside the module you need to design a 3x3 inner product with sobel parameters


//sobel_fillter UUT ( xxxxxxxxxx  );

kernel  m0 (
                    .clk(clk), .result(result),
                    .In0(In0), .In1(In1), .In2(In2), .In3(In3), .In4(In4), .In5(In5),. In6(In6), .In7(In7)
                    );


initial
begin
    clk = 1'b0;
	forever
		#5 clk = ~clk;
end

//initial the mem
initial begin
	$readmemh("lena_gray.txt", mem0);
	$readmemh("zero512.txt", mem1);
end

initial begin
//setup the threshold  
rstn = 1'b1;
data = 8'd0;
end

reg done=1'b0;

always @ (negedge rstn)
    begin
        if(~rstn)
            begin
                $readmemh("lena_gray.txt", mem0);
                $readmemh("zero512.txt", mem1);
            end
    end


//calculate
initial begin
	$readmemh("lena_gray.txt", mem0);
    $readmemh("zero512.txt", mem1);
	#5
	p = 0;

	for (i=1; i<510; i=i+1) begin // 1:510
		for (j=1; j<510 ; j=j+1) begin
			
			Up=(i-1)*row_size;
			Mid=i*row_size;
			Down=(i+1)*row_size;
			
			//middle: mem0[i*row_size+j]
			In0 = mem0[Up+j-1];
			In1 = mem0[Up+j];
			In2 = mem0[Up+j+1];

			In3 = mem0[Mid+j-1];
			In4 = mem0[Mid+j+1];
			
			In5 = mem0[Down+j-1];
			In6 = mem0[Down+j];
			In7 = mem0[Down+j+1];

			#5
			mem1[Mid+j] = result;
			#5;

		end
	end

	#10;
	handle1 = $fopen("sobel_out.txt","w");

	for(p=0; p< row_size*column_size; p=p+1) begin
		data = (mem1[p]) ? 8'hFF : 8'h00;

		$fwrite(handle1,"%h ", data);

		if ( (p % 512) == 511) begin
				$fwrite(handle1,"\n");
		end
	end

	$fclose(handle1);
	#10
	$stop;

end


endmodule

