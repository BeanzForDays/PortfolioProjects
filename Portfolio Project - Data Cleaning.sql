CREATE TABLE nashville_housing
(uniqueid integer,
parcelid text,
landuse text,
propertyaddress text,
saledate date,
saleprice decimal,
legalreference text,
soldasvacant text,
ownername varchar(60),
owneraddress text,
acreage decimal,
taxdistrict varchar(50),
landvalue decimal,
buildingvalue decimal,
totalvalue decimal,
yearbuilt text,
bedrooms decimal,
fullbath decimal,
halfbath decimal)

COPY nashville_housing
FROM 'C:\Users\Public\Nashville Housing Data for Data Cleaning.csv'
with (FORMAT CSV, header)

-- Breaking out Addresses into Individual Columns (Address, City, State)

--Splitting 'Property Address' with SUBSTRING funciton
SELECT SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) -1), 
SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) +1)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD property_split_address TEXT

ALTER TABLE nashville_housing
SET property_split_address = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) -1)

ALTER TABLE nashville_housing
ADD property_split_city TEXT

ALTER TABLE nashville_housing
SET property_split_city = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) +1)

--Splitting 'Onwer Address' with SPLIT_PART function
SELECT owneraddress, 
SPLIT_PART(owneraddress, ',', 1),
SPLIT_PART(owneraddress, ',', 2),
SPLIT_PART(owneraddress, ',', 3)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD owner_split_address TEXT

ALTER TABLE nashville_housing
SET owner_split_address = SPLIT_PART(owneraddress, ',', 1)

ALTER TABLE nashville_housing
ADD owner_split_city TEXT

ALTER TABLE nashville_housing
SET owner_split_city = SPLIT_PART(owneraddress, ',', 2)

ALTER TABLE nashville_housing
ADD owner_split_state TEXT

ALTER TABLE nashville_housing
SET owner_split_state = SPLIT_PART(owneraddress, ',', 3)

-- Converting 'Y' and 'N' into 'Yes' and 'No' in 'Sold as Vacant'

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant, 
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN  soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END
FROM nashville_housing

ALTER TABLE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes' 
						WHEN  soldasvacant = 'N' THEN 'No' 
						ELSE soldasvacant 
						END

--Remove Duplicates

WITH row_cte AS (
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY parcelid, 
				propertyaddress, 
				saleprice, 
				saledate, 
				legalreference 
	ORDER BY parcelid) row_num
FROM nashville_housing
)
SELECT * 
FROM row_cte
WHERE row_num > 1

DELETE 
FROM nashville_housing
WHERE  parcelid IN 
(SELECT parcelid FROM 
(SELECT parcelid, 
ROW_NUMBER() OVER(PARTITION BY parcelid, 
				propertyaddress, 
				saleprice, 
				saledate, 
				legalreference 
ORDER BY parcelid) AS row_num
FROM nashville_housing) nash
WHERE nash.row_num > 1 );

--Removing Unused Columns

ALTER TABLE nashville_housing
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress
