--Data Cleaning Training

Select *
From [Project Portfolio]..Nashville_Housing

--Standardize Date Format

Select Sale_Date_Converted
From [Project Portfolio]..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD Sale_Date_Converted DATE;

UPDATE Nashville_Housing
Set Sale_Date_Converted = CONVERT(date, SaleDate)

--Property Address

Select *
From [Project Portfolio]..Nashville_Housing
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Project Portfolio]..Nashville_Housing a
JOIN [Project Portfolio]..Nashville_Housing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Project Portfolio]..Nashville_Housing a
JOIN [Project Portfolio]..Nashville_Housing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Break Address into different Columns

Select PropertyAddress
From [Project Portfolio]..Nashville_Housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From [Project Portfolio]..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Nashville_Housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity nvarchar(255);

UPDATE Nashville_Housing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select OwnerAddress
From [Project Portfolio]..Nashville_Housing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From [Project Portfolio]..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in SoldasVacant Column

Select Distinct(SoldAsVacant)
From [Project Portfolio]..Nashville_Housing

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Project Portfolio]..Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates
With RowNumCTE AS (
Select *,
  ROW_NUMBER() OVER (
  Partition by ParcelID,
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY
			    UniqueID
				) row_num
From [Project Portfolio]..Nashville_Housing
)
Select *
From RowNumCTE
Where row_num > 1

--Delete Unused Columns

Select *
From [Project Portfolio]..Nashville_Housing

ALTER TABLE [Project Portfolio]..Nashville_Housing
DROP COLUMN SaleDate
