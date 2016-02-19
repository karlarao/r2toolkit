----------------------------------------------------------------------------------------
-- DROP TABLES
----------------------------------------------------------------------------------------

-- drop all the tables
select count(*) from r2_regression_data;
select count(*) from r2_outlier_data;
select count(*) from r2_stat_name;
select count(*) from r2_stat_name_top;
select count(*) from r2_y_value;
select count(*) from r2_x_value;
truncate table r2_regression_data;
truncate table r2_outlier_data;
truncate table r2_stat_name;
truncate table r2_stat_name_top;
truncate table r2_y_value;
truncate table r2_x_value;
drop table r2_regression_data purge;
drop table r2_outlier_data purge;
drop table r2_stat_name purge;
drop table r2_stat_name_top purge;
drop table r2_y_value purge;
drop table r2_x_value purge;