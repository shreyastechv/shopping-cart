DELIMITER $$

CREATE PROCEDURE spCreateOrderItems (
    IN orderId VARCHAR(64),
    IN userId INT,
    IN addressId INT,
    IN totalPrice DECIMAL(10,2),
    IN totalTax DECIMAL(10,2),
    IN jsonProducts JSON,
	OUT success BIT(1)
)
BEGIN
	-- Error Handling
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SET success = 0; -- 0 means false
		ROLLBACK;
	END;

	START TRANSACTION;
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
			orderId,
			userId,
			addressId,
			totalPrice,
			totalTax
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
			orderId,
			JP.fldProductId,
			JP.fldQuantity,
			P.fldPrice,
			P.fldTax
		FROM
			JSON_TABLE(
				jsonProducts,
				'$[*]' COLUMNS (
					fldProductId INT PATH '$.productId',
					fldQuantity INT PATH '$.quantity'
				)
			) AS JP
		JOIN tblProduct P
			ON JP.fldProductId = P.fldProduct_Id;

		-- Delete added products from cart table
		DELETE FROM
			tblCart
		WHERE
			fldUserId = userId
			AND fldProductId IN (
				SELECT
					productId
				FROM
					JSON_TABLE(
						jsonProducts,
						'$[*]' COLUMNS (
							productId INT PATH '$.productId'
						)
					) AS JP
			);
	COMMIT;

	SET success = 1;
END $$

DELIMITER ;
