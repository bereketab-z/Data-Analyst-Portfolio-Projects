SELECT *
FROM NashvilleHousing$;

-- Standardize Date formate

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM NashvilleHousing$;

ALTER TABLE NashvillHousing$
ADD saleDateConverted DATE;

UPDATE NashvilleHousing$
SET saleDateConverted = CONVERT(DATE, SaleDate);

--Populate missing/Null property address

SELECT PropertyAddress
FROM NashvilleHousing$
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing$ a
JOIN NashvilleHousing$ b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing$ a
JOIN NashvilleHousing$ b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Breaking out address into indivdual columns (address, city, state)

SELECT *
FROM NashvilleHousing$

SELECT PropertyAddress
FROM NashvilleHousing$;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))
FROM NashvilleHousing$;

ALTER TABLE NashvilleHousing$
ADD PropertySlicedCity NVARCHAR(255);

ALTER TABLE NashvilleHousing$
ADD PropertySlicedAddress NVARCHAR(255);

UPDATE NashvilleHousing$
SET PropertySlicedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1);

UPDATE NashvilleHousing$
SET PropertySlicedCity = SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress));


SELECT OwnerAddress
FROM NashvilleHousing$;


SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),  3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),  2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),  1)
FROM NashvilleHousing$;


ALTER TABLE NashvilleHousing$
ADD OwnerSlicedAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing$
ADD OwnerSlicedCity NVARCHAR(255);

ALTER TABLE NashvilleHousing$
ADD OwnerSlicedState NVARCHAR(255);


UPDATE NashvilleHousing$
SET OwnerSlicedAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),  3);

UPDATE NashvilleHousing$
SET OwnerSlicedCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),  2);

UPDATE NashvilleHousing$
SET OwnerSlicedState = PARSENAME(REPLACE(OwnerAddress,',', '.'),  1);


--Change the 'Y' and 'N' to 'YES' and 'NO' in SoldAsVacant column

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM NashvilleHousing$;

UPDATE NashvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                   WHEN SoldAsVacant = 'N' THEN 'No'
                   ELSE SoldAsVacant
                   END;


--Remove Duplicates and unused Columns

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) row_num
FROM NashvilleHousing$
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



ALTER TABLE NashvilleHousing$
DROP COLUMN PropertyAddress, SaleDate,OwnerAddress, TaxDistrict

Select * 
FROM NashvilleHousing$;