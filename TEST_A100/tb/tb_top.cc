#include "Vahb_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <string>
using namespace  std;

#ifdef JTAGVPI
#include "jtagServer.h"
#endif

vluint64_t tick = 0;
int cnt = 0,cnt2 = 0;
int j,k,error = 0;
char send_data[16][512] = {

    "Advanced High-performance Bus (AHB): A bus protocol with a fixed pipeline between "
    "address/control and data phases. It only "
    "supports a subset of the functionality provided by the AMBA AXI protocol. The full "
    "AMBA AHB protocol specification includes a number of features that are not "
    "commonly required for master and slave IP developments and it is recommended that "
    "only a subset of the protocol is used. This subset is defined as the AMBA AHB-Lite "
    "protocol.",

    "AHB-Lite: A subset of the full AMBA AHB protocol specification. It provides all of the basic "
    "functions required by the majority of AMBA AHB slave and master designs, "
    "particularly when used with a multi-layer AMBA interconnect. In most cases, the extra "
    "facilities provided by a full AMBA AHB interface are implemented more efficiently by "
    "using an AMBA AXI protocol interface."

};
int pointer;

int main(int argc, char **argv) {

    Verilated::commandArgs(argc, argv);
    Vahb_top *ahb = new Vahb_top;

    // check if trace is enabled
    int trace_en = 0;
    for (int i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-t") == 0)
            trace_en = 1;
        if (strcmp(argv[i], "--trace") == 0)
            trace_en = 1;
    }

    if (trace_en)
    {
        cout << "Trace is enabled.\n";
    }
    else
    {
        cout << "Trace is disabled.\n";
    }
#ifdef JTAGVPI
        VerilatorJtagServer* jtag = new VerilatorJtagServer(10);
        jtag->init_jtag_server(5555, false);
    #endif
    //enable waveform
    VerilatedVcdC* tfp = new VerilatedVcdC;
    if (trace_en)
    {
        Verilated::traceEverOn(true);
        ahb->trace(tfp, 99); // Trace 99 levels of hierarchy
        tfp->open("Vahb_top.vcd");
    }
    ahb->clk = 0;
    ahb->rst_n = 0;
    for (size_t m = 0; m < 2; m++)
    {
        ahb->master_start[m] = 0;
    }
    
    ahb->eval();
    if (trace_en) tfp->dump(tick); tick++;

    // enough time to reset
    for (int i = 0; i < 10 * 10; i++)
    {
        if(cnt == 9)
        {
            cnt = 0;
            ahb->clk = !ahb->clk;   
        }
        else{
            cnt ++;
        }
        ahb->eval();
        if (trace_en)
            tfp->dump(tick);
        tick++;
    }
    cnt = 0;
    ahb->rst_n = 1;
    ahb->eval();

    for (int i = 0; i < 40000; i++)
    {
        if(cnt == 9)
        {
            cnt = 0;
            ahb->clk = !ahb->clk;
            if(pointer < (strlen(send_data[0]) > strlen(send_data[1]) ? strlen(send_data[0]) : strlen(send_data[1])))
            {
                if(ahb->clk == 0){
                    for (size_t m = 0; m < 2; m++)
                    {
                        ahb->master_din[m] = (int)send_data[m][pointer] + ((int)send_data[m][pointer+1] << 8)
                             + ((int)send_data[m][pointer+2] << 16) + ((int)send_data[m][pointer+3] << 24);
                        cout << "mst" << m << " hex in(" << dec << pointer << "):" << hex << ahb->master_din[m] << endl;
                    }
                    pointer += 4;
                    j++;
                }
            }
            else
            {   
                if(cnt2 < 1) 
                {   
                    cnt2++;
                }
                else {
                    ahb->master_start[0] = 1;
                    ahb->master_start[1] = 1;
                    if(ahb->master_okay[0] && ahb->master_okay[1]) 
                    {
                        if(cnt2 < 100) cnt2++;
                        else break;
                    }
                }
            }
        }
        else cnt ++;
        ahb->eval();
        if (trace_en)
            tfp->dump(tick);
        tick++;
    }

    if (trace_en)
    {
        tfp->close();
    }
    cout << endl << endl;
    for (size_t m = 0; m < 2; m++){
        cout << "master_" << m << " original data: " << endl;
        cout << send_data[m] <<endl << endl;
        cout << "master_" << m << " received data: " << endl;
        cout << ahb->master_receive[m];
        cout << endl << endl << "-----------------------------------------------" << endl << endl;
    }
    cout << "-----------------------------------------------" << endl << endl;
    cout << "data check:" << endl;
    
    for (size_t m = 0; m < 2; m++)
    {
        cnt = 0;
        error = 0;
        for (size_t i = 0; i < 512; i+=4)
        {
            j = (int)send_data[m][i] + ((int)send_data[m][i+1] << 8) + 
                    ((int)send_data[m][i+2] << 16) + ((int)send_data[m][i+3] << 24);
            k = (int)ahb->master_receive[m][i] + ((int)ahb->master_receive[m][i+1] << 8) 
                    + ((int)ahb->master_receive[m][i+2] << 16) + ((int)ahb->master_receive[m][i+3] << 24);
            if(j != k)
            {
                error ++;
                cout << "master_" << m << "_data[" << dec << cnt << "](" 
                        << cnt*4 << " ~ " << cnt*4+3 <<")has error" << endl;
                cout << "       origin:" << hex << j <<endl;
                cout << "       received:" << hex << k <<endl<<endl;
            }
            cnt ++;
        }
        if(!error) 
        {
            cout << "master" << m << ": no transmission error!" << endl << endl;
        }
    }
    
    delete ahb;

    return 0;
}
