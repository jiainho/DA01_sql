-- 01: Data Type Cleaning - Chuyển đổi kiểu dữ liệu phù hợp cho các trường (sử dụng ALTER)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN priceeach TYPE numeric USING (priceeach::numeric),
ALTER COLUMN ordernumber TYPE numeric USING (ordernumber::numeric),
ALTER COLUMN quantityordered TYPE numeric USING (quantityordered::numeric),
ALTER COLUMN orderlinenumber TYPE numeric USING (orderlinenumber::numeric),
ALTER COLUMN sales TYPE numeric USING (sales::numeric),
ALTER COLUMN orderdate TYPE timestamp USING (orderdate::timestamp),
ALTER COLUMN msrp TYPE numeric USING (msrp::numeric)

-- 02: Check Null/Blank(")
select * from SALES_DATASET_RFM_PRJ
where (ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE) is null 

-- 03: Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME,
  --chuẩn hóa theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD CONTACTFIRSTNAME  VARCHAR
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD CONTACTLASTNAME VARCHAR

UPDATE SALES_DATASET_RFM_PRJ
SET CONTACTFIRSTNAME  =
INITCAP(LEFT(CONTACTFULLNAME,POSITION('-' IN CONTACTFULLNAME)-1))

UPDATE SALES_DATASET_RFM_PRJ
SET CONTACTLASTNAME = 
INITCAP(SUBSTRING(CONTACTFULLNAME FROM POSITION('-' IN CONTACTFULLNAME)+1))

-- 04: Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Quý, tháng, năm được lấy ra từ ORDERDATE
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD QTR_ID  INT,
ADD MONTH_ID  INT,
ADD YEAR_ID  INT;

UPDATE SALES_DATASET_RFM_PRJ
SET QTR_ID = CEIL(EXTRACT(MONTH FROM ORDERDATE)/3),
MONTH_ID = EXTRACT(MONTH FROM ORDERDATE),
YEAR_ID = EXTRACT(YEAR FROM ORDERDATE)

-- 05:
with twt_min_max_value as(
select Q1-1.5*IQR as min_value,
Q3+1.5*IQR as max_value
from(
select 
percentile_cont(0.25) within group (order by QUANTITYORDERED) as Q1,
percentile_cont(0.75) within group (order by QUANTITYORDERED) as Q3,
percentile_cont(0.75) within group (order by QUANTITYORDERED)
-percentile_cont(0.25) within group (order by QUANTITYORDERED) as IQR
from SALES_DATASET_RFM_PRJ) as a) 

--Bước 3 - xác định outlier < min or > max
select * from SALES_DATASET_RFM_PRJ
where QUANTITYORDERED < (select min_value from twt_min_max_value)
or QUANTITYORDERED > (select max_value from twt_min_max_value)

-- xử lý giá trị ngoại lai (bỏ lun, thay thế)
UPDATE SALES_DATASET_RFM_PRJ
SET quantityordered = (select avg(quantityordered)
from SALES_DATASET_RFM_PRJ)
where QUANTITYORDERED < (select min_value from twt_min_max_value)
or QUANTITYORDERED > (select max_value from twt_min_max_value)

DELETE FROM SALES_DATASET_RFM_PRJ
where QUANTITYORDERED < (select min_value from twt_min_max_value)
or QUANTITYORDERED > (select max_value from twt_min_max_value)


-- 06: Sau khi làm sạch dữ liệu, lưu vào bảng mới tên SALES_DATASET_RFM_PRJ_CLEAN
create table SALES_DATASET_RFM_PRJ_CLEAN as
select * from SALES_DATASET_RFM_PRJ
