/*
Data cleaning projects SQL
*/

-- Update saleprice and change the data type
SELECT *
FROM NashvilleHousing
WHERE SalePrice LIKE '%.%'

UPDATE NashvilleHousing
SET SalePrice = 120000
WHERE UniqueID = 39467

UPDATE NashvilleHousing
SET SalePrice = CASE UniqueID 
WHEN 25017 THEN 120000
WHEN 39539 THEN 362500
WHEN 17845 THEN 195000
WHEN 55748 THEN 1124900
WHEN 23307 THEN 195000
WHEN 17651 THEN 178500
WHEN 8996 THEN 159900
WHEN 1390 THEN 119000
WHEN 26950 THEN 35000
WHEN 57 THEN 35000
ELSE SalePrice
END 

SELECT *
FROM NashvilleHousing

-- change data type of saleprice, from nvarchar(50) to int

ALTER TABLE NashvilleHousing
ALTER COLUMN SalePrice INT

SELECT SaleDate
FROM NashvilleHousing

-- populate property address data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL

SELECT nash_a.ParcelID, nash_a.PropertyAddress, nash_b.PropertyAddress, ISNULL(nash_a.PropertyAddress,nash_b.PropertyAddress)
FROM NashvilleHousing as nash_a
INNER JOIN NashvilleHousing as nash_b
    ON nash_a.ParcelID = nash_b.ParcelID
    AND nash_a.UniqueID <> nash_b.UniqueID
WHERE nash_a.PropertyAddress is NULL

UPDATE nash_b
SET PropertyAddress = ISNULL(nash_a.PropertyAddress,nash_b.PropertyAddress)
FROM NashvilleHousing as nash_a
INNER JOIN NashvilleHousing as nash_b
    ON nash_a.ParcelID = nash_b.ParcelID
    AND nash_a.UniqueID <> nash_b.UniqueID

SELECT * 
FROM NashvilleHousing

-- breaking individual address into address, city, and state and added to new tables

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

-- update address coloumn
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- update city coloumn
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as city,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as state
FROM NashvilleHousing

ALTER TABLE NashvilleHousing ADD 
OwnerSplitAddress NVARCHAR(255), 
OwnerSplitCity NVARCHAR(255),
OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM NashvilleHousing

-- change Y and N to Yes and No in Sold as Vacant field

SELECT DISTINCT SoldAsVacant, Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
END
FROM NashvilleHousing
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
END

-- Remove Duplicates

WITH Row_numCTE AS (
SELECT *,
        ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SaleDate,
                     SalePrice,
                     LegalReference
                     ORDER BY UniqueID
                     ) as Row_Num
FROM NashvilleHousing
)

SELECT * 
FROM Row_numCTE
WHERE Row_num > 1

SELECT * FROM NashvilleHousing

-- Delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

