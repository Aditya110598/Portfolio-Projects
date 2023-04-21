/*
Cleaning Data in SQL Queries
*/


Select *
From Project.dbo.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select *, CONVERT(Date,SaleDate) as SaleDateConverted
From Project.dbo.NashvilleHousing;


/*
  This code will not update the table.
  A SELECT statement only retrieves data from the table and does not modify the data in the table in any way. 
  If you want to update the data in the table, you would need to use an UPDATE statement
*/


Update project..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);


Select *
From Project.dbo.NashvilleHousing;


-- If it doesn't Work properly, Try this-


ALTER TABLE project..NashvilleHousing
Add SaleDateConverted Date;

Update project..NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS Date)



-- Populate Property Address data where Property Address is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Project.dbo.NashvilleHousing a
JOIN Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;


-- ISNULL() function is used to replace NULL values with a replacement value.
-- ISNULL(expression, replacement_value)


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Project.dbo.NashvilleHousing a
JOIN Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;



Select *
From Project.dbo.NashvilleHousing
where PropertyAddress is null;
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Project.dbo.NashvilleHousing;


-- SUBSTRING() function is used to extract a substring from a string.
-- SUBSTRING(string_expression, start, length)


-- CHARINDEX() function returns an integer value representing the position of the first occurrence of the specified string within the target string.
-- CHARINDEX(search_string, target_string, start_position)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Project.dbo.NashvilleHousing;


ALTER TABLE project..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update project..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE project..NashvilleHousing
Add PropertySplitCity Nvarchar(255);


Update project..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));


Select *
From Project.dbo.NashvilleHousing;



Select OwnerAddress
From Project.dbo.NashvilleHousing;


/* PARSENAME() function is used to parse an object name and return the specified part of the name.
   PARSENAME(object_name, part_number)
   The part_number can range from 1 to 4, with 1 being the rightmost part and 4 being the leftmost part.
   PARSENAME() can only handle up to four parts of a delimited string. 
   If you have more than four parts, you may need to use another method, such as SUBSTRING() or CHARINDEX().
*/


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Project.dbo.NashvilleHousing;


/* 
   REPLACE() function is used to replace all occurrences of a specified substring in a string with another substring.
   REPLACE(string_expression, substring_to_replace, replacement_substring)
   
   PARSENAME() function is designed to work with dot-separated values, so if the input string uses a different delimiter, such as a comma, 
   it needs to be replaced with a dot before calling the PARSENAME() function.
*/


ALTER TABLE Project.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);


Update Project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE Project.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


Update Project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);


ALTER TABLE Project.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);


Update Project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


Select *
From Project.dbo.NashvilleHousing;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2;



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Project.dbo.NashvilleHousing;


Update Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- ROW_NUMBER() function is a window function that assigns a unique sequential number to each row in a result set, starting at 1 for the first row.


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY UniqueID) as row_num
From Project.dbo.NashvilleHousing
)
Delete 
From RowNumCTE
Where row_num > 1;



WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY UniqueID) as row_num
From Project.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertySplitAddress;



Select *
From Project.dbo.NashvilleHousing;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



ALTER TABLE Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


Select *
From Project.dbo.NashvilleHousing;
