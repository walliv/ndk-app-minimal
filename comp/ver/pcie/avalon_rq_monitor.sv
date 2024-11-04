/*
 * Copyright (C) 2020 CESNET z. s. p. o.
 * SPDX-License-Identifier: BSD-3-Clause
*/

class avalon_rq_monitor extends sv_common_pkg::Monitor;
    ////////////////////////
    // Variable
    pcie_monitor_cbs    avalon_rq_cbs;
    int unsigned verbosity = 0;

    typedef enum {IDLE, READ} state_t;
    state_t state;
    logic [31:0] data[$];
    PcieRequest hl_tr;

    protected sv_common_pkg::stats speed;
    protected int unsigned         speed_curr;

    function new (string inst = "");
       super.new(inst);
       avalon_rq_cbs = new();
       speed = new();
    endfunction

    function void verbosity_set(int unsigned level);
        verbosity = level;
    endfunction

    task run_meter();
        speed_curr = 0;
        while (enabled) begin
            time speed_start_time;
            time speed_end_time;
            const int unsigned mesures = 100;
            string msg;

            speed_end_time = $time();
            forever begin
                time step_speed_end_time = speed_end_time;
                time step_speed_start_time;

                for (int unsigned it = 0; it < mesures; it++) begin
                    step_speed_start_time = step_speed_end_time;

                    #(1us);
                    step_speed_end_time = $time();
                    speed.next_val(real'(speed_curr)/((step_speed_end_time-step_speed_start_time)/1ns));

                    speed_curr = 0;
                end

                begin
                    real min, max, avg, std_dev;

                    speed_start_time = speed_end_time;
                    speed_end_time   = step_speed_end_time;
                    speed.count(min, max, avg, std_dev);
                    msg = $sformatf("\n\tSpeed [%0dns:%0dns]\n\t\tAverage : %0.2fGb/s std_dev %0.2fGb/s\n\t\tmin : %0.2fGb/s max  %0.2fGb/s",
                            speed_start_time/1ns, speed_end_time/1ns, avg*32, std_dev*32, min*32, max*32);
                    $write({"\n", this.inst , "\n", msg, "\n"});
                    speed.reset();
                end
            end
        end
    endtask

    virtual task run();
        sv_common_pkg::Transaction common_tr;
        avst_rx::transaction tr;

        fork
            run_meter();
        join_none;

        while(enabled) begin
            avalon_rq_cbs.get(common_tr);
            $cast(tr, common_tr);

            if (verbosity > 4) begin
                tr.display({inst, " RQ TRANSACTION"});
            end

            if(tr.sop == 1'b1) begin
                logic [128-1:0] hdr;
                data = {};
                hl_tr = new();
                hdr[128-1:96] = tr.hdr[32-1:0];
                hdr[96-1:64]  = tr.hdr[64-1:32];
                hdr[64-1:32]  = tr.hdr[96-1:64];
                hdr[32-1:0]   = tr.hdr[128-1:96];

                if(hdr[30:29] == 2'b11) begin
                    hl_tr.type_tr = PCIE_RQ_WRITE;
                    hl_tr.addr    = {hdr[95:64], hdr[127:98]};
                    state = READ;
                end

                if(hdr[30:29] == 2'b10) begin
                    hl_tr.type_tr = PCIE_RQ_WRITE;
                    hl_tr.addr    = hdr[95:66];
                    state = READ;
                end

                if(hdr[30:29] == 2'b01) begin
                    hl_tr.type_tr = PCIE_RQ_READ;
                    hl_tr.addr    = {hdr[95:64], hdr[127:98]};
                end

                if(hdr[30:29] == 2'b00) begin
                    hl_tr.type_tr = PCIE_RQ_READ;
                    hl_tr.addr    = hdr[95:66];
                end

                hl_tr.length = hdr[9:0];
                hl_tr.tag    = {hdr[23], hdr[19], hdr[47:40]};
                hl_tr.fbe    = hdr[35:32];
                hl_tr.lbe    = hdr[39:36];
                hl_tr.requester_id = hdr[63:48]; // Request ID. (63:56 = BUS NUM, 55:48 = VF ID)
            end

            if(state == READ) begin
                int m_end = 8;
                if (data.size() + m_end >= hl_tr.length) begin
                     m_end = hl_tr.length - data.size();
                end

                //read data from buss
                for (int i = 0; i < m_end; i++) begin
                    data.push_back(tr.data[(i+1)*32-1 -:32]);
                end
                speed_curr += m_end;
            end

            if(tr.eop == 1'b1) begin
                sv_common_pkg::Transaction to;

                if (hl_tr.length == 1) begin
                    hl_tr.lbe = hl_tr.fbe;
                end

                state = IDLE;
                hl_tr.data  = data;
                $cast(to, hl_tr);
                foreach(cbs[it]) begin
                    cbs[it].post_rx(to, inst);
                end

                if (verbosity > 4) begin
                     hl_tr.display({inst, " CREATE FRAME"});
                end
            end
        end
    endtask

endclass

