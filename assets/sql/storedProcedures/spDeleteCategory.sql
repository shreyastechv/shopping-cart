DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS spDeleteCategory(
	IN categoryId INT,
	IN userId INT
)
BEGIN
	-- Delete products
	UPDATE
		tblProduct
	SET
		fldActive = 0,
		fldUpdatedBy = userId
	WHERE
		fldSubCategoryId IN (
			SELECT
				fldSubCategory_Id
			FROM
				tblSubCategory
			WHERE
				fldCategoryId = categoryId
		);

	-- Delete subcategory
	UPDATE
		tblSubCategory
	SET
		fldActive = 0,
		fldUpdatedBy = userId
	WHERE
		fldCategoryId = categoryId;

	-- Delete category
	UPDATE
		tblCategory
	SET
		fldActive = 0,
		fldUpdatedBy = userId
	WHERE
		fldCategory_Id = categoryId;
END $$

DELIMITER ;