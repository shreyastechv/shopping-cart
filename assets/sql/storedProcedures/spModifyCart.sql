DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS spModifyCart(
	IN productId INT,
	IN action VARCHAR(20), -- An action can be increment, decrement, or delete
	IN userId INT
)
BEGIN

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
		START TRANSACTION;

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

		COMMIT;

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

END $$

DELIMITER ;
