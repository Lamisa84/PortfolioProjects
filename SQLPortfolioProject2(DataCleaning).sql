/*

Cleaning Data in SQL Queries

*/


Select *
from PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate --CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)



--Alter Table PortfolioProject..NashvilleHousing
--Add SaleDateConverted Date;
--GO



-- Add the column only if it doesn't already exist
IF NOT EXISTS (
    SELECT 1 
    FROM PortfolioProject.INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'NashvilleHousing' 
      AND COLUMN_NAME = 'SaleDateConverted'
)
BEGIN
    ALTER TABLE PortfolioProject..NashvilleHousing 
    ADD SaleDateConverted Date;
    PRINT 'Column SaleDateConverted added.';
END
ELSE
BEGIN
    PRINT 'Column SaleDateConverted already exists. Skipping ALTER.';
END
GO
Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, Convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing




-------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET a.PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




-------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

--SELECT 
--    PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2) AS Address,
--    PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1) AS City
--FROM PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar (233);

UPDATE  PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing




SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3) AS Address
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2) AS City
,PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..NashvilleHousing





Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar (255);

UPDATE  PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2) 

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) 

SELECT *
FROM PortfolioProject..NashvilleHousing







---------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field 




Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END

FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END





---------------------------------------------------------------------------------------------------------

-- Remove Duplicates 



WITH RowNumCTE AS (
SELECT *,

ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             ORDER BY
             UniqueID
             ) row_num


FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID

)


--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress







-------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate




