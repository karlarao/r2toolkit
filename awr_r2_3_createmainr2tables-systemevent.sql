----------------------------------------------------------------------------------------
-- CREATE THE r2 TABLES
----------------------------------------------------------------------------------------

-- create regression table
create table r2_regression_data 
  (
    snap_id number,
    tm date,
    x_axis number,
    y_axis number,
    proj_y number, 
    residual number,
    residual_sqr number,
    stnd_residual number
  );


-- create outlier table
create table r2_outlier_data 
  (
    snap_id number,
    tm date,
    x_axis number,
    y_axis number,
    proj_y number, 
    residual number,
    residual_sqr number,
    stnd_residual number
  );


-- create table for top r2
create table r2_stat_name_top
  (
    regr_count number,
    regr_r2    number,
    stat_name  varchar2(200 byte)
  );


-- create distinct statistic names for x axis
create table r2_stat_name as select distinct event_name stat_name from dba_hist_system_event;