-- /*

-- Cleaning Data in SQL Queries

-- */


SELECT 
     *
FROM
    portfolioproject.dbo.NashvilleHousing



-- Standardize Date Format



SELECT 
     SaleDateConverted,
	 CONVERT(DATE, SaleDate)
FROM
    portfolioproject.dbo.NashvilleHousing



UPDATE portfolioproject.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)


ALTER TABLE portfolioproject.dbo.NashvilleHousing
ADD SaleDateConverted DATE



UPDATE portfolioproject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)



-- Populate Property Address Data
-- Addressing Property Address that is Null


SELECT 
     *
FROM
    portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT 
     a.ParcelID,
	 a.PropertyAddress,
	 b.ParcelID,
	 b.PropertyAddress,
	 ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
     portfolioproject.dbo.NashvilleHousing AS a
JOIN portfolioproject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
     portfolioproject.dbo.NashvilleHousing AS a
JOIN portfolioproject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL



-- Breaking Out Address into Individual Columns (Address, City, State)
-- Removing Comma (,) at the End of the Address & Spacing the Address


SELECT 
     PropertyAddress
FROM
    portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT
     SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM
    portfolioproject.dbo.NashvilleHousing


-- We can't Saparate two Values from one Column without Creating other two new Columns



ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE portfolioproject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))





Select 
      OwnerAddress
From   
     portfolioproject.dbo.NashvilleHousing



SELECT
     PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
    ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
    ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing






ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)






-- Change Y and N to Yes and No "Sold as Vacant" field


Select 
      Distinct(SoldAsVacant), 
	  Count(SoldAsVacant)
From 
     PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From 
    PortfolioProject.dbo.NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



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
From 
     PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From 
     RowNumCTE
Where row_num > 1
--Order by PropertyAddress




WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress






-- Delete Unused Columns



Select 
      *
From 
     PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate










