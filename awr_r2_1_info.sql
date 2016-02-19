
-- TO VIEW DB INFO
set lines 300
select dbid,instance_number,version,db_name,instance_name, host_name from dba_hist_database_instance where rownum < 2;

-- TO VIEW RETENTION INFORMATION
select * from dba_hist_wr_control;

/*
-- SET RETENTION PEROID TO 31DAYS (UNIT IS MINUTES)
execute dbms_workload_repository.modify_snapshot_settings (interval => 60, retention => 43200);

-- Create Snapshot
BEGIN
  DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT ();
END;
/
*/

-- AWR get recent snapshot
select * from 
(SELECT s0.instance_number, s0.snap_id, 
  to_char(s0.startup_time,'yyyy-mon-dd hh24:mi:ss') startup_time,
  TO_CHAR(s0.END_INTERVAL_TIME,'yyyy-mon-dd hh24:mi:ss') snap_start,
  TO_CHAR(s1.END_INTERVAL_TIME,'yyyy-mon-dd hh24:mi:ss') snap_end,
  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440 + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60 + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) ela_min
FROM dba_hist_snapshot s0,
  dba_hist_snapshot s1
WHERE s1.snap_id           = s0.snap_id + 1
ORDER BY snap_id DESC)
where rownum < 11;

-- MIN/MAX for dba_hist tables
select to_char(min(end_interval_time),'yyyy-mon-dd hh24:mi:ss') min_date, to_char(max(end_interval_time),'yyyy-mon-dd hh24:mi:ss') max_date from dba_hist_snapshot;


/*
-- STATSPACK get recent snapshot
	  set lines 300
	  col what format a30
	  set numformat 999999999999999
	  alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
	  select sysdate from dual;
	  select instance, what, job, next_date, next_sec from user_jobs;
	  select * from 
	      (select 
		    s0.instance_number, s0.snap_id snap_id, s0.startup_time,
		    to_char(s0.snap_time,'YYYY-Mon-DD HH24:MI:SS') snap_start,
		    to_char(s1.snap_time,'YYYY-Mon-DD HH24:MI:SS') snap_end,
		    (s1.snap_time-s0.snap_time)*24*60 ela_min,
		    s0.dbid, s0.snap_level, s0.snapshot_exec_time_s 
	      from	stats$snapshot s0,
		      stats$snapshot s1
	      where s1.snap_id  = s0.snap_id + 1
	      ORDER BY s0.snap_id DESC)
	      where rownum < 11;


-- MIN/MAX for statspack tables
col min_dt format a14
col max_dt format a14
col host_name format a12
select	
	t1.dbid, 
	t1.instance_number,
        t2.version,
        t2.db_name,
	t2.instance_name,
        t2.host_name,
	min(to_char(t1.snap_time,'YYYY-Mon-DD HH24')) min_dt,
	max(to_char(t1.snap_time,'YYYY-Mon-DD HH24')) max_dt
from	stats$snapshot t1,
        stats$database_instance t2
where   t1.dbid = t2.dbid
  and   t1.snap_id = t2.snap_id
group by
	t1.dbid, 
	t1.instance_number,
        t2.version,
        t2.db_name,
	t2.instance_name,
        t2.host_name
/
*/


/*
AWR reports:

Running Workload Repository Reports Using Enterprise Manager
Running Workload Repository Compare Period Report Using Enterprise Manager
Running Workload Repository Reports Using SQL Scripts



Running Workload Repository Reports Using SQL Scripts
-----------------------------------------------------

You can view AWR reports by running the following SQL scripts:

The @?/rdbms/admin/awrrpt.sql SQL script generates an HTML or text report that displays statistics for a range of snapshot Ids.

The awrrpti.sql SQL script generates an HTML or text report that displays statistics for a range of snapshot Ids on 
a specified database and instance.

The awrsqrpt.sql SQL script generates an HTML or text report that displays statistics of a particular SQL statement for a 
range of snapshot Ids. Run this report to inspect or debug the performance of a SQL statement.

The awrsqrpi.sql SQL script generates an HTML or text report that displays statistics of a particular SQL statement for a 
range of snapshot Ids on a specified database and instance. Run this report to inspect or debug the performance of a SQL statement on a specific database and instance.

The awrddrpt.sql SQL script generates an HTML or text report that compares detailed performance attributes and configuration 
settings between two selected time periods.

The awrddrpi.sql SQL script generates an HTML or text report that compares detailed performance attributes and configuration 
settings between two selected time periods on a specific database and instance.

awrsqrpt.sql -- SQL performance report
*/



