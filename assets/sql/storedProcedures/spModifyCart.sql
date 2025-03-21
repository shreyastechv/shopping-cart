DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS spModifyCart(
	IN productId INT,
	IN action VARCHAR(20), -- An action can be increment, decrement, or delete
	IN userId INT,
	OUT success BIT(1),
	OUT newQuantity INT,
	OUT productActualPrice DECIMAL(10,2),
	OUT productTax DECIMAL(10,2),
	OUT totalActualPrice DECIMAL(10,2),
	OUT totalTax DECIMAL(10,2)
)
BEGIN
	-- Error Handling
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		SET success = 0; -- 0 means false
		ROLLBACK;
	END;

	-- Setting default values for some out variables
	SET totalActualPrice = 0.0;
	SET totalTax = 0.0;


	START TRANSACTION;
		-- Add or Increment quantity
		IF action = 'increment' THEN
			INSERT INTO
				tblCart (
					fldProductId,
					fldUserId,
					fldQuantity
				)
			VALUES
				(productId, userId, 1)
			-- Increment quantity if product already exists in cart
			ON DUPLICATE KEY UPDATE fldQuantity = fldQuantity + 1;

		-- Decrement quantity
		ELSEIF action = 'decrement' THEN
			-- Update quantity
			UPDATE
				tblCart
			SET
				fldQuantity = fldQuantity - 1
			WHERE
				fldProductId = productId
				AND fldUserId = userId;

			-- Delete row if quantity is 0
			DELETE FROM
				tblCart
			WHERE
				fldQuantity = 0
				AND fldProductId = productId
				AND fldUserId = userId;

		-- Delete product from cart
		ELSEIF action = 'delete' THEN
			DELETE FROM
				tblCart
			WHERE
				fldProductId = productId
				AND fldUserId = userId;

		-- Handle invalid action
		ELSE
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid action. Allowed: increment, decrement, delete';

		END IF;

		-- Get the new quantity, total actual price and total tax of product after action
		SELECT
			C.fldQuantity,
			P.fldPrice * C.fldQuantity,
			P.fldPrice * C.fldQuantity * P.fldTax / 100
		INTO
			newQuantity,
			productActualPrice,
			productTax
		FROM
			tblCart C
			INNER JOIN tblProduct P ON P.fldProduct_Id = C.fldProductId
			AND P.fldActive = 1
		WHERE
			C.fldProductId = productId
			AND C.fldUserId = userId
		GROUP BY
			C.fldCart_Id;

		-- Get the total cart actual price and total cart tax after action
		SELECT
			SUM(P.fldPrice * C.fldQuantity),
			SUM(P.fldPrice * C.fldQuantity * P.fldTax / 100)
		INTO
			totalActualPrice,
			totalTax
		FROM
			tblCart C
			INNER JOIN tblProduct P ON P.fldProduct_Id = C.fldProductId
			AND P.fldActive = 1
		WHERE
			C.fldUserId = userId
		GROUP BY
			C.fldUserId;

	COMMIT;

	SET success = 1;
END $$

DELIMITER ;
