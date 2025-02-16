DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS spDeleteItem(
	IN item VARCHAR(20), -- An item can be category, subcategory, product, or productimage
	IN itemId INT,
	IN userId INT
)
BEGIN

	-- Delete category
	IF item = 'category' THEN
		UPDATE
			tblCategory C
				LEFT JOIN tblSubCategory SC ON SC.fldCategoryId = C.fldCategory_Id
				LEFT JOIN tblProduct P ON P.fldSubCategoryId = SC.fldSubCategory_Id
				LEFT JOIN tblProductImages PI ON PI.fldProductId = P.fldProduct_Id
		SET
			C.fldActive = 0,
			SC.fldActive = 0,
			P.fldActive = 0,
			PI.fldActive = 0
		WHERE
			C.fldCategory_Id = itemId;

	-- Delete sub category
	ELSEIF item = 'subcategory' THEN
		UPDATE
			tblSubCategory SC
				LEFT JOIN tblProduct P ON P.fldSubCategoryId = SC.fldSubCategory_Id
				LEFT JOIN tblProductImages PI ON PI.fldProductId = P.fldProduct_Id
		SET
			SC.fldActive = 0,
			P.fldActive = 0,
			PI.fldActive = 0
		WHERE
			SC.fldSubCategory_Id = itemId;

	-- Delete product
	ELSEIF item = 'product' THEN
		UPDATE
			tblProduct P
				LEFT JOIN tblProductImages PI ON PI.fldProductId = P.fldProduct_Id
		SET
			P.fldActive = 0,
			PI.fldActive = 0
		WHERE
			P.fldProduct_Id = itemId;

	-- Delete product image
	ELSEIF item = 'productimage' THEN
		UPDATE
			tblProductImages
		SET
			fldActive = 0
		WHERE
			fldProductImage_Id = itemId;

	-- Handle invalid item type
	ELSE
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Invalid item type. Allowed: category, subcategory, product, productimage';

	END IF;

END $$

DELIMITER ;
