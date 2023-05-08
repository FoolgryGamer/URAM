`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/21 10:36:32
// Design Name: 
// Module Name: me_controller
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


module me_controller#(
    parameter M_SIZE = 3072,
    parameter RADIX = 72,
    parameter SIZE_LOG = 6
)(
    // to top
    input clk,
    input rst_n,
    input en_pre_me,
    input en_me,
    input en_one_mm,
    input [3:0] num,
    
    input [M_SIZE-1:0] a,
    input [M_SIZE-1:0] e,
    input [M_SIZE-1:0] m,
    input [M_SIZE+1:0] m_n,
    input [RADIX+SIZE_LOG+1:0] m_prime,    
    
    input mm_full,
    input mm_busy,
    input mm_done,
    input [3:0] mm_flag,
    input [4:0] mm_round,
    
    input [M_SIZE-1:0] res,
    
    input [7:0] mm_info_in,// 0000_00_00, first four is num, then two is the num of  me, last three is the type of mm where 00 is the first mm of a normal me and 10 is the second mm, 01 is the pre mm, 11 is the single mm
    output reg [7:0] mm_info_out,
    
    output reg [M_SIZE-1:0] z,
    output reg en_mm,
    output reg [M_SIZE-1:0] a_mm,
    output reg [M_SIZE-1:0] b_mm,
    output [M_SIZE-1:0] m_mm,
    output [M_SIZE+1:0] m_n_mm,
    output [RADIX+SIZE_LOG+1:0] m_prime_mm,
    
    
    output reg done,
    // to fifo
    input [M_SIZE-1:0] data_f_table0, data_f_table1, data_f_table2, data_f_table3,
    output reg rinc0, rinc1, rinc2, rinc3,
    input rempty0, rempty1, rempty2, rempty3,
    input scanning_e0, scanning_e1, scanning_e2, scanning_e3,
    output reg en_pre_me0, en_pre_me1, en_pre_me2, en_pre_me3,
    output reg [M_SIZE-1:0] e_0, e_1, e_2, e_3
    );
    assign m_mm=m, m_n_mm=m_n, m_prime_mm=m_prime;
    /////////////////////////////////////////////////////////////////////////////////////////////////////////cnt 
    reg [1:0] cnt;// number of working me
    //assign empty=cnt==0;
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt <= 0;
        end
        else if(en_pre_me || en_me || en_one_mm) begin
            cnt <= cnt + 1'b1;
        end
        else if(done) begin
            cnt <= cnt - 1'b1;
        end
    end
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg [M_SIZE-1:0] array_ini_r[3:0], array_ini_a[3:0], array_ini_e[3:0], array_ini_rs[3:0];
    reg [M_SIZE-1:0] array_r[3:0], array_a[3:0], array_e[3:0];
    wire [M_SIZE-1:0] array_rs[3:0];
    reg [3:0] array_num[3:0];
    
    reg [1:0] array_ready[3:0];// array_ready[i]==2'b11->ready for a mm
    reg which_mm[3:0]; // indicate which mm is waiting when doing normal me
    reg array_done[3:0];
    localparam TYPE_IDLE = 0, TYPE_pre_me = 1, TYPE_me = 2, TYPE_mm = 3;
    reg [1:0] act_i[3:0];
    /**************************************************** ģ�ݵĳ�ʼ�� *****************************************************/
    integer i;
    always @(posedge clk or negedge rst_n) begin/////////////////////////////////////////////////ģ������¼��
        if(~rst_n) begin
            for(i=0; i<4; i=i+1) begin
                act_i[i] <= TYPE_IDLE;
            end
        end
        else if(en_pre_me) begin //////////////////////¼���µ�Ԥ����ģ��
            if(act_i[0]==TYPE_IDLE) begin
                act_i[0] <= TYPE_pre_me;
            end
            else if(act_i[1]==TYPE_IDLE) begin
                act_i[1] <= TYPE_pre_me;
            end
            else if(act_i[2]==TYPE_IDLE) begin
                act_i[2] <= TYPE_pre_me;
            end
            else if(act_i[3]==TYPE_IDLE) begin
                act_i[3] <= TYPE_pre_me;
            end
        end
        else if(en_me) begin ////////////////////////¼���µ���ͨģ��
            if(act_i[0]==TYPE_IDLE) begin
                act_i[0] <= TYPE_me;
            end
            else if(act_i[1]==TYPE_IDLE) begin
                act_i[1] <= TYPE_me;
            end
            else if(act_i[2]==TYPE_IDLE) begin
                act_i[2] <= TYPE_me;
            end
            else if(act_i[3]==TYPE_IDLE) begin
                act_i[3] <= TYPE_me;
            end
        end
        else if(en_one_mm) begin
            if(act_i[0]==TYPE_IDLE) begin
                act_i[0] <= TYPE_mm;
            end
            else if(act_i[1]==TYPE_IDLE) begin
                act_i[1] <= TYPE_mm;
            end
            else if(act_i[2]==TYPE_IDLE) begin
                act_i[2] <= TYPE_mm;
            end
            else if(act_i[3]==TYPE_IDLE) begin
                act_i[3] <= TYPE_mm;
            end
        end
        else if(done) begin
            if(array_done[0]) act_i[0] <= TYPE_IDLE;
            if(array_done[1]) act_i[1] <= TYPE_IDLE;
            if(array_done[2]) act_i[2] <= TYPE_IDLE;
            if(array_done[3]) act_i[3] <= TYPE_IDLE;
        end
    end
    /************************************************************************************************************************/
    wire ready_mm = array_ready[0]==2'b11 || array_ready[1]==2'b11 || array_ready[2]==2'b11 || array_ready[3]==2'b11;
    /*********************************************************** FSM *********************************************************/ 
    localparam S_IDLE=0, S_INIT=1, S_DOING=2, S_ISSUE=3;
    reg [2:0] state, nextstate;
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            state <= S_IDLE;
        end
        else begin
            state <= nextstate;
        end
    end
    always@(*) begin
        if(~rst_n) begin
            nextstate <= S_IDLE;
        end
        case(state) 
            S_IDLE: begin
                if(en_me || en_pre_me || en_one_mm) nextstate <= S_INIT;
                else nextstate <= S_IDLE;
            end
            S_INIT: begin
                if(act_i[0] == TYPE_me) nextstate <= S_ISSUE;
                else if(act_i[0] == TYPE_pre_me && array_ready[0] == 2'b11) nextstate <= S_ISSUE;
                else if(act_i[0] == TYPE_mm) nextstate <= S_ISSUE;
                else nextstate <= S_INIT;
            end
            S_ISSUE: begin
                if(en_mm) nextstate <= S_DOING;
                else nextstate <= S_ISSUE;
            end
            S_DOING: begin
                if(~mm_full && ready_mm) nextstate <= S_ISSUE;
                else if(cnt==1 && done) nextstate <= S_IDLE;
                else nextstate <= S_DOING;
            end
            default: begin
                ;
            end
        endcase
    end
    /***************************************************************************************************************************/ 
    wire able_to_enmm = (mm_flag[0]==0 && mm_round == 5'd17) || (mm_flag[1]==0 && mm_round == 5'd3) || (mm_flag[2]==0 && mm_round == 5'd7) || (mm_flag[3]==0 && mm_round == 5'd11);
    /******************************************************** ģ�˵�ִ�� *******************************************************/ 
    integer j;
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            for(j=0; j<4; j=j+1) begin
                which_mm[j] <= 1'b0;
                array_ready[j] <= 2'b00;
            end
            en_mm <= 0;
            rinc0 <= 0;
            rinc1 <= 0;
            rinc2 <= 0;
            rinc3 <= 0;
            a_mm <= 0;
            b_mm <= 0;
            for(i=0; i<4; i=i+1) begin
                array_r[i] <= 0;
                array_a[i] <= 0;
                array_e[i] <= 0;
                array_num[i] <= 0;
            end
            z <= 0;
        end
        else begin
            if(state==S_IDLE && nextstate==S_INIT) begin
                if(act_i[0]==TYPE_me) begin
                    which_mm[0] <= 1'b0;// first mm is required and the me is a normal me
                    array_ready[0] <= 2'b11;// now is ready
                end
                else if(act_i[0]==TYPE_pre_me) begin
                    array_ready[0] <= 2'b10;// now wait for data from table
                end
                else if(act_i[0]==TYPE_mm) begin
                    array_ready[0] <= 2'b11;// now is ready
                end
            end
            else if(state==S_ISSUE) begin///////////////// to issue a ready mm while the mm module is found available
                if(able_to_enmm&&~en_mm) begin
                    en_mm <= 1;
                    if(array_ready[0]==2'b11) begin
                        if(act_i[0]==TYPE_me)begin
                            if(which_mm[0]==1'b0) begin// һ��ѭ���Ŀ�ʼ
                                if(array_e[0][0]==1'b1) begin
                                    ////////////////////////ִ��ѭ���ڵ�һ��ģ��
                                    mm_info_out <= {array_num[0], 4'b00_00};
                                    a_mm <= array_a[0];
                                    b_mm <= array_r[0];
                                    ////////////////////////
                                    which_mm[0] <= 1'b1;
                                    if(array_e[0]!=1) begin
                                        array_ready[0] <= 2'b11;//��ǵڶ���ģ����׼���õ�
                                    end
                                    else begin
                                        array_ready[0] <= 2'b00;//���һ�֣��������ڶ���ģ��
                                        array_e[0] <= array_e[0]>>1;
                                    end
                                end
                                else begin
                                    array_e[0] <= array_e[0]>>1;
                                    ////////////////////////����ѭ���ڵ�һ��ģ�ˣ�ֱ��ִ�еڶ���ģ��
                                    mm_info_out <= {array_num[0], 4'b00_10};
                                    a_mm <= array_a[0];
                                    b_mm <= array_a[0];
                                    ////////////////////////
                                    which_mm[0] <= 1'b0;
                                    array_ready[0] <= 2'b00;
                                end
                            end
                            else begin// current mm is the second one
                                array_e[0] <= array_e[0]>>1;
                                ////////////////////////ִ��ѭ���ڵڶ���ģ��
                                mm_info_out <= {array_num[0], 4'b00_10};
                                a_mm <= array_a[0];
                                b_mm <= array_a[0];
                                ////////////////////////
                                which_mm[0] <= 1'b0;
                                array_ready[0] <= 2'b00;
                            end
                        end
                        else if(act_i[0]==TYPE_pre_me) begin
                            ////////////////////////
                            mm_info_out <= {array_num[0], 4'b00_01};
                            a_mm <= array_rs[0];
                            b_mm <= array_r[0];
                            ////////////////////////
                            array_ready[0] <= 2'b00;
                        end
                        else if(act_i[0]==TYPE_mm) begin
                            ////////////////////////
                            mm_info_out <= {array_num[0], 4'b00_11};
                            a_mm <= array_a[0];
                            b_mm <= array_e[0];
                            ////////////////////////
                            array_ready[0] <= 2'b00;
                        end
                        
                    end
                    else if(array_ready[1]==2'b11) begin
                        if(act_i[1]==TYPE_me)begin
                            if(which_mm[1]==1'b0) begin// һ��ѭ���Ŀ�ʼ
                                if(array_e[1][0]==1'b1) begin
                                    ////////////////////////ִ��ѭ���ڵ�һ��ģ��
                                    mm_info_out <= {array_num[1], 4'b01_00};
                                    a_mm <= array_a[1];
                                    b_mm <= array_r[1];
                                    ////////////////////////
                                    which_mm[1] <= 1'b1;
                                    if(array_e[1]!=1) begin
                                        array_ready[1] <= 2'b11;//��ǵڶ���ģ����׼���õ�
                                    end
                                    else begin
                                        array_ready[1] <= 2'b00;//���һ�֣��������ڶ���ģ��
                                        array_e[1] <= array_e[1]>>1;
                                    end
                                end
                                else begin
                                    array_e[1] <= array_e[1]>>1;
                                    ////////////////////////����ѭ���ڵ�һ��ģ�ˣ�ֱ��ִ�еڶ���ģ��
                                    mm_info_out <= {array_num[1], 4'b01_10};
                                    a_mm <= array_a[1];
                                    b_mm <= array_a[1];
                                    ////////////////////////
                                    which_mm[1] <= 1'b0;
                                    array_ready[1] <= 2'b00;
                                end
                            end
                            else begin// current mm is the second one
                                array_e[1] <= array_e[1]>>1;
                                ////////////////////////ִ��ѭ���ڵڶ���ģ��
                                mm_info_out <= {array_num[1], 4'b01_10};
                                a_mm <= array_a[1];
                                b_mm <= array_a[1];
                                ////////////////////////
                                which_mm[1] <= 1'b0;
                                array_ready[1] <= 2'b00;
                            end
                        end
                        else if(act_i[1]==TYPE_pre_me) begin
                            ////////////////////////
                            mm_info_out <= {array_num[1], 4'b01_01};
                            a_mm <= array_rs[1];
                            b_mm <= array_r[1];
                            ////////////////////////
                            array_ready[1] <= 2'b00;
                        end
                        else if(act_i[1]==TYPE_mm) begin
                            ////////////////////////
                            mm_info_out <= {array_num[1], 4'b01_11};
                            a_mm <= array_a[1];
                            b_mm <= array_e[1];
                            ////////////////////////
                            array_ready[1] <= 2'b00;
                        end
                        
                    end
                    else if(array_ready[2]==2'b11) begin
                        if(act_i[2]==TYPE_me)begin
                            if(which_mm[2]==1'b0) begin// һ��ѭ���Ŀ�ʼ
                                if(array_e[2][0]==1'b1) begin
                                    ////////////////////////ִ��ѭ���ڵ�һ��ģ��
                                    mm_info_out <= {array_num[2], 4'b1000};
                                    a_mm <= array_a[2];
                                    b_mm <= array_r[2];
                                    ////////////////////////
                                    which_mm[2] <= 1'b1;
                                    if(array_e[2]!=1) begin
                                        array_ready[2] <= 2'b11;//��ǵڶ���ģ����׼���õ�
                                    end
                                    else begin
                                        array_ready[2] <= 2'b00;//���һ�֣��������ڶ���ģ��
                                        array_e[2] <= array_e[2]>>1;
                                    end
                                end
                                else begin
                                    array_e[2] <= array_e[2]>>1;
                                    ////////////////////////����ѭ���ڵ�һ��ģ�ˣ�ֱ��ִ�еڶ���ģ��
                                    mm_info_out <= {array_num[2], 4'b1010};
                                    a_mm <= array_a[2];
                                    b_mm <= array_a[2];
                                    ////////////////////////
                                    which_mm[2] <= 1'b0;
                                    array_ready[2] <= 2'b00;
                                end
                            end
                            else begin// current mm is the second one
                                array_e[2] <= array_e[2]>>1;
                                ////////////////////////ִ��ѭ���ڵڶ���ģ��
                                mm_info_out <= {array_num[2], 4'b1010};
                                a_mm <= array_a[2];
                                b_mm <= array_a[2];
                                ////////////////////////
                                which_mm[2] <= 1'b0;
                                array_ready[2] <= 2'b00;
                            end
                        end
                        else if(act_i[2]==TYPE_pre_me) begin
                            ////////////////////////
                            mm_info_out <= {array_num[2], 4'b1001};
                            a_mm <= array_rs[2];
                            b_mm <= array_r[2];
                            ////////////////////////
                            array_ready[2] <= 2'b00;
                        end
                        else if(act_i[2]==TYPE_mm) begin
                            ////////////////////////
                            mm_info_out <= {array_num[2], 4'b10_11};
                            a_mm <= array_a[2];
                            b_mm <= array_e[2];
                            ////////////////////////
                            array_ready[2] <= 2'b00;
                        end
                        
                    end
                    else if(array_ready[3]==2'b11) begin
                        if(act_i[3]==TYPE_me)begin
                            if(which_mm[3]==1'b0) begin// һ��ѭ���Ŀ�ʼ
                                if(array_e[3][0]==1'b1) begin
                                    ////////////////////////ִ��ѭ���ڵ�һ��ģ��
                                    mm_info_out <= {array_num[3], 4'b1100};
                                    a_mm <= array_a[3];
                                    b_mm <= array_r[3];
                                    ////////////////////////
                                    which_mm[3] <= 1'b1;
                                    if(array_e[3]!=1) begin
                                        array_ready[3] <= 2'b11;//��ǵڶ���ģ����׼���õ�
                                    end
                                    else begin
                                        array_ready[3] <= 2'b00;//���һ�֣��������ڶ���ģ��
                                        array_e[3] <= array_e[3]>>1;
                                    end
                                end
                                else begin
                                    array_e[3] <= array_e[3]>>1;
                                    ////////////////////////����ѭ���ڵ�һ��ģ�ˣ�ֱ��ִ�еڶ���ģ��
                                    mm_info_out <= {array_num[3], 4'b1110};
                                    a_mm <= array_a[3];
                                    b_mm <= array_a[3];
                                    ////////////////////////
                                    which_mm[3] <= 1'b0;
                                    array_ready[3] <= 2'b00;
                                end
                            end
                            else begin// current mm is the second one
                                array_e[3] <= array_e[3]>>1;
                                ////////////////////////ִ��ѭ���ڵڶ���ģ��
                                mm_info_out <= {array_num[3], 4'b1110};
                                a_mm <= array_a[3];
                                b_mm <= array_a[3];
                                ////////////////////////
                                which_mm[3] <= 1'b0;
                                array_ready[3] <= 2'b00;
                            end
                        end
                        else if(act_i[3]==TYPE_pre_me) begin
                            ////////////////////////
                            mm_info_out <= {array_num[3], 4'b1101};
                            a_mm <= array_rs[3];
                            b_mm <= array_r[3];
                            ////////////////////////
                            array_ready[3] <= 2'b00;
                        end
                        else if(act_i[3]==TYPE_mm) begin
                            ////////////////////////
                            mm_info_out <= {array_num[3], 4'b11_11};
                            a_mm <= array_a[3];
                            b_mm <= array_e[3];
                            ////////////////////////
                            array_ready[3] <= 2'b00;
                        end
                        
                    end
                end
                else en_mm <= 0;
            end
            else if(state==S_DOING) begin/////////// to receive data from mm, to go to S_ISSUE
                en_mm <= 0;
            end
/*****************************************************************************/
            if(mm_done) begin
                if(mm_info_in[3:2]==2'b00) begin
                    if(act_i[0]==TYPE_pre_me) begin
                        if(rempty0&&!scanning_e0) begin
                            z <= res;
                            array_r[0] <= res;
                        end
                        else begin
                            array_r[0] <= res;
                            array_ready[0] <= 2'b10;
                        end
                    end
                    else if(act_i[0]==TYPE_me) begin
                        if(mm_info_in[1:0]==2'b10) begin// ��ɵ�ģ���ǵڶ���ģ��
                            array_a[0] <= res;
                            array_ready[0] <= 2'b11;
                        end
                        else begin// ��ɵ�ģ���ǵ�һ��ģ��
                            if(array_e[0]==0) begin
                                z <= res;
                                array_r[0] <= res;
                                array_ready[0] <= 2'b00;
                            end
                            else begin
                                array_r[0] <= res;
                            end
                        end
                    end
                    else if(act_i[0]==TYPE_mm) begin
                        z <= res;
                    end
                end
                else if(mm_info_in[3:2]==2'b01) begin
                    if(act_i[1]==TYPE_pre_me) begin
                        if(rempty1&&!scanning_e1) begin
                            z <= res;
                            array_r[1] <= res;
                        end
                        else begin
                            array_r[1] <= res;
                            array_ready[1] <= 2'b10;
                        end
                    end
                    else if(act_i[1]==TYPE_me) begin
                        if(mm_info_in[1:0]==2'b10) begin// ��ɵ�ģ���ǵڶ���ģ��
                            array_a[1] <= res;
                            array_ready[1] <= 2'b11;
                        end
                        else begin// ��ɵ�ģ���ǵ�һ��ģ��
                            if(array_e[1]==0) begin
                                z <= res;
                                array_r[1] <= res;
                                array_ready[1] <= 2'b00;
                            end
                            else begin
                                array_r[1] <= res;
                            end
                        end
                    end
                    else if(act_i[1]==TYPE_mm) begin
                        z <= res;
                    end
                end
                else if(mm_info_in[3:2]==2'b10) begin
                    if(act_i[2]==TYPE_pre_me) begin
                        if(rempty2&&!scanning_e2) begin
                            z <= res;
                            array_r[2] <= res;
                        end
                        else begin
                            array_r[2] <= res;
                            array_ready[2] <= 2'b10;
                        end
                    end
                    else if(act_i[2]==TYPE_me) begin
                        if(mm_info_in[1:0]==2'b10) begin// ��ɵ�ģ���ǵڶ���ģ��
                            array_a[2] <= res;
                            array_ready[2] <= 2'b11;
                        end
                        else begin// ��ɵ�ģ���ǵ�һ��ģ��
                            if(array_e[2]==0) begin
                                z <= res;
                                array_r[2] <= res;
                                array_ready[2] <= 2'b00;
                            end
                            else begin
                                array_r[2] <= res;
                            end
                        end
                    end
                    else if(act_i[2]==TYPE_mm) begin
                        z <= res;
                    end
                end
                else if(mm_info_in[3:2]==2'b11) begin
                    if(act_i[3]==TYPE_pre_me) begin
                        if(rempty3&&!scanning_e3) begin
                            z <= res;
                            array_r[3] <= res;
                        end
                        else begin
                            array_r[3] <= res;
                            array_ready[3] <= 2'b10;
                        end
                    end
                    else if(act_i[3]==TYPE_me) begin
                        if(mm_info_in[1:0]==2'b10) begin// ��ɵ�ģ���ǵڶ���ģ��
                            array_a[3] <= res;
                            array_ready[3] <= 2'b11;
                        end
                        else begin// ��ɵ�ģ���ǵ�һ��ģ��
                            if(array_e[3]==0) begin
                                z <= res;
                                array_r[3] <= res;
                                array_ready[3] <= 2'b00;
                            end
                            else begin
                                array_r[3] <= res;
                            end
                        end
                    end
                    else if(act_i[3]==TYPE_mm) begin
                        z <= res;
                    end
                end
            end

            if(rinc0) begin
                rinc0 <= 1'b0;
                array_ready[0] <= 2'b11;
            end
            else if(array_ready[0]==2'b10&&!rempty0) rinc0 <= 1'b1;
            
            if(rinc1) begin
                rinc1 <= 1'b0;
                array_ready[1] <= 2'b11;
            end
            else if(array_ready[1]==2'b10&&!rempty1) rinc1 <= 1'b1;
            
            if(rinc2) begin
                rinc2 <= 1'b0;
                array_ready[2] <= 2'b11;
            end
            else if(array_ready[2]==2'b10&&!rempty2) rinc2 <= 1'b1;
            
            if(rinc3) begin
                rinc3 <= 1'b0;
                array_ready[3] <= 2'b11;
            end
            else if(array_ready[3]==2'b10&&!rempty3) rinc3 <= 1'b1;
            /*****************************����¼��ģ�� **********************************/
            if(en_pre_me) begin ////////////////////////¼���µ�Ԥ����ģ��
                if(act_i[0]==TYPE_IDLE) begin
                    array_r[0] <= 1;
                    array_e[0] <= e;
                    array_ready[0] <= 2'b10;
                    array_num[0] <= num;
                end
                else if(act_i[1]==TYPE_IDLE) begin
                    array_r[1] <= 1;
                    array_e[1] <= e;
                    array_ready[1] <= 2'b10;
                    array_num[1] <= num;
                end
                else if(act_i[2]==TYPE_IDLE) begin
                    array_r[2] <= 1;
                    array_e[2] <= e;
                    array_ready[2] <= 2'b10;
                    array_num[2] <= num;
                end
                else if(act_i[3]==TYPE_IDLE) begin
                    array_r[3] <= 1;
                    array_e[3] <= e;
                    array_ready[3] <= 2'b10;
                    array_num[3] <= num;
                end
            end
            else if(en_me) begin ////////////////////////¼���µ���ͨģ��
                if(act_i[0]==TYPE_IDLE) begin
                    array_r[0] <= 1;
                    array_a[0] <= a;
                    array_e[0] <= e;
                    array_ready[0] <= 2'b11;
                    array_num[0] <= num;
                end
                else if(act_i[1]==TYPE_IDLE) begin
                    array_r[1] <= 1;
                    array_a[1] <= a;
                    array_e[1] <= e;
                    array_ready[1] <= 2'b11;
                    array_num[1] <= num;
                end
                else if(act_i[2]==TYPE_IDLE) begin
                    array_r[2] <= 1;
                    array_a[2] <= a;
                    array_e[2] <= e;
                    array_ready[2] <= 2'b11;
                    array_num[2] <= num;
                end
                else if(act_i[3]==TYPE_IDLE) begin
                    array_r[3] <= 1;
                    array_a[3] <= a;
                    array_e[3] <= e;
                    array_ready[3] <= 2'b11;
                    array_num[3] <= num;
                end
            end
            else if(en_one_mm) begin ///////////¼���������Ͳ���
                if(act_i[0]==TYPE_IDLE) begin
                    array_r[0] <= 0;
                    array_a[0] <= a;
                    array_e[0] <= e;
                    array_ready[0] <= 2'b11;
                    array_num[0] <= num;
                end
                else if(act_i[1]==TYPE_IDLE) begin
                    array_r[1] <= 0;
                    array_a[1] <= a;
                    array_e[1] <= e;
                    array_ready[1] <= 2'b11;
                    array_num[1] <= num;
                end
                else if(act_i[2]==TYPE_IDLE) begin
                    array_r[2] <= 0;
                    array_a[2] <= a;
                    array_e[2] <= e;
                    array_ready[2] <= 2'b11;
                    array_num[2] <= num;
                end
                else if(act_i[3]==TYPE_IDLE) begin
                    array_r[3] <= 0;
                    array_a[3] <= a;
                    array_e[3] <= e;
                    array_ready[3] <= 2'b11;
                    array_num[3] <= num;
                end
            end
            /*************************************************************************/        
        end
    end
    
/******************************** done ************************************/       
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            done <= 0;
            array_done[0] <= 0;
            array_done[1] <= 0;
            array_done[2] <= 0;
            array_done[3] <= 0;
        end
        else begin
            if(mm_done) begin
                if(mm_info_in[3:2]==2'b00) begin
                    if(act_i[0]==TYPE_pre_me && rempty0) begin
                        done <= 1;
                        array_done[0] <= 1;
                    end
                    else if(act_i[0]==TYPE_me && mm_info_in[1:0]==2'b00 && array_e[0]==0) begin
                        done <= 1;
                        array_done[0] <= 1;
                    end
                    else if(act_i[0]==TYPE_mm) begin
                        done <= 1;
                        array_done[0] <= 1;
                    end
                    else begin
                        done <= 0;
                        array_done[0] <= 0;
                    end
                end
                else if(mm_info_in[3:2]==2'b01) begin
                    if(act_i[1]==TYPE_pre_me && rempty1) begin
                        done <= 1;
                        array_done[1] <= 1;
                    end
                    else if(act_i[1]==TYPE_me && mm_info_in[1:0]==2'b00 && array_e[1]==0) begin
                        done <= 1;
                        array_done[1] <= 1;
                    end
                    else if(act_i[1]==TYPE_mm) begin
                        done <= 1;
                        array_done[1] <= 1;
                    end
                    else begin
                        done <= 0;
                        array_done[1] <= 0;
                    end
                end
                else if(mm_info_in[3:2]==2'b10) begin
                    if(act_i[2]==TYPE_pre_me && rempty2) begin
                        done <= 1;
                        array_done[2] <= 1;
                    end
                    else if(act_i[2]==TYPE_me && mm_info_in[1:0]==2'b00 && array_e[2]==0) begin
                        done <= 1;
                        array_done[2] <= 1;
                    end
                    else if(act_i[2]==TYPE_mm) begin
                        done <= 1;
                        array_done[2] <= 1;
                    end
                    else begin
                        done <= 0;
                        array_done[2] <= 0;
                    end
                end
                else if(mm_info_in[3:2]==2'b11) begin
                    if(act_i[3]==TYPE_pre_me && rempty3) begin
                        done <= 1;
                        array_done[3] <= 1;
                    end
                    else if(act_i[3]==TYPE_me && mm_info_in[1:0]==2'b00 && array_e[3]==0) begin
                        done <= 1;
                        array_done[3] <= 1;
                    end
                    else if(act_i[3]==TYPE_mm) begin
                        done <= 1;
                        array_done[3] <= 1;
                    end
                    else begin
                        done <= 0;
                        array_done[3] <= 0;
                    end
                end
            end
            else begin
                done <= 0;
                array_done[0] <= 0;
                array_done[1] <= 0;
                array_done[2] <= 0;
                array_done[3] <= 0;
            end
        end
    end
/******************************** Ԥ�������ȡ���� ************************************/   
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            en_pre_me0 <= 0;
            en_pre_me1 <= 0;
            en_pre_me2 <= 0;
            en_pre_me3 <= 0;
            e_0 <= 0;
            e_1 <= 0;
            e_2 <= 0;
            e_3 <= 0;
        end
        else if(en_pre_me) begin ////////////////////////¼���µ�Ԥ����ģ��
            if(act_i[0]==TYPE_IDLE) begin
                en_pre_me0 <= 1;
                en_pre_me1 <= 0;
                en_pre_me2 <= 0;
                en_pre_me3 <= 0;
                e_0 <= e;
            end
            else if(act_i[1]==TYPE_IDLE) begin
                en_pre_me0 <= 0;
                en_pre_me1 <= 1;
                en_pre_me2 <= 0;
                en_pre_me3 <= 0;
                e_1 <= e;
            end
            else if(act_i[2]==TYPE_IDLE) begin
                en_pre_me0 <= 0;
                en_pre_me1 <= 0;
                en_pre_me2 <= 1;
                en_pre_me3 <= 0;
                e_2 <= e;
            end
            else if(act_i[3]==TYPE_IDLE) begin
                en_pre_me0 <= 0;
                en_pre_me1 <= 0;
                en_pre_me2 <= 0;
                en_pre_me3 <= 1;
                e_3 <= e;
            end
        end
        else begin
            en_pre_me0 <= 0;
            en_pre_me1 <= 0;
            en_pre_me2 <= 0;
            en_pre_me3 <= 0;
        end
    end
    //////////////////////////////////////////////////////////////////////////////////////////////
    assign array_rs[0] = data_f_table0;
    assign array_rs[1] = data_f_table1;
    assign array_rs[2] = data_f_table2;
    assign array_rs[3] = data_f_table3;
endmodule
