DELIMITER $$

CREATE PROCEDURE spCreateOrderItems (
	IN userId INT,
	IN addressId INT,
	IN jsonProducts JSON,
	OUT orderId VARCHAR(64),
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
				fldUserId,
				fldAddressId,
				fldTotalPrice,
				fldTotalTax
			)
		SELECT
			userId,
			addressId,
			SUM(P.fldPrice * fldQuantity) + SUM(P.fldPrice * fldQuantity * fldTax / 100) AS totalPrice,
			SUM(P.fldPrice * fldQuantity * fldTax / 100) AS totalTax
		FROM
			tblCart C
				INNER JOIN tblProduct P ON C.fldProductId = P.fldProduct_Id
					AND P.fldActive = 1
			WHERE
				C.fldUserId = userId
				AND C.fldProductId IN (
					SELECT
						JP.productId
					FROM
						JSON_TABLE(
							jsonProducts,
							'$[*]' COLUMNS (
								productId INT PATH '$.productId'
							)
						) AS JP
				)
			GROUP BY
				C.fldUserId;

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
			@lastOrderId, -- There is a trigger in the table that sets this value
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
