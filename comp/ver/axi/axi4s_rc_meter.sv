/*!
 * \file       axi4s_rc_meter.sv
 * \brief      Get statistic from axi4s
 * \author     Radek Iša <isa@cesnet.cz>
 * \date       2024
 * \copyright  CESNET, z. s. p. o.
 */

/* SPDX-License-Identifier: BSD-3-Clause */

class Axi4S_RC_meter #(DATA_WIDTH = 512, USER_WIDTH = 137, ITEM_WIDTH_IN = 8, ST_COUNT = 4) extends Monitor;

    localparam REGIONS = ST_COUNT;
    localparam REGION_SIZE = 1;
    localparam ITEM_WIDTH = 8;
    localparam BLOCK_SIZE = DATA_WIDTH/REGIONS/ITEM_WIDTH;

    protected int sof_pos[REGIONS];
    protected int eof_pos[REGIONS];

    localparam ITEMS = REGIONS * REGION_SIZE * BLOCK_SIZE;
    localparam REGION_ITEMS = REGION_SIZE * BLOCK_SIZE;
    localparam WORD_BLOCKS = REGIONS * REGION_SIZE;
    localparam SOF_POS_WIDTH = $clog2(REGION_SIZE);
    localparam EOF_POS_WIDTH = $clog2(REGION_SIZE * BLOCK_SIZE);

    protected virtual iAxi4SRx#(DATA_WIDTH, USER_WIDTH, ITEM_WIDTH_IN) vif;
    protected sv_common_pkg::stats speed;
    protected int unsigned         speed_curr;
    protected logic                inframe;
	protected int old_inframe = 0;

    function new(string i, virtual iAxi4SRx#(DATA_WIDTH, USER_WIDTH, ITEM_WIDTH_IN) v);
        super.new(i);
        speed = new();
        vif = v;
    endfunction

    virtual task setEnabled();
        enabled = 1;
        fork
            run();
        join_none;
    endtask

    function int hasSOF();
      if (USER_WIDTH==137) // ULTRASCALE
         return vif.cb.TUSER[21:20];
      else begin // 7SERIES
         if (!inframe)
            return vif.cb.TVALID;
         else
            return 0;
      end
    endfunction

    function int hasEOF();
      if (USER_WIDTH==137) // ULTRASCALE
         return vif.cb.TUSER[27:26];
      else begin // 7SERIES
         return vif.cb.TLAST;
      end
    endfunction

    function logic [3:0] fbe(int unsigned index);
        if(USER_WIDTH== 137) begin
            return vif.cb.TUSER[(index+1)*4-1 -: 4];
        end else if (USER_WIDTH == 60) begin
            return vif.cb.TUSER[3:0];
        end else begin
            $write("NOT SUPPORTED AXI USER_WIDTH\n");
            $stop();
        end
    endfunction

    function logic [3:0] lbe(int unsigned index);
        if(USER_WIDTH== 137) begin
            return vif.cb.TUSER[(index+1)*4+7 -: 4];
        end else if (USER_WIDTH == 60) begin
            return vif.cb.TUSER[7:4];
        end else begin
            $write("NOT SUPPORTED AXI USER_WIDTH\n");
            $stop();
        end
    endfunction

    function int sofPos(int index);
      if(SOF_POS_WIDTH == 0) begin
        return 0;
      end

      if (USER_WIDTH==137) // ULTRASCALE
         return index;
      else begin // 7SERIES
         return 0;
      end
    endfunction

    function int eofPos(int index);
      int pos = 0;
      int j = 0;

      if (EOF_POS_WIDTH == 0) begin
          return 0;
      end

      if (USER_WIDTH==137) begin // ULTRASCALE
         if ((vif.cb.TUSER[26] && vif.cb.TUSER[31:31] == index))
            return vif.cb.TUSER[30:28];
         if ((vif.cb.TUSER[27] && vif.cb.TUSER[35:35] == index))
            return vif.cb.TUSER[34:32];
      end else begin // 7SERIES
         for (j = 0; j < REGION_ITEMS; j++) begin
            if (vif.cb.TKEEP[j]==1'b0)
               break;
            pos = j;
         end
         return pos;
      end
        return -1;
    endfunction

    function int isSOF(int index);
      if (USER_WIDTH==137) begin // ULTRASCALE
         if ((vif.cb.TUSER[20] && vif.cb.TUSER[23:23] == index) ||
               (vif.cb.TUSER[21] && vif.cb.TUSER[25:25] == index))
            return 1;
      end else begin // 7SERIES
         if (!old_inframe)
            return vif.cb.TVALID;
      end
        return 0;
    endfunction

    function int isEOF(int index);
      if (USER_WIDTH==137) begin // ULTRASCALE
         if ((vif.cb.TUSER[26] && vif.cb.TUSER[31:31] == index) ||
               (vif.cb.TUSER[27] && vif.cb.TUSER[35:35] == index))
            return 1;
      end else begin // 7SERIES
         return hasEOF(); // only 1 region
      end
        return 0;
    endfunction

    task run_meter();
        speed_curr = 0;
        speed.reset();

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
                            speed_start_time/1ns, speed_end_time/1ns, avg*ITEM_WIDTH, std_dev*ITEM_WIDTH, min*ITEM_WIDTH, max*ITEM_WIDTH);
                    $write({"\n", this.inst , "\n", msg, "\n"});
                    speed.reset();
                end
            end
        end
    endtask


    virtual task run();
        inframe = 0;

        fork
            run_meter();
        join_none


        while (enabled) begin
            int unsigned data_frame_size = 0;

            do begin
                @(vif.monitor_cb);
            end while (enabled && !(vif.monitor_cb.TVALID && vif.monitor_cb.TREADY));

            if (!enabled)
                break;

            for (int unsigned it = 0; it < REGIONS; it++) begin
                if (inframe == 1) begin
                    if (isEOF(it)) begin
                        data_frame_size += eofPos(it)+1;
                        inframe = 0;
                        if (isSOF(it)) begin
                            data_frame_size += (REGION_SIZE - sofPos(it))*BLOCK_SIZE;
                            inframe = 1;
                        end
                        old_inframe = inframe;
                    end else begin
                        data_frame_size += REGION_SIZE*BLOCK_SIZE;
                    end
                end else begin
                    if (isSOF(it)) begin
                       if (isEOF(it)) begin
                            data_frame_size += (eofPos(it)+1 - sofPos(it)*BLOCK_SIZE);
                            inframe = 0;
                       end else begin
                            data_frame_size += (REGION_SIZE - sofPos(it))*BLOCK_SIZE;
                            inframe = 1;
                       end
                        old_inframe = inframe;
                    end else begin
                        data_frame_size += 0;
                    end
                end
            end
            speed_curr += data_frame_size;
        end
    endtask

endclass
