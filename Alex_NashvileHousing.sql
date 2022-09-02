Use PortfolioProject
Select *
From dbo.NashvileHousing

-- Standardaize Date Format using CONVERT

Select SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvileHousing;

ALTER TABLE NashvileHousing
ADD SaleDAteConverted Date;

UPDATE NashvileHousing 
SET SaleDAteConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
FROM PortfolioProject.dbo.NashvileHousing;

--------------------------------------------------
--- Populate property address data
------------------------------------------------
Select * --PropertyAddress 
From PortfolioProject.dbo.NashvileHousing
--where propertyAddress is null
order by ParcelID;

-------
-------
Select a.ParcelID, a.PropertyAddress, 
       b.ParcelID, b.PropertyAddress,
	   ISNULL(a.PropertyAddress,b.PropertyAddress)

From PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

Where a.PropertyAddress is Null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is Null


--------------------------------------------------
-- Breaking out Address into Individual Columns (address, City, State)
---------------------------------------------------

Select PropertyAddress 
From PortfolioProject.dbo.NashvileHousing
--where propertyAddress is null
--order by ParcelID;

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address

, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvileHousing

-------------------------------------------------------------

--we gonna add two columns
-----------------------------
ALTER TABLE NashvileHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvileHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvileHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvileHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvileHousing


----------------
--Let's change Owner Address BUT Instead of Substring
-- we will use PARSENAME which is easier than Substring
---------------
Select OwnerAddress
From PortfolioProject.dbo.NashvileHousing

Select PARSENAME(REPLACE(OwnerAddress, ',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2) 
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvileHousing

--- now lets add columns and popoulate them using Set
ALTER TABLE NashvileHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvileHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

-----------

ALTER TABLE NashvileHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvileHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

----------------
ALTER TABLE NashvileHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvileHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


---- Now lets quickly look
Select *
From PortfolioProject.dbo.NashvileHousing


---------------------------------------
----------------------
------ Cahneg Y and N to Yes and No in "Sold as Vacant" field
-------------------------------
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvileHousing
Group by SoldAsVacant
Order by 2

-- To change Y and N to YEs and No WE can use Case Statement
Select SoldAsVacant,
	CASE 
	WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END 
From PortfolioProject.dbo.NashvileHousing

-- now lets update the table with the case statement
UPDATE NashvileHousing
SET SoldAsVacant = 	
    CASE 
	WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END 

	--------------------------------------
	---REMOVE DUPLICATES
	--------------------------------------
	-- It;s not a common practice though..
	--find the duplicate valuess first. we want to PARTITION our data.
	-- we need to identify our data using rank, dense rank, row-numbers etc

	WITH RowNumCTE AS(
	Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress,
	            SalePrice,	SaleDate, LegalReference
	ORDER BY UniqueID 
	               ) row_num
	From PortfolioProject.dbo.NashvileHousing
	--Order by parcelID
	) 
	Select *
	From RowNumCTE
	where row_num >1
	Order by PropertyAddress

---------------------------
	--- Now that we found 104 of the rows are 
	---duplicated, we gonna get rid of them by using DELETE
-------------------------------------

	WITH RowNumCTE AS(
	Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress,
	            SalePrice,	SaleDate, LegalReference
	ORDER BY UniqueID 
	               ) row_num
	From PortfolioProject.dbo.NashvileHousing
	--Order by parcelID
	) 
	DELETE 
	From RowNumCTE
	where row_num >1
	--Order by PropertyAddress


-------------------------------
	------------------------
	---NOW Lets DELETE Unused Columns 
	-------------------------------------------------------------
Select *
From PortfolioProject.dbo.NashvileHousing

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN SaleDate
