DELIMITER $$

-- Create Order Stored Procedure Start
CREATE PROCEDURE spCreateOrderItems (
    IN p_orderId VARCHAR(64),
    IN p_userId INT,
    IN p_addressId INT,
    IN p_totalPrice DECIMAL(10,2),
    IN p_totalTax DECIMAL(10,2),
    IN p_jsonProducts JSON
)
BEGIN
    -- Insert into order table
    INSERT INTO
        tblOrder (
            fldOrder_Id,
            fldUserId,
            fldAddressId,
            fldTotalPrice,
            fldTotalTax
        )
    VALUES (
        p_orderId,
        p_userId,
        p_addressId,
        p_totalPrice,
        p_totalTax
    );

    -- Insert into order items table
    INSERT INTO
        tblOrderItems (
            fldOrderId,
            fldProductId,
            fldQuantity,
            fldUnitPrice,
            fldUnitTax
        )
    SELECT
        p_orderId,
        jt.fldProductId,
        jt.fldQuantity,
        jt.fldUnitPrice,
        jt.fldUnitTax
    FROM
        JSON_TABLE(
            p_jsonProducts,
            '$[*]' COLUMNS (
                fldProductId INT PATH '$.productId',
                fldQuantity INT PATH '$.quantity',
                fldUnitPrice DECIMAL(10,2) PATH '$.unitPrice',
                fldUnitTax DECIMAL(10,2) PATH '$.unitTax'
            )
        ) AS jt;

    -- Delete added products from cart table
    DELETE FROM
        tblCart
    WHERE
        fldUserId = p_userId
        AND fldProductId IN (
            SELECT
                productId
            FROM
                JSON_TABLE(
                    p_jsonProducts,
                    '$[*]' COLUMNS (
                        productId INT PATH '$.productId'
                    )
                ) AS jt
        );
END $$
-- Create Order Stored Procedure End

-- Delete Category Stored Procedure Start
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
-- Delete Category Stored Procedure End

DELIMITER ;
