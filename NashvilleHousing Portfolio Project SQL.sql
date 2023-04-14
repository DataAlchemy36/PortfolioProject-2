/*

Cleaning Data in SQL Queries 

*/

SELECT *
FROM portfolioproject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format



SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM portfolioproject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data 



SELECT *
FROM portfolioproject.dbo.NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


----------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



SELECT PropertyAddress
FROM portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress1 NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity1 NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity1 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM portfolioproject.dbo.NashvilleHousing



SELECT OwnerAddress
FROM portfolioproject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress1 NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress1 = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity1 NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity1 = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)



----------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field



SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM portfolioproject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



----------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates



WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



----------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate