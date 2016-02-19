----------------------------------------------------------------------------------------
-- POPULATE y data
----------------------------------------------------------------------------------------

-- populate y axis
-- truncate table r2_regression_data;
insert into r2_regression_data (snap_id, tm, x_axis, y_axis)
select snap_id, tm, null, diff
from r2_y_value;
commit;


----------------------------------------------------------------------------------------
-- ANALYZE r2 VALUES systematically 
----------------------------------------------------------------------------------------

-- get r2 of each x axis independent value
-- truncate table r2_stat_name_top;
declare
cursor r2_stat_name is select stat_name from r2_stat_name;
    r2_count number;
    r2_r2 number; 
    stat_name varchar2(200);
begin
for table_scan in r2_stat_name loop
select 
       regr_count(y.y_axis,x.diff), regr_r2(y.y_axis,x.diff)
into   r2_count, r2_r2
from   
(
    select snap_id, y_axis from r2_regression_data
) y,
(
    select snap_id, diff from r2_x_value                                                             --<---- x value HERE!
    where stat_name = table_scan.stat_name
) x
where  x.snap_id = y.snap_id;
insert into r2_stat_name_top values (r2_count, r2_r2, table_scan.stat_name);
commit;
end loop;
end;
/


-- get top r2, choose above 90!
set lines 300
select * from 
(select regr_count, round(regr_r2,2) regr_r2, stat_name 
from r2_stat_name_top 
where regr_r2 > 0
and regr_count > 30
and stat_name != (select distinct stat_name from r2_y_value)
order by 2 desc)
where rownum < 31;


----------------------------------------------------------------------------------------
-- POPULATE x and residual data (portions below are by Neeraj Bhatia from the paper www.nioug.org/files/Linear_Regression.pdf)
----------------------------------------------------------------------------------------

-- populate x axis
/*
 update r2_regression_data set x_axis = null;
 update r2_regression_data set proj_y = null; 
 update r2_regression_data set residual = null; 
 update r2_regression_data set residual_sqr = null; 
 update r2_regression_data set stnd_residual = null;
*/
declare
  cursor c2 is 
    select snap_id, diff from r2_x_value                                  --<---- indicate specific x value (90 above) from the top r2 HERE!
    where stat_name = (select stat_name from 
                         (select regr_count, round(regr_r2,2) regr_r2, stat_name 
                         from r2_stat_name_top 
                         where regr_r2 > 0
                         and regr_count > 30
                         and stat_name != (select distinct stat_name from r2_y_value)
                         order by 2 desc)
                       where rownum < 2)               
    ;
begin
for table_scan in c2 loop
  update r2_regression_data set x_axis = table_scan.diff
  where snap_id = table_scan.snap_id;
commit;
end loop;
end;
/


-- regression analysis table - populate the residual and outlier data
declare
  outlier_count number;
  intercept number;
  slope number;
  stnd_dev number;
  avg_res number;
  cursor c1 is select 
    snap_id, tm, x_axis, y_axis, proj_y, residual, residual_sqr, stnd_residual
    from r2_regression_data;

  begin
    update r2_regression_data set stnd_residual = 4;

  select count(*) 
    into outlier_count
  from r2_regression_data
  where abs(stnd_residual) > 3;

  while outlier_count >0 loop
    select round(regr_intercept (y_axis, x_axis),8)
     into intercept 
  from r2_regression_data;
    select round(regr_slope (y_axis, x_axis),8) 
     into slope 
  from r2_regression_data;

  for table_scan in c1 loop
    update r2_regression_data set proj_y = slope * table_scan.x_axis + intercept 
    where snap_id = table_scan.snap_id;

    update r2_regression_data set residual = proj_y - y_axis
    where snap_id = table_scan.snap_id;

    update r2_regression_data set residual_sqr = residual * residual 
    where snap_id = table_scan.snap_id; 
  end loop;

  select round(avg(residual),8) 
     into avg_res 
  from r2_regression_data;
  
  select round(stddev(residual),8) 
     into stnd_dev
  from r2_regression_data;
  
  for table_scan2 in c1 loop
    update r2_regression_data set stnd_residual = (residual-avg_res)/stnd_dev where snap_id = table_scan2.snap_id;
  end loop;

  select count(*) 
     into outlier_count 
  from r2_regression_data where abs(stnd_residual) > 3;

  if outlier_count >0 then 
  for table_scan3 in c1 loop
      if abs(table_scan3.stnd_residual) > 3 then
        insert into r2_outlier_data (snap_id, tm, x_axis, y_axis, proj_y, residual, residual_sqr, stnd_residual) values
        (table_scan3.snap_id, table_scan3.tm, table_scan3.x_axis, table_scan3.y_axis, table_scan3.proj_y, table_scan3.residual, table_scan3.residual_sqr, table_scan3.stnd_residual);

        delete from r2_regression_data where snap_id = table_scan3.snap_id;
      end if;
  end loop;
  end if;
  end loop;
  commit; 
end;
/