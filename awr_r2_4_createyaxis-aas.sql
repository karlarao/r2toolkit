-- create the y axis - AAS and cpu sysstat (dependent value)

set echo off verify off

COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;

COLUMN instancenumber NEW_VALUE _instancenumber NOPRINT
select instance_number instancenumber from v$instance;

create table r2_y_value as 
SELECT * FROM
( 
  SELECT s0.snap_id,
  s0.END_INTERVAL_TIME tm,
  s0.instance_number inst,
  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
  s0.dbid,
  'AAS' stat_name,
  ((s5t1.value - s5t0.value) / 1000000)/60 /  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) diff,
  ((round(((s6t1.value - s6t0.value) / 1000000) + ((s7t1.value - s7t0.value) / 1000000),2)) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 
                                                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 
                                                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) 
                                                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2)*60)*s3t1.value))*100 as oracpupct,
  e.value - b.value cpuusedbysession
FROM dba_hist_snapshot s0,
  dba_hist_snapshot s1,
  dba_hist_osstat s3t1,         -- osstat just get the end value
  dba_hist_sys_time_model s5t0,
  dba_hist_sys_time_model s5t1,
  dba_hist_sys_time_model s6t0,
  dba_hist_sys_time_model s6t1,
  dba_hist_sys_time_model s7t0,
  dba_hist_sys_time_model s7t1,
  dba_hist_sysstat b,
  dba_hist_sysstat e
WHERE s0.dbid            = &_dbid    -- CHANGE THE DBID HERE!
AND s1.dbid              = s0.dbid
AND s3t1.dbid            = s0.dbid
AND s5t0.dbid            = s0.dbid
AND s5t1.dbid            = s0.dbid
AND s6t0.dbid            = s0.dbid
AND s6t1.dbid            = s0.dbid
AND s7t0.dbid            = s0.dbid
AND s7t1.dbid            = s0.dbid
AND b.dbid               = s0.dbid
AND e.dbid               = s0.dbid
AND s0.instance_number   = &_instancenumber   -- CHANGE THE INSTANCE_NUMBER HERE!
AND s1.instance_number   = s0.instance_number
AND s3t1.instance_number = s0.instance_number
AND s5t0.instance_number = s0.instance_number
AND s5t1.instance_number = s0.instance_number
AND s6t0.instance_number = s0.instance_number
AND s6t1.instance_number = s0.instance_number
AND s7t0.instance_number = s0.instance_number
AND s7t1.instance_number = s0.instance_number
AND b.instance_number    = s0.instance_number
AND e.instance_number    = s0.instance_number 
AND s1.snap_id           = s0.snap_id + 1
AND s3t1.snap_id         = s0.snap_id + 1
AND s5t0.snap_id         = s0.snap_id
AND s5t1.snap_id         = s0.snap_id + 1
AND s6t0.snap_id         = s0.snap_id
AND s6t1.snap_id         = s0.snap_id + 1
AND s7t0.snap_id         = s0.snap_id
AND s7t1.snap_id         = s0.snap_id + 1
AND b.snap_id            = s0.snap_id
AND e.snap_id            = s0.snap_id + 1
AND s1.startup_time      = s0.startup_time
AND s3t1.stat_name       = 'NUM_CPUS'
AND s5t0.stat_name       = 'DB time'
AND s5t1.stat_name       = s5t0.stat_name
AND s6t0.stat_name       = 'DB CPU'
AND s6t1.stat_name       = s6t0.stat_name
AND s7t0.stat_name       = 'background cpu time'
AND s7t1.stat_name       = s7t0.stat_name
AND e.stat_name          = b.stat_name
AND b.stat_name          = 'CPU used by this session'                                           --<---- indicate the Y value HERE!
)
where to_char(tm,'d') >= &&DayOfWeek1     -- day of week: 1=sunday 7=saturday
and to_char(tm,'d') <= &&DayOfWeek2
and to_char(tm,'hh24mi') >= &&Hour1     -- hour
and to_char(tm,'hh24mi') <= &&Hour2
and tm >= to_date('&&DataRange1','yyyy-mon-dd hh24:mi:ss')     -- data range
and tm <= to_date('&&DataRange2','yyyy-mon-dd hh24:mi:ss')
ORDER BY snap_id ASC;