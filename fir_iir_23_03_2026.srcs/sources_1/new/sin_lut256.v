`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:14:35
// Design Name: 
// Module Name: sin_lut256
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


module sin_lut256(
    input  wire [7:0]  addr,
    output reg  signed [15:0] data
);

    always @(*) begin
        case (addr)
            8'd0:   data = 16'sd0;
            8'd1:   data = 16'sd804;
            8'd2:   data = 16'sd1608;
            8'd3:   data = 16'sd2410;
            8'd4:   data = 16'sd3211;
            8'd5:   data = 16'sd4011;
            8'd6:   data = 16'sd4808;
            8'd7:   data = 16'sd5602;
            8'd8:   data = 16'sd6393;
            8'd9:   data = 16'sd7179;
            8'd10:  data = 16'sd7962;
            8'd11:  data = 16'sd8739;
            8'd12:  data = 16'sd9511;
            8'd13:  data = 16'sd10278;
            8'd14:  data = 16'sd11038;
            8'd15:  data = 16'sd11792;
            8'd16:  data = 16'sd12539;
            8'd17:  data = 16'sd13278;
            8'd18:  data = 16'sd14009;
            8'd19:  data = 16'sd14732;
            8'd20:  data = 16'sd15446;
            8'd21:  data = 16'sd16150;
            8'd22:  data = 16'sd16845;
            8'd23:  data = 16'sd17530;
            8'd24:  data = 16'sd18204;
            8'd25:  data = 16'sd18867;
            8'd26:  data = 16'sd19519;
            8'd27:  data = 16'sd20159;
            8'd28:  data = 16'sd20787;
            8'd29:  data = 16'sd21403;
            8'd30:  data = 16'sd22006;
            8'd31:  data = 16'sd22595;
            8'd32:  data = 16'sd23170;
            8'd33:  data = 16'sd23732;
            8'd34:  data = 16'sd24279;
            8'd35:  data = 16'sd24811;
            8'd36:  data = 16'sd25329;
            8'd37:  data = 16'sd25831;
            8'd38:  data = 16'sd26318;
            8'd39:  data = 16'sd26789;
            8'd40:  data = 16'sd27244;
            8'd41:  data = 16'sd27683;
            8'd42:  data = 16'sd28105;
            8'd43:  data = 16'sd28510;
            8'd44:  data = 16'sd28898;
            8'd45:  data = 16'sd29269;
            8'd46:  data = 16'sd29622;
            8'd47:  data = 16'sd29957;
            8'd48:  data = 16'sd30274;
            8'd49:  data = 16'sd30572;
            8'd50:  data = 16'sd30852;
            8'd51:  data = 16'sd31113;
            8'd52:  data = 16'sd31356;
            8'd53:  data = 16'sd31579;
            8'd54:  data = 16'sd31783;
            8'd55:  data = 16'sd31968;
            8'd56:  data = 16'sd32133;
            8'd57:  data = 16'sd32279;
            8'd58:  data = 16'sd32405;
            8'd59:  data = 16'sd32512;
            8'd60:  data = 16'sd32599;
            8'd61:  data = 16'sd32666;
            8'd62:  data = 16'sd32714;
            8'd63:  data = 16'sd32741;
            8'd64:  data = 16'sd32749;
            8'd65:  data = 16'sd32737;
            8'd66:  data = 16'sd32704;
            8'd67:  data = 16'sd32652;
            8'd68:  data = 16'sd32580;
            8'd69:  data = 16'sd32487;
            8'd70:  data = 16'sd32375;
            8'd71:  data = 16'sd32242;
            8'd72:  data = 16'sd32089;
            8'd73:  data = 16'sd31917;
            8'd74:  data = 16'sd31724;
            8'd75:  data = 16'sd31512;
            8'd76:  data = 16'sd31280;
            8'd77:  data = 16'sd31029;
            8'd78:  data = 16'sd30758;
            8'd79:  data = 16'sd30468;
            8'd80:  data = 16'sd30160;
            8'd81:  data = 16'sd29832;
            8'd82:  data = 16'sd29486;
            8'd83:  data = 16'sd29121;
            8'd84:  data = 16'sd28739;
            8'd85:  data = 16'sd28338;
            8'd86:  data = 16'sd27920;
            8'd87:  data = 16'sd27485;
            8'd88:  data = 16'sd27033;
            8'd89:  data = 16'sd26564;
            8'd90:  data = 16'sd26079;
            8'd91:  data = 16'sd25578;
            8'd92:  data = 16'sd25062;
            8'd93:  data = 16'sd24530;
            8'd94:  data = 16'sd23984;
            8'd95:  data = 16'sd23423;
            8'd96:  data = 16'sd22849;
            8'd97:  data = 16'sd22262;
            8'd98:  data = 16'sd21662;
            8'd99:  data = 16'sd21049;
            8'd100: data = 16'sd20425;
            8'd101: data = 16'sd19789;
            8'd102: data = 16'sd19143;
            8'd103: data = 16'sd18486;
            8'd104: data = 16'sd17819;
            8'd105: data = 16'sd17143;
            8'd106: data = 16'sd16458;
            8'd107: data = 16'sd15765;
            8'd108: data = 16'sd15064;
            8'd109: data = 16'sd14356;
            8'd110: data = 16'sd13641;
            8'd111: data = 16'sd12919;
            8'd112: data = 16'sd12192;
            8'd113: data = 16'sd11460;
            8'd114: data = 16'sd10723;
            8'd115: data = 16'sd9982;
            8'd116: data = 16'sd9237;
            8'd117: data = 16'sd8489;
            8'd118: data = 16'sd7739;
            8'd119: data = 16'sd6986;
            8'd120: data = 16'sd6232;
            8'd121: data = 16'sd5478;
            8'd122: data = 16'sd4722;
            8'd123: data = 16'sd3967;
            8'd124: data = 16'sd3211;
            8'd125: data = 16'sd2457;
            8'd126: data = 16'sd1704;
            8'd127: data = 16'sd953;
            8'd128: data = 16'sd0;
            8'd129: data = -16'sd953;
            8'd130: data = -16'sd1704;
            8'd131: data = -16'sd2457;
            8'd132: data = -16'sd3211;
            8'd133: data = -16'sd3967;
            8'd134: data = -16'sd4722;
            8'd135: data = -16'sd5478;
            8'd136: data = -16'sd6232;
            8'd137: data = -16'sd6986;
            8'd138: data = -16'sd7739;
            8'd139: data = -16'sd8489;
            8'd140: data = -16'sd9237;
            8'd141: data = -16'sd9982;
            8'd142: data = -16'sd10723;
            8'd143: data = -16'sd11460;
            8'd144: data = -16'sd12192;
            8'd145: data = -16'sd12919;
            8'd146: data = -16'sd13641;
            8'd147: data = -16'sd14356;
            8'd148: data = -16'sd15064;
            8'd149: data = -16'sd15765;
            8'd150: data = -16'sd16458;
            8'd151: data = -16'sd17143;
            8'd152: data = -16'sd17819;
            8'd153: data = -16'sd18486;
            8'd154: data = -16'sd19143;
            8'd155: data = -16'sd19789;
            8'd156: data = -16'sd20425;
            8'd157: data = -16'sd21049;
            8'd158: data = -16'sd21662;
            8'd159: data = -16'sd22262;
            8'd160: data = -16'sd22849;
            8'd161: data = -16'sd23423;
            8'd162: data = -16'sd23984;
            8'd163: data = -16'sd24530;
            8'd164: data = -16'sd25062;
            8'd165: data = -16'sd25578;
            8'd166: data = -16'sd26079;
            8'd167: data = -16'sd26564;
            8'd168: data = -16'sd27033;
            8'd169: data = -16'sd27485;
            8'd170: data = -16'sd27920;
            8'd171: data = -16'sd28338;
            8'd172: data = -16'sd28739;
            8'd173: data = -16'sd29121;
            8'd174: data = -16'sd29486;
            8'd175: data = -16'sd29832;
            8'd176: data = -16'sd30160;
            8'd177: data = -16'sd30468;
            8'd178: data = -16'sd30758;
            8'd179: data = -16'sd31029;
            8'd180: data = -16'sd31280;
            8'd181: data = -16'sd31512;
            8'd182: data = -16'sd31724;
            8'd183: data = -16'sd31917;
            8'd184: data = -16'sd32089;
            8'd185: data = -16'sd32242;
            8'd186: data = -16'sd32375;
            8'd187: data = -16'sd32487;
            8'd188: data = -16'sd32580;
            8'd189: data = -16'sd32652;
            8'd190: data = -16'sd32704;
            8'd191: data = -16'sd32737;
            8'd192: data = -16'sd32749;
            8'd193: data = -16'sd32741;
            8'd194: data = -16'sd32714;
            8'd195: data = -16'sd32666;
            8'd196: data = -16'sd32599;
            8'd197: data = -16'sd32512;
            8'd198: data = -16'sd32405;
            8'd199: data = -16'sd32279;
            8'd200: data = -16'sd32133;
            8'd201: data = -16'sd31968;
            8'd202: data = -16'sd31783;
            8'd203: data = -16'sd31579;
            8'd204: data = -16'sd31356;
            8'd205: data = -16'sd31113;
            8'd206: data = -16'sd30852;
            8'd207: data = -16'sd30572;
            8'd208: data = -16'sd30274;
            8'd209: data = -16'sd29957;
            8'd210: data = -16'sd29622;
            8'd211: data = -16'sd29269;
            8'd212: data = -16'sd28898;
            8'd213: data = -16'sd28510;
            8'd214: data = -16'sd28105;
            8'd215: data = -16'sd27683;
            8'd216: data = -16'sd27244;
            8'd217: data = -16'sd26789;
            8'd218: data = -16'sd26318;
            8'd219: data = -16'sd25831;
            8'd220: data = -16'sd25329;
            8'd221: data = -16'sd24811;
            8'd222: data = -16'sd24279;
            8'd223: data = -16'sd23732;
            8'd224: data = -16'sd23170;
            8'd225: data = -16'sd22595;
            8'd226: data = -16'sd22006;
            8'd227: data = -16'sd21403;
            8'd228: data = -16'sd20787;
            8'd229: data = -16'sd20159;
            8'd230: data = -16'sd19519;
            8'd231: data = -16'sd18867;
            8'd232: data = -16'sd18204;
            8'd233: data = -16'sd17530;
            8'd234: data = -16'sd16845;
            8'd235: data = -16'sd16150;
            8'd236: data = -16'sd15446;
            8'd237: data = -16'sd14732;
            8'd238: data = -16'sd14009;
            8'd239: data = -16'sd13278;
            8'd240: data = -16'sd12539;
            8'd241: data = -16'sd11792;
            8'd242: data = -16'sd11038;
            8'd243: data = -16'sd10278;
            8'd244: data = -16'sd9511;
            8'd245: data = -16'sd8739;
            8'd246: data = -16'sd7962;
            8'd247: data = -16'sd7179;
            8'd248: data = -16'sd6393;
            8'd249: data = -16'sd5602;
            8'd250: data = -16'sd4808;
            8'd251: data = -16'sd4011;
            8'd252: data = -16'sd3211;
            8'd253: data = -16'sd2410;
            8'd254: data = -16'sd1608;
            8'd255: data = -16'sd804;
            default: data = 16'sd0;
        endcase
    end

endmodule

