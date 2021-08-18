


SELECT 
	*
FROM
	[PortfolioProject-02]..HousingData



SELECT LandUse, COUNT(LandUse) as 'Count'
FROM
	[PortfolioProject-02]..HousingData
GROUP BY
	LandUse
ORDER BY
	Count desc


-- Formatting "SaleDate" 

Alter table HousingData
Add SaleDateConverted Date;

update [PortfolioProject-02]..HousingData
set SaleDateConverted = Convert(date, SaleDate)

Alter table [PortfolioProject-02]..HousingData
Drop column SaleDate


-- Populating 'PropertyAddress'

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From [PortfolioProject-02]..HousingData as a
Join [PortfolioProject-02]..HousingData as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From [PortfolioProject-02]..HousingData as a
Join [PortfolioProject-02]..HousingData as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


--Splitting address columns into address, city, state.


--Property Address Split
Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress,
	Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
from [PortfolioProject-02]..HousingData


Alter table [PortfolioProject-02]..HousingData
add PropertyAddressSplit nvarchar(255), PropertyAddressCity nvarchar(255)

Update 
	[PortfolioProject-02]..HousingData
set 
	PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	PropertyAddressCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, len(PropertyAddress))

Alter table 
	[PortfolioProject-02]..HousingData
Drop column 
	PropertyAddress


--Owner Address Split
select
	PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
	PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
	PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From
	[PortfolioProject-02]..HousingData

Alter table [PortfolioProject-02]..HousingData
add OwnerAddressSplit nvarchar (255),OwnerAddressCity nvarchar(255), OwnerAddressState nvarchar(255)

Update [PortfolioProject-02]..HousingData
set OwnerAddressSplit = PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
	OwnerAddressCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
	OwnerAddressState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Alter table [PortfolioProject-02]..HousingData
Drop column OwnerAddress


--Replacing inconsistencies in SoldAs Vacant


Select distinct SoldAsVacant
From [PortfolioProject-02]..HousingData

Select 
	SoldAsVacant,
	Case
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	End
from		[PortfolioProject-02]..HousingData


Update
	[PortfolioProject-02]..HousingData
Set
	SoldAsVacant =  Case
						When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
					End


-- Deleting Duplicates


Select 
	ParcelID,
	PropertyAddressSplit,
	SaleDateConverted,
	SalePrice,
	count(*) as CNT
From
	[PortfolioProject-02]..HousingData
Group by
	ParcelID,
	PropertyAddressSplit,
	SaleDateConverted,
	SalePrice
Having
	COUNT(*) > 1
Order by
	CNT desc


Delete
From
	[PortfolioProject-02]..HousingData
Where
	UniqueID not in
		(
			Select max(UniqueId)
			from [PortfolioProject-02]..HousingData
			group by
				ParcelID,
				PropertyAddressSplit,
				SaleDateConverted,
				SalePrice
		);