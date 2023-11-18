select *
from [Porfolio project].dbo.Housing

--cleaning data in sql

--saledate change 

select SaleDate, CONVERT(Date,SaleDate)
from [Porfolio project].dbo.Housing

update Housing
SET SaleDate = CONVERT(Date,SaleDate)

alter table Housing 
Add SaleDateConverted Date;

--Peoples property address data 

select *
from [Porfolio project].dbo.Housing
--Where PropertyAddress is Null
order by ParcelID

select AZ.ParcelID, AZ.PropertyAddress, BZ.ParcelID, BZ.PropertyAddress, ISNULL(AZ.PropertyAddress,BZ.PropertyAddress)
from [Porfolio project].dbo.Housing as AZ
Join [Porfolio project].dbo.Housing as BZ
	 on AZ.ParcelID = BZ.ParcelID
	 and AZ.[UniqueID ] <> BZ.[UniqueID ]
Where AZ.PropertyAddress is null 

update AZ
set PropertyAddress = ISNULL(AZ.PropertyAddress,BZ.PropertyAddress)
from [Porfolio project].dbo.Housing as AZ
Join [Porfolio project].dbo.Housing as BZ
	 on AZ.ParcelID = BZ.ParcelID
	 and AZ.[UniqueID ] <> BZ.[UniqueID ]


--breaking out addresses into Address and city 

select PropertyAddress
from [Porfolio project].dbo.Housing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From dbo.Housing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as  City
From [Porfolio project].dbo.Housing

update Housing
SET PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table Housing 
Add PropertyAddress nvarchar(255)

update Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

alter table Housing 
Add PropertyCity nvarchar (255)

select *
from [Porfolio project].dbo.Housing

--owners address 

select OwnerAddress
from [Porfolio project].dbo.Housing

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [Porfolio project].dbo.Housing


update Housing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table Housing 
Add OwnerSplitAddress nvarchar(255)

update Housing
SET OwnerScreamCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table Housing 
Add OwnerScreamCity nvarchar (255)

update Housing
SET OwnerSameState = PARSENAME(replace(OwnerAddress,',','.'),1)

alter table Housing 
Add OwnerSameState nvarchar (255)

select OwnerSplitAddress, OwnerScreamCity, OwnerSameState
From [Porfolio project].dbo.Housing

--Change Y and N to yes and NO in sold as Vacant

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Porfolio project].dbo.Housing
group by SoldAsVacant
order by 1

select SoldAsVacant,
Case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'NO'
	else SoldAsVacant
	END
from [Porfolio project].dbo.Housing

update Housing
set SoldAsVacant = Case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'NO'
	else SoldAsVacant
	END

-- Remove Duplicates

With row_numCTE as(
select * ,
ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	Order by UniqueID) as row_num

from [Porfolio project].dbo.Housing
--order by ParcelID
)
select *
from row_numCTE
where row_num > 1
Order by PropertyAddress
select * 
from [Porfolio project].dbo.Housing

--Delete Unused columns 


select*
from [Porfolio project].dbo.Housing

Alter Table [Porfolio project].dbo.Housing
Drop Column OwnerAddress, PropertyAddress,SaleDate

Alter Table [Porfolio project].dbo.Housing
Drop Column SaleDate
