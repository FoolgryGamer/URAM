`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23 20:10:18
// Design Name: 
// Module Name: tb_one_mm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_one_mm#(
    parameter M_SIZE = 3072,
    parameter RADIX = 72,
    parameter SIZE_LOG = 6,
    parameter FIFO_DEPTH = 4,
    parameter FIFO_AddrWidth = 3,
    parameter SIZE_ADD = 128*25,
    parameter URAM_ADDR = 12
)(    );
    reg clk, rst_n, en_pre_me, en_me, en_one_mm;
    reg [M_SIZE-1:0] a,e,m;
    reg [M_SIZE+1:0] m_n;
    reg [RADIX+SIZE_LOG+1:0] m_prime;
    reg [3:0] num;
    wire [3:0] num_out;
    
    wire [M_SIZE-1:0] z;
    wire done;
    
    initial begin
        clk = 0;
        rst_n = 0;
        en_pre_me = 0;
        en_me = 0;
        en_one_mm = 0;
        a = 0;
        e = 0;
        m = 0;
        m_n = 0;
        m_prime = 0;
        #25
        rst_n = 1;
        #10
        a = 3072'h5537b809d650de8821a83a5433a9d61aede0b5920116118d86fb93a8d61ff5a55a3e1a86a9120ba88af0ff4819be8672a58ecbc4400842af1066a7b2e35e526d9ab97bd64db7bff40899184841441aa17a2d7841cf20bc9a5fc943298506d301af280f381f7926c35def357682db8c4db8efe60f0aa935118ab780d2973963903eb6d14bb6540990f80c8061362db2be2bf1cc084dce716c58cca95c5cd0c1b936019cd4759e88ad73f4da76a03fbeef68cb9e02460732361921f86cce6536ba073754de30ed0e06ed36943c5ec050f7ddd4257fbb5af45a6f419c93f11cd49134357a0be4edc9ec3ca2f8b87afa9fa492ab0d79195a0fee32d288531fef019fa0c99c50fed25f253cb31035ef94ecbf2d1565bdc8cc519313cbef7757b04f50f8ca834effd0688af300f3659a9447316b59e67540d31c8be01cb54ecae0e8ca60cf668014db967669e48796ecd0807113b29d0a42eb574f2e554879c44eb5d200585ffbd15b31f5f7a0a3a557a31bc8400bf88f4748907725c7be2d13da5531;
        e = 3072'h671047557606fd8d3be9ad6de0da5da977f72001707d2f9276558975106c3d928f9c32333d51c99e6c89d26daa431f5e1fd01d66526876974bb2fdc8f451fbed67b1dd0cec40a7c924c87656f406e4470d1ae592a469eecccf0e3737eda2b8a8c9c8800bcd5ceb29f184bafdaffc85ee9a59aef2d323debb55e76620f9a3a3748c5635df31e3a1c190a8780677a0dae4a892fa2e2ddda31e0213f3888aff98747a039c2b2bb0900196d1fe1d086a02f7a65155f987bd00f53787c7e8d3adb6439ac0c3b0357ae05c778522188769fde1914aea9f1629383f5677593d1aefe0435a870bfd2afd5fd80183b8b3053f38e2d27a9dec0090b077242c72f4b3179928f6448045e9ed5d7d8c9b0e1f6bdf1fb6ad70a64c601148f84799bba89f81f63c81220518e4cb02fb2cfd634ed0b0d00a2d312fee7e15ca5229e0f0724872b7136e37071d1eadd13f6e6f139fa55b3555df314efeade12a969ec410e54d26a59ab2ba6bd1dab7ffbe4f2ab284a28c3dea8a820b4e535fdb2a3b1b1b44b952281d;
        m = 3072'hdc85279b3f9f6f56ed70ec798632ff7f62829f9aed27ce9b97bf748a8768c48364a1f91bacfdd03d5190b29661de1d3d206b56c498e67cafbee993abecc98f843cdc450214c40389a03b958e0fcceeacdc05af7438ba1a595c3e7931966a71299fbaedda383a619433cc35a51da18d6acc030a84b25333a327328ca85b44e416ccb17ae7676587791240ca9c49d1cf8218a83e6560bd24eeca83e1bae2e7ea0d8f7ad7f578fb28cc66ea66547c8b99954ca77217d79e0d40cf15e92a1da2bc22c1ff04bab3064e192857ae677f43bf3f1e52b96d702283a7dc9988476fa7ad499f015f0dd2b5d4422762d34c42635dbc83c14fdedef8f76bbe1ad03d2c60075887f5811f7765d9ae7d4201524cd355e8d8e73925526c356eb8f676af0217a64b74cb4ad6525fc9f7fca40ef0ee70f11022804bd7bf7c2321c9505c6ab348082a84955d0a38f8dda6e8c347268de733f4adf6475bf4dbf88443f43365070d2d21c472527036376a0baf155d8bf192f20254882416f304ad08992cc4e36483d004;
        m_n = 3074'h3237ad864c06090a9128f138679cd00809d7d606512d8316468408b7578973b7c9b5e06e453022fc2ae6f4d699e21e2c2df94a93b6719835041166c541336707bc323bafdeb3bfc765fc46a71f033115323fa508bc745e5a6a3c186ce69958ed660451225c7c59e6bcc33ca5ae25e729533fcf57b4daccc5cd8cd7357a4bb1be9334e8518989a7886edbf3563b62e307de757c19a9f42db11357c1e451d1815f27085280a8704d733991599ab8374666ab3588de82861f2bf30ea16d5e25d43dd3e00fb454cf9b1e6d7a8519880bc40c0e1ad46928fdd7c58236677b8905852b660fea0f22d4a2bbdd89d2cb3bd9ca2437c3eb0212107089441e52fc2d39ff8a7780a7ee0889a265182bdfeadb32caa172718c6daad93ca9147098950fde859b48b34b529ada03608035bf10f118f0eefdd7fb4284083dcde36afa3954cb7f7d57b6aa2f5c7072259173cb8d97218cc0b5209b8a40b24077bbc0bcc9af8f2d2de3b8dad8fc9c895f450eaa2740e6d0dfdab77dbe90cfb52f766d33b1c9b7c2ffc;
        m_prime = 80'h4a4c0ccb4cb4e139f56b;
        en_one_mm = 1;
        num = 3;
        // time 8045 ns
        // answer 3072'hba7f0aef407d0913a4715f76d56c3bdc71d3ab167ef274777e870db2627142258e70dd8c5fbaaa5267399c4892f2020c08789f8c2df2f261b53de21d330eba2d8a1aa162c0664b5cfb4b3260e864fa899bb3dc35ed0e43c09ba8633e9f053959ed683bddd7c6095b178d57260a948c0e6324897a1062cf0a98886a72e088630712ed5c1db11fb985fbabf1130b8b14216134d3463082ec17c0e06f436a976fe71f6ee8eedddc755c347583a5168826aa8c891ad70dd7dc63af962154663afee4a08b95a24a66652eedc079b8eecb7f6ad0f6c0e55ca394599ec10be26d5c0628bd739b76b29c3626d1b1620b3d1129dc9ae376a0bd07ba19dbac9d0d29bb92cb00f450a23a57ab77e57f90fb32d42c5366edf89e8e966dbb63dfcc35630e39c4b1691c5d409f4ebb703896526ecc8b125eba4c32de0b72dcd23a55dc92dc7b63ea9e170c25b28fb241b224d653db4b1911a53e23043b3dd05842509eac66415e08a0f6d52b281a91566e5b8fec5dbe351f6d4dce53c13250a0b22d88e3a04a39
        #10
        en_one_mm = 0;
        /*
        #30
        a = 3072'h6537b809d650de8821a83a5433a9d61aede0b5920116118d86fb93a8d61ff5a55a3e1a86a9120ba88af0ff4819be8672a58ecbc4400842af1066a7b2e35e526d9ab97bd64db7bff40899184841441aa17a2d7841cf20bc9a5fc943298506d301af280f381f7926c35def357682db8c4db8efe60f0aa935118ab780d2973963903eb6d14bb6540990f80c8061362db2be2bf1cc084dce716c58cca95c5cd0c1b936019cd4759e88ad73f4da76a03fbeef68cb9e02460732361921f86cce6536ba073754de30ed0e06ed36943c5ec050f7ddd4257fbb5af45a6f419c93f11cd49134357a0be4edc9ec3ca2f8b87afa9fa492ab0d79195a0fee32d288531fef019fa0c99c50fed25f253cb31035ef94ecbf2d1565bdc8cc519313cbef7757b04f50f8ca834effd0688af300f3659a9447316b59e67540d31c8be01cb54ecae0e8ca60cf668014db967669e48796ecd0807113b29d0a42eb574f2e554879c44eb5d200585ffbd15b31f5f7a0a3a557a31bc8400bf88f4748907725c7be2d13da5531;
        e = 3072'h671047557606fd8d3be9ad6de0da5da977f72001707d2f9276558975106c3d928f9c32333d51c99e6c89d26daa431f5e1fd01d66526876974bb2fdc8f451fbed67b1dd0cec40a7c924c87656f406e4470d1ae592a469eecccf0e3737eda2b8a8c9c8800bcd5ceb29f184bafdaffc85ee9a59aef2d323debb55e76620f9a3a3748c5635df31e3a1c190a8780677a0dae4a892fa2e2ddda31e0213f3888aff98747a039c2b2bb0900196d1fe1d086a02f7a65155f987bd00f53787c7e8d3adb6439ac0c3b0357ae05c778522188769fde1914aea9f1629383f5677593d1aefe0435a870bfd2afd5fd80183b8b3053f38e2d27a9dec0090b077242c72f4b3179928f6448045e9ed5d7d8c9b0e1f6bdf1fb6ad70a64c601148f84799bba89f81f63c81220518e4cb02fb2cfd634ed0b0d00a2d312fee7e15ca5229e0f0724872b7136e37071d1eadd13f6e6f139fa55b3555df314efeade12a969ec410e54d26a59ab2ba6bd1dab7ffbe4f2ab284a28c3dea8a820b4e535fdb2a3b1b1b44b952281d;
        en_one_mm = 1;
        num = 4;
        #10
        en_one_mm = 0;
        */
    end
    
    always #5 clk=~clk;
    
    me_top me_top(
    .clk(clk),
    .rst_n(rst_n),
    .en_pre_me(en_pre_me),
    .en_me(en_me),
    .en_one_mm(en_one_mm),
    .num(num),
    
    .a(a),
    .e(e),
    .m(m),
    .m_n(m_n),
    .m_prime(m_prime),
    
    .z(z),
    .num_out(num_out),
    .done(done)
    );
endmodule