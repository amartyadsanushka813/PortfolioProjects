-- Cleaning data in SQL Queries

Select * 
From PortfolioProject.dbo.housing

-- Changing Date Format (Removing the time)

Alter Table housing
Add SaleDateConverted Date;

Update housing
Set SaleDateConverted = Convert (Date, SaleDate )


Select SaleDateConverted
From PortfolioProject.dbo.housing

-- Populating NULLs in property address based on ParcelID

Select *
From housing
Order by ParcelID

      -- Self Join
Select original.[UniqueID ], original.ParcelID, original.PropertyAddress, original.[UniqueID ], copyhouse.ParcelID, copyhouse.PropertyAddress
From housing original
JOIN housing copyhouse
	ON  original.ParcelID = copyhouse.ParcelID -- same ParcelID
	And original.[UniqueID ] <> copyhouse.[UniqueID ] -- Different UniqueID


Update original
Set original.PropertyAddress =  ISNULL(original.PropertyAddress, copyhouse.PropertyAddress)
From housing original
JOIN housing copyhouse
	ON  original.ParcelID = copyhouse.ParcelID -- same ParcelID
	And original.[UniqueID ] <> copyhouse.[UniqueID ] -- Different UniqueID
where original.PropertyAddress is null

-- Breaking down Property address into individual columns SUBSTRING(Address, City)

Select PropertyAddress
From housing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
From housing

Select SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From housing

Alter Table housing
Add PropertySplitAddress Nvarchar(255);

Update housing
Set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table housing
Add PropertySplitCity Nvarchar(255);

Update housing
Set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select*From housing

-- Breaking down Owner address into individual columns using PARSENAME (Address, Ciyt, State)

Select OwnerAddress
From housing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From housing


Alter Table housing
Add OwnerSplitAddress Nvarchar(255);

Update housing
Set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table housing
Add OwnerSplitCity Nvarchar(255);

Update housing
Set OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table housing
Add OwnerSplitState Nvarchar(255);

Update housing
Set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in 'SoldAsVacant' column

Select SoldAsVacant, COUNT(SoldAsVacant)
From housing
group by SoldAsVacant
order by 2

Select SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
From housing

Update housing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
					END

-- Remove Duplicates (cutting down the data form ~700,000 to ~56000)


With RowNumCTE AS(
Select *, ROW_NUMBER() OVER (Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
From housing
)
DELETE
From RowNumCTE
Where row_num > 1


select*
From housing



-- Removing Unused/modified columns

Alter Table housing
Drop Column SaleDate, OwnerAddress, PropertyAddress

Select *
From housing



