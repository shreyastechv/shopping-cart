DELIMITER $$

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
        JP.fldProductId,
        JP.fldQuantity,
        P.fldPrice,
        P.fldTax
    FROM
        JSON_TABLE(
            p_jsonProducts,
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
                ) AS JP
        );
END $$

DELIMITER ;
