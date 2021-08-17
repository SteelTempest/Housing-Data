SELECT *
FROM HousingData.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT (Date, SaleDate)
FROM HousingData.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populated Property Address Data

SELECT *
FROM HousingData.dbo.NashvilleHousing
--WHERE PropertyAddress IS null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, b.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM HousingData.dbo.NashvilleHousing A 
JOIN HousingData.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM HousingData.dbo.NashvilleHousing A 
JOIN HousingData.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS null

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM HousingData.dbo.NashvilleHousing
--WHERE PropertyAddress IS null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) AS Address

FROM HousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))

SELECT * 
FROM HousingData.dbo.NashvilleHousing

SELECT OwnerAddress
FROM HousingData.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)
FROM HousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)

SELECT * 
FROM HousingData.dbo.NashvilleHousing

--Changing Y and N to YES and NO in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM HousingData.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Removing Duplicates

WITH RowNumCTE AS(
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


FROM HousingData.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT * 
FROM HousingData.dbo.NashvilleHousing

-- Deleting Unused Columns

SELECT * 
FROM HousingData.dbo.NashvilleHousing

ALTER TABLE HousingData.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HousingData.dbo.NashvilleHousing
DROP COLUMN SaleDate