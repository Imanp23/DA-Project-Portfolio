
--DATA CLEANING NASHVILLE HOUSING DATASET

--------------------------------------------------------------------------------------------------------------------------


--MAKE A BACKUP OF ORIGINAL DATA TO BE CLEANED  
  
  SELECT * INTO nashvillehousing_bkup
  FROM nashville_housing_aa



--------------------------------------------------------------------------------------------------------------------------
--VIEW DATA TO BE CLEANED

  SELECT * 
  FROM nashville_housing_aa



  --------------------------------------------------------------------------------------------------------------------------
  
  -- STANDARDIZE DATE FORMAT
  

  SELECT SaleDate, CONVERT(date, SaleDate)
  FROM nashville_housing_aa


  ALTER TABLE nashville_housing_aa
  ADD SaleDateConverted Date

  UPDATE nashville_housing_aa
  SET SaleDateConverted = CONVERT(date, SaleDate)



   --------------------------------------------------------------------------------------------------------------------------

   -- POPULATE PROPERTY ADDRESS DATA
		
		--Self Join The table and locate data for populating null rows 


SELECT a.ParcelID,  a.PropertyAddress , b.ParcelID, b.PropertyAddress
FROM nashville_housing_aa a
JOIN nashville_housing_aa b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

		
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL(a.PropertyAddress, 'No Address') A STRING BE USED ALSO
FROM nashville_housing_aa a
JOIN nashville_housing_aa b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



   --------------------------------------------------------------------------------------------------------------------------

   -- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
	
		--Property Address Split 


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
   ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as AddressState
FROM nashville_housing_aa


ALTER TABLE nashville_housing_aa
ADD PropertySplitAddress Nvarchar(255)

UPDATE nashville_housing_aa
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
FROM nashville_housing_aa


ALTER TABLE nashville_housing_aa
ADD PropertySplitCity Nvarchar(255)

UPDATE nashville_housing_aa
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) 
FROM nashville_housing_aa


		--Owner Address Split 
				

select PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) as OwnerSplitAddress
	  ,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) as OwnerSplitCity
	  ,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) as OwnerSplitState
FROM nashville_housing_aa


ALTER TABLE nashville_housing_aa
ADD OwnerSplitAddress  Nvarchar(255)

UPDATE nashville_housing_aa
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
FROM nashville_housing_aa


ALTER TABLE nashville_housing_aa
ADD OwnerSplitCity Nvarchar(255)

UPDATE nashville_housing_aa
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
FROM nashville_housing_aa


ALTER TABLE nashville_housing_aa
ADD OwnerSplitState Nvarchar(255)

UPDATE nashville_housing_aa
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM nashville_housing_aa



   --------------------------------------------------------------------------------------------------------------------------

   -- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 
FROM nashville_housing_aa

UPDATE nashville_housing_aa
SET SoldAsVacant = 
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 
FROM nashville_housing_aa



   -----------------------------------------------------------------------------------------------------------------------------------------------------------

   -- REMOVE DUPLICATES

WITH rwcte AS
(SELECT ROW_NUMBER() OVER(
	   PARTITION BY parcelid
				   ,PropertyAddress
				   ,SalePrice
				   ,SaleDate
				   ,LegalReference
				   ORDER BY
				    Uniqueid
					  ) row_num
					  ,*
from nashville_housing_aa
) 
delete
FROM rwcte
where row_num > 1



   ---------------------------------------------------------------------------------------------------------

   -- Delete Unused Columns

ALTER TABLE nashville_housing_aa
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


