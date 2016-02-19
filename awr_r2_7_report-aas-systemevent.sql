set echo on
set pagesize 50000
set linesize 300
set serveroutput on

spool r2_report-aas-systemevent.txt
----------------------------------------------------------------------------------------
-- R2 REPORT
----------------------------------------------------------------------------------------
-- CPU used by this session %  = 1675794centi/100 = 16757sec
-- IO MB/s                     = ((C2*block_size)/1024/1024)/3600
-- select snap_id from (select * from r2_regression_data union all select * from r2_outlier_data);


-- get top r2, choose above 90!
select * from 
(select regr_count, round(regr_r2,2) regr_r2, stat_name 
from r2_stat_name_top 
where regr_r2 > 0
and regr_count > 30
and stat_name != (select distinct stat_name from r2_y_value)
order by 2 desc)
where rownum < 31;


-- get full r2 report & residual 
select snap_id, to_char(tm,'yy/mm/dd hh24:mi') tm, x_axis, y_axis, round(proj_y,2) proj_y, round(residual,2) residual, round(residual_sqr,2) residual_sqr, stnd_residual
from 
(select * from r2_regression_data
union all
select * from r2_outlier_data)
order by residual_sqr desc;


-- get full r2 report & residual without x null values
select snap_id, to_char(tm,'yy/mm/dd hh24:mi') tm, x_axis, y_axis, round(proj_y,2) proj_y, round(residual,2) residual, round(residual_sqr,2) residual_sqr, stnd_residual
from 
(select * from r2_regression_data
union all
select * from r2_outlier_data)
where x_axis is not null
order by residual_sqr desc;


-- cpu(y) centric r2 report
select a.snap_id, to_char(a.tm,'yy/mm/dd hh24:mi') tm, a.x_axis, a.y_axis, round(b.oracpupct,2) oracpupct, round(a.proj_y,2) proj_y, round(a.residual,2) residual, round(a.residual_sqr,2) residual_sqr, a.stnd_residual
from 
(select * from r2_regression_data
union all
select * from r2_outlier_data) a, r2_y_value b
where a.x_axis is not null
and a.snap_id = b.snap_id
-- and a.snap_id = 354
 order by a.residual_sqr desc
-- order by oracpupct desc
/


-- io(y) centric r2 report
select a.snap_id, to_char(a.tm,'yy/mm/dd hh24:mi') tm, a.x_axis, a.y_axis, round(b.iormbs,2) iormbs, round(a.proj_y,2) proj_y, round(a.residual,2) residual, round(a.residual_sqr,2) residual_sqr, a.stnd_residual
from 
(select * from r2_regression_data
union all
select * from r2_outlier_data) a, r2_y_value b
where a.x_axis is not null
and a.snap_id = b.snap_id
-- and a.snap_id = 354
 order by a.residual_sqr desc
-- order by iormbs desc
/


-- compare y to another column value
select regr_count(a.y_axis,b.oracpupct), regr_r2(a.y_axis,b.oracpupct)
from 
(select * from r2_regression_data
union all
select * from r2_outlier_data) a, r2_y_value b
where a.x_axis is not null
and a.snap_id = b.snap_id
 order by a.residual_sqr desc
/



-- get r2 
select regr_count(y_axis,x_axis), regr_r2(y_axis,x_axis) from
(select * from r2_regression_data
union all
select * from r2_outlier_data);


-- get r2 after removing outlier
select regr_count(y_axis,x_axis), regr_r2(y_axis,x_axis) from r2_regression_data;


-- get r2 of outlier
select regr_count(y_axis,x_axis), regr_r2(y_axis,x_axis) from r2_outlier_data;


-- get outlier data
select snap_id, to_char(tm,'yy/mm/dd hh24:mi') tm, x_axis, y_axis, round(proj_y,2) proj_y, round(residual,2) residual, round(residual_sqr,2) residual_sqr, stnd_residual
from r2_outlier_data 
where x_axis is not null
order by residual_sqr desc;


-- get statistical summary of data
declare
  s DBMS_STAT_FUNCS.SummaryType;
begin
  DBMS_STAT_FUNCS.SUMMARY('R2TOOLKIT','R2_REGRESSION_DATA','X_AXIS',5,s);
  dbms_output.put_line('SUMMARY STATISTICS');
  dbms_output.put_line('---------------------------');
  dbms_output.put_line('Count:	    '||s.count);
  dbms_output.put_line('Min:	      '||s.min);
  dbms_output.put_line('Max:	      '||s.max);
  dbms_output.put_line('Range:	    '||s.range);
  dbms_output.put_line('Mean:	      '||round(s.mean));
  dbms_output.put_line('Mode Count:	'||s.cmode.count);
  dbms_output.put_line('Mode:		    '||s.cmode(1));
  dbms_output.put_line('Variance:	  '||round(s.variance));
  dbms_output.put_line('Stddev:		  '||round(s.stddev));
  dbms_output.put_line('---------------------------');
  dbms_output.put_line('Quantile 5  ->	'||s.quantile_5);
  dbms_output.put_line('Quantile 25 ->	'||s.quantile_25);
  dbms_output.put_line('Median      ->  '||s.median);
  dbms_output.put_line('Quantile 75 ->	'||s.quantile_75);
  dbms_output.put_line('Quantile 95 ->	'||s.quantile_95);
  dbms_output.put_line('---------------------------');
  dbms_output.put_line('Extreme Count:	'||s.extreme_values.count);
  dbms_output.put_line('Extremes:	      '||s.extreme_values(1));
  dbms_output.put_line('Bottom 5:	      '||s.bottom_5_values(5)||','||s.bottom_5_values(4)||','||s.bottom_5_values(3)||','||s.bottom_5_values(4)||','||s.top_5_values(5));
  dbms_output.put_line('Top 5:		      '||s.top_5_values(1)||','||s.top_5_values(2)||','||s.top_5_values(3)||','||s.top_5_values(4)||','||s.top_5_values(5));
  dbms_output.put_line('---------------------------');
end;
/
declare
  s DBMS_STAT_FUNCS.SummaryType;
begin
  DBMS_STAT_FUNCS.SUMMARY('R2TOOLKIT','R2_REGRESSION_DATA','Y_AXIS',5,s);
  dbms_output.put_line('SUMMARY STATISTICS');
  dbms_output.put_line('---------------------------');
  dbms_output.put_line('Count:	    '||s.count);
  dbms_output.put_line('Min:	      '||s.min);
  dbms_output.put_line('Max:	      '||s.max);
  dbms_output.put_line('Range:	    '||s.range);
  dbms_output.put_line('Mean:	      '||round(s.mean));
  dbms_output.put_line('Mode Count:	'||s.cmode.count);
  dbms_output.put_line('Mode:		    '||s.cmode(1));
  dbms_output.put_line('Variance:	  '||round(s.variance));
  dbms_output.put_line('Stddev:		  '||round(s.stddev));
  dbms_output.put_line('---------------------------');
  dbms_output.put_line('Quantile 5  ->	'||s.quantile_5);
  dbms_output.put_line('Quantile 25 ->	'||s.quantile_25);
  dbms_output.put_line('Median      ->  '||s.median);
  dbms_output.put_line('Quantile 75 ->	'||s.quantile_75);
  dbms_output.put_line('Quantile 95 ->	'||s.quantile_95);
  dbms_output.put_line('---------------------------');
  dbms_output.put_line('Extreme Count:	'||s.extreme_values.count);
  dbms_output.put_line('Extremes:	      '||s.extreme_values(1));
  dbms_output.put_line('Bottom 5:	      '||s.bottom_5_values(5)||','||s.bottom_5_values(4)||','||s.bottom_5_values(3)||','||s.bottom_5_values(4)||','||s.top_5_values(5));
  dbms_output.put_line('Top 5:		      '||s.top_5_values(1)||','||s.top_5_values(2)||','||s.top_5_values(3)||','||s.top_5_values(4)||','||s.top_5_values(5));
  dbms_output.put_line('---------------------------');
end;
/
spool off
set echo off