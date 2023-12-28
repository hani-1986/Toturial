/*

Cleaning Data in SQL Queries

*/

Select *
From SQLToturial.dbo.Housing

-- Date Format
Alter Table Housing
ADD SalesDateConvert Date

Update Housing
Set SalesDateConvert = Convert(Date,SaleDate)

-- Populate Property Address data
Select ParcelID,PropertyAddress
From SQLToturial.dbo.Housing
--Where PropertyAddress is null
Order By ParcelID

Select A.[UniqueID ],A.ParcelID,A.PropertyAddress,B.[UniqueID ],B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
From SQLToturial.dbo.Housing A
Join SQLToturial.dbo.Housing B
  On A.ParcelID=B.ParcelID
  And A.[UniqueID ]<>B.[UniqueID ] 
Where A.PropertyAddress Is null

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From SQLToturial.dbo.Housing A
Join SQLToturial.dbo.Housing B
  On A.ParcelID=B.ParcelID
  And A.[UniqueID ]<>B.[UniqueID ] 
Where A.PropertyAddress Is null

  
--Individual Columns (Address, City, State)

Select PropertyAddress
from SQLToturial.dbo.Housing

Alter Table [Housing]
ADD city Varchar(255);

Update SQLToturial.dbo.Housing
set city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Alter Table [Housing]
ADD Address Varchar(255);

Update SQLToturial.dbo.Housing
set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Select OwnerAddress
From SQLToturial.dbo.Housing


Select PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQLToturial.dbo.Housing

Alter Table [Housing]
ADD OwnerSplitAddress Varchar(255);

Update SQLToturial.dbo.Housing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table [Housing]
ADD OwnerSplitCity Varchar(255);

Update SQLToturial.dbo.Housing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table [Housing]
ADD OwnerSplitStatus Varchar(255);

Update SQLToturial.dbo.Housing
set OwnerSplitStatus = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From SQLToturial.dbo.Housing
group by SoldAsVacant

Select Distinct(SoldAsVacant)
, Case When SoldAsVacant='N' Then 'NO'
       When SoldAsVacant='Y' Then 'Yes'
	   Else SoldAsVacant
	   End
From SQLToturial.dbo.Housing

Update [Housing]
Set SoldAsVacant =Case When SoldAsVacant='N' Then 'NO'
                       When SoldAsVacant='Y' Then 'Yes'
	                   Else SoldAsVacant
	                   End

-- Remove Duplicates
With CTEROWNUM AS
 (
Select *,
    ROW_NUMBER() Over (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
				   UniqueId
				   ) AS Row_num
From SQLToturial.dbo.Housing
--order by ParcelID
 ),
  DELROWNUM AS
 ( 
 Select *
 From CTEROWNUM
 Where Row_num > 1
 --Order By PropertyAddress
 )
 Delete 
 From DELROWNUM
 Where Row_num > 1
 

 -- Delete Unused Columns

 Select *
 From SQLToturial.dbo.Housing

 Alter Table SQLToturial.dbo.Housing
 Drop Column OwnerAddress,TaxDistrict,PropertyAddress

 Alter Table SQLToturial.dbo.Housing
 Drop Column SaleDate