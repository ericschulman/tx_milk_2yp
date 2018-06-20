/*Table 6*/
clear
import delimited C:\Users\ehs588\Downloads\input\clean_milk.csv, numericcols(3 5 6 7 8 9 10 11 12)

generate ww = type=="ww"
generate wc = type=="wc"
generate lfw = type=="lfw"
generate lfc = type=="lfc"

mixed lbid inc wc lfw lfc lfmo lestqty lnostop lback esc lnum || system: || year:, mle

/*Table 5*/

generate IxLFC = i*lfc
generate IxLFW = i*lfw
generate IxWC = i*wc
generate IxLnFMO = i*lfmo
generate IxLnQSTOP = i*lqstop
generate IxLnBACK = i*lback
generate IxESC = i*esc
generate IxLnN = i*lnum
generate NIxLFC = (1-i)*lfc
generate NIxLFW = (1-i)*lfw
generate NIxWC = (1-i)*wc
generate NIxLnFMO = (1-i)*lfmo
generate NIxLnQSTOP = (1-i)*lqstop
generate NIxLnBACK = (1-i)*lback
generate NIxESC = (1-i)*esc
generate NIxLnN = (1-i)*lnum

mixed lbid inc IxLFC IxLFW IxWC IxLnFMO IxLnQSTOP IxLnBACK IxESC IxLnN NIxLFC NIxLFW NIxWC NIxLnFMO NIxLnQSTOP NIxLnBACK NIxESC NIxLnN || system: || year:, mle
