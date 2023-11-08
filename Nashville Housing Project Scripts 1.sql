/* 
Cleaning Data in SQL Queries
*/

Select *
From [dbo].[NashvilleHousing]
-----------------------------------------------------------------------------------------
-- Standaridize Date Format

Select SaleDateCoverted, CONVERT(Date, SaleDate)
From [dbo].[NashvilleHousing]

Update NashvilleHousing 
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateCoverted Date

Update NashvilleHousing 
Set SaleDateCoverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From [dbo].[NashvilleHousing]
-- Where PropertyAddress is NULL
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [dbo].[NashvilleHousing] a
Join [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [dbo].[NashvilleHousing] a
Join [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


-----------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [dbo].[NashvilleHousing]
-- Where PropertyAddress is NULL
-- Order By ParcelID

Select 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Street,
Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From [dbo].[NashvilleHousing]

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress))



Select *
From [dbo].[NashvilleHousing]


Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From [dbo].[NashvilleHousing]

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

-----------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[NashvilleHousing]
Group By SoldAsVacant
Order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From [dbo].[NashvilleHousing]

Update [NashvilleHousing]
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

-----------------------------------------------------------------------------------------

--Remove Duplicates

Select *
From [dbo].[NashvilleHousing]


Select ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	Order By
	UniqueID	
	) row_num
From [dbo].[NashvilleHousing]
Order By ParcelID
-- Where row_num > 1

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	Order By
	UniqueID	
	) row_num
From [dbo].[NashvilleHousing]
-- Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1

-----------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [dbo].[NashvilleHousing]

Alter Table [NashvilleHousing]
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table [NashvilleHousing]
Drop Column SaleDate, LegalReference
