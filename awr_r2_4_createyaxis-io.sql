-- create the y axis - io sysstat (dependent value)

set echo off verify off

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
select distinct block_size blocksize from v$datafile;

COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;

COLUMN instancenumber NEW_VALUE _instancenumber NOPRINT
select instance_number instancenumber from v$instance;

create table r2_y_value as 
select 
  s0.snap_id,
  s0.end_interval_time tm, 
  s0.instance_number inst,
  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
  s0.dbid,
  b.stat_name,
  e.value - b.value diff,
   (((e.value - b.value)* &_blocksize)/1024/1024)  / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60) as IORmbs
from
  dba_hist_snapshot s0,
  dba_hist_snapshot s1,
  dba_hist_sysstat b,
  dba_hist_sysstat e
where s0.dbid = &_dbid                                                              --<---- DBID HERE!
and s1.dbid = s0.dbid
and b.dbid = s0.dbid
and e.dbid = s0.dbid
and s0.instance_number = &_instancenumber                                                              --<---- instance_number HERE!
and s1.instance_number = s0.instance_number
and b.instance_number = s0.instance_number
and e.instance_number = s0.instance_number
and s1.snap_id = s0.snap_id + 1
and b.snap_id = s0.snap_id
and e.snap_id = s0.snap_id + 1
and s1.startup_time = s0.startup_time
and to_char(s0.end_interval_time,'d') >= &&DayOfWeek1                                              --<---- indicate workload periods HERE!
and to_char(s0.end_interval_time,'d') <= &&DayOfWeek2
and to_char(s0.end_interval_time,'hh24mi') >= &&Hour1
and to_char(s0.end_interval_time,'hh24mi') <= &&Hour2
and s0.end_interval_time >= to_date('&&DataRange1','yyyy-mon-dd hh24:mi:ss')
and s0.end_interval_time <= to_date('&&DataRange2','yyyy-mon-dd hh24:mi:ss')
and e.stat_name = b.stat_name
and b.stat_name = 'physical reads'                                           --<---- indicate the Y value HERE!
-- 'physical reads'
-- 'physical writes'
-- and s0.snap_id = 338
;
