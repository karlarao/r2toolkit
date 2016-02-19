----------------------------------------------------------------------------------------
-- CREATE USER
----------------------------------------------------------------------------------------
connect / as sysdba
drop user r2toolkit cascade;
create user r2toolkit identified by r2toolkit account unlock;
grant create session to r2toolkit;
grant create table to r2toolkit;
grant create view to r2toolkit;
grant create procedure to r2toolkit;
grant unlimited tablespace to r2toolkit;
grant select on dba_hist_snapshot to r2toolkit;
grant select on dba_hist_database_instance to r2toolkit;
grant select on dba_hist_sysstat to r2toolkit;
grant select on dba_hist_system_event to r2toolkit;
grant select on dba_hist_sys_time_model to r2toolkit;
grant select on dba_hist_osstat to r2toolkit;
grant select on dba_hist_sys_time_model to r2toolkit;
grant select on dba_hist_wr_control to r2toolkit;
grant select on v_$datafile to r2toolkit;
grant select on v_$database to r2toolkit;
grant select on v_$instance to r2toolkit;
connect r2toolkit/r2toolkit