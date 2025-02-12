use shoppingCart;
CREATE TABLE IF NOT EXISTS `tblRole` (
  `fldRole_Id` INT NOT NULL AUTO_INCREMENT,
  `fldRoleName` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`fldRole_Id`));

CREATE UNIQUE INDEX `fld_roleId_UNIQUE` ON `tblRole` (`fldRole_Id` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblUser` (
  `fldUser_Id` INT NOT NULL AUTO_INCREMENT,
  `fldFirstName` VARCHAR(32) NOT NULL,
  `fldLastName` VARCHAR(32) NULL,
  `fldEmail` VARCHAR(100) NOT NULL,
  `fldPhone` VARCHAR(15) NOT NULL,
  `fldRoleId` INT NOT NULL,
  `fldHashedPassword` VARCHAR(256) NOT NULL,
  `fldUserSaltString` VARCHAR(32) NOT NULL,
  `fldActive` TINYINT(1) NULL DEFAULT 1,
  `fldCreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fldUpdatedBy` INT NULL,
  `fldUpdatedDate` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`fldUser_Id`),
  CONSTRAINT `fldroleId`
    FOREIGN KEY (`fldRoleId`)
    REFERENCES `tblRole` (`fldRole_Id`));

CREATE INDEX `fldroleId_idx` ON `tblUser` (`fldRoleId` ASC) VISIBLE;

CREATE UNIQUE INDEX `fld_userid_UNIQUE` ON `tblUser` (`fldUser_Id` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldEmail_UNIQUE` ON `tblUser` (`fldEmail` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblAddress` (
  `fldAddress_Id` INT NOT NULL AUTO_INCREMENT,
  `fldUserId` INT NOT NULL,
  `fldFirstName` VARCHAR(32) NOT NULL,
  `fldlLastName` VARCHAR(32) NULL,
  `fldAddressLine1` VARCHAR(64) NULL,
  `fldAddressLine2` VARCHAR(64) NULL,
  `fldCity` VARCHAR(64) NULL,
  `fldState` VARCHAR(64) NULL,
  `fldPincode` VARCHAR(10) NULL,
  `fldPhone` VARCHAR(15) NOT NULL,
  `fldActive` TINYINT(1) NOT NULL DEFAULT 1,
  `fldCreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fldDeactivatedDate` DATETIME NULL,
  PRIMARY KEY (`fldAddress_Id`),
  CONSTRAINT `userid`
    FOREIGN KEY (`fldUserId`)
    REFERENCES `tblUser` (`fldUser_Id`));

CREATE INDEX `userid_idx` ON `tblAddress` (`fldUserId` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldAddress_Id_UNIQUE` ON `tblAddress` (`fldAddress_Id` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblOrder` (
  `fldOrder_Id` VARCHAR(64) NOT NULL,
  `fldUserId` INT NOT NULL,
  `fldAddressId` INT NOT NULL,
  `fldTotalPrice` DECIMAL(10,2) NOT NULL,
  `fldTotalTax` DECIMAL(10,2) NULL,
  `fldOrderDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`fldOrder_Id`),
  CONSTRAINT `tblOrder_userid`
    FOREIGN KEY (`fldUserId`)
    REFERENCES `tblUser` (`fldUser_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `addressid`
    FOREIGN KEY (`fldAddressId`)
    REFERENCES `tblAddress` (`fldAddress_Id`));

CREATE INDEX `userid_idx` ON `tblOrder` (`fldUserId` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldOrder_Id_UNIQUE` ON `tblOrder` (`fldOrder_Id` ASC) VISIBLE;

CREATE INDEX `addressid_idx` ON `tblOrder` (`fldAddressId` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblCategory` (
  `fldCategory_Id` INT NOT NULL AUTO_INCREMENT,
  `fldCategoryName` VARCHAR(64) NOT NULL,
  `fldActive` TINYINT(1) NOT NULL DEFAULT 1,
  `fldCreatedBy` INT NOT NULL,
  `fldCreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fldUpdatedBy` INT NULL,
  `fldUpdatedDate` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`fldCategory_Id`),
  CONSTRAINT `createdBy`
    FOREIGN KEY (`fldCreatedBy`)
    REFERENCES `tblUser` (`fldUser_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fldUpdatedBy`
    FOREIGN KEY (`fldUpdatedBy`)
    REFERENCES `tblUser` (`fldUser_Id`));

CREATE INDEX `createdBy_idx` ON `tblCategory` (`fldCreatedBy` ASC) VISIBLE;

CREATE UNIQUE INDEX `categoryId_UNIQUE` ON `tblCategory` (`fldCategory_Id` ASC) VISIBLE;

CREATE INDEX `fldUser_Id_idx` ON `tblCategory` (`fldUpdatedBy` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblSubCategory` (
  `fldSubCategory_Id` INT NOT NULL AUTO_INCREMENT,
  `fldCategoryId` INT NOT NULL,
  `fldSubCategoryName` VARCHAR(64) NULL,
  `fldActive` TINYINT(1) NOT NULL DEFAULT 1,
  `fldCreatedBy` INT NOT NULL,
  `fldCreatedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `fldUpdatedBy` INT NULL,
  `fldUpdatedDate` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`fldSubCategory_Id`),
  CONSTRAINT `categoryId`
    FOREIGN KEY (`fldCategoryId`)
    REFERENCES `tblCategory` (`fldCategory_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tblSubCategory_createdby`
    FOREIGN KEY (`fldCreatedBy`)
    REFERENCES `tblUser` (`fldUser_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tblSubCategory_fldUpdatedby`
    FOREIGN KEY (`fldUpdatedBy`)
    REFERENCES `tblUser` (`fldUser_Id`));

CREATE INDEX `categoryId_idx` ON `tblSubCategory` (`fldCategoryId` ASC) VISIBLE;

CREATE INDEX `createdby_idx` ON `tblSubCategory` (`fldCreatedBy` ASC) VISIBLE;

CREATE UNIQUE INDEX `subCategoryId_UNIQUE` ON `tblSubCategory` (`fldSubCategory_Id` ASC) VISIBLE;

CREATE INDEX `fldUpdatedby_idx` ON `tblSubCategory` (`fldUpdatedBy` ASC) VISIBLE;



CREATE TABLE IF NOT EXISTS `tblBrands` (
  `fldBrand_Id` INT NOT NULL AUTO_INCREMENT,
  `fldBrandName` VARCHAR(64) NOT NULL,
  `fldActive` TINYINT(1) NULL DEFAULT 1,
  PRIMARY KEY (`fldBrand_Id`));

CREATE UNIQUE INDEX `fldBrand_Id_UNIQUE` ON `tblBrands` (`fldBrand_Id` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblProduct` (
  `fldProduct_Id` INT NOT NULL AUTO_INCREMENT,
  `fldSubCategoryId` INT NOT NULL,
  `fldBrandId` INT NOT NULL,
  `fldProductName` VARCHAR(100) NOT NULL,
  `fldDescription` TEXT NULL,
  `fldPrice` DECIMAL(10,2) NULL,
  `fldActive` TINYINT(1) NOT NULL DEFAULT 1,
  `fldTax` DECIMAL(10,2) NULL,
  `fldCreatedBy` INT NOT NULL,
  `fldCreatedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `fldUpdatedBy` INT NULL,
  `fldUpdatedDate` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`fldProduct_Id`),
  CONSTRAINT `subcategoryId`
    FOREIGN KEY (`fldSubCategoryId`)
    REFERENCES `tblSubCategory` (`fldSubCategory_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tblProduct_createdBy`
    FOREIGN KEY (`fldCreatedBy`)
    REFERENCES `tblUser` (`fldUser_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tblProduct_fldUpdatedBy`
    FOREIGN KEY (`fldUpdatedBy`)
    REFERENCES `tblUser` (`fldUser_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tblProduct_brandId`
    FOREIGN KEY (`fldBrandId`)
    REFERENCES `tblBrands` (`fldBrand_Id`));

CREATE INDEX `subcategoryId_idx` ON `tblProduct` (`fldSubCategoryId` ASC) VISIBLE;

CREATE INDEX `createdBy_idx` ON `tblProduct` (`fldCreatedBy` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldProduct_Id_UNIQUE` ON `tblProduct` (`fldProduct_Id` ASC) VISIBLE;

CREATE INDEX `fldUpdatedBy_idx` ON `tblProduct` (`fldUpdatedBy` ASC) VISIBLE;

CREATE INDEX `brandId_idx` ON `tblProduct` (`fldBrandId` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblOrderItems` (
  `fldOrderItem_Id` INT NOT NULL AUTO_INCREMENT,
  `fldOrderId` VARCHAR(64) NOT NULL,
  `fldProductId` INT NOT NULL,
  `fldQuantity` INT NULL,
  `fldUnitPrice` DECIMAL(10,2) NULL,
  `fldUnitTax` DECIMAL(10,2) NULL,
  PRIMARY KEY (`fldOrderItem_Id`),
  CONSTRAINT `orderId`
    FOREIGN KEY (`fldOrderId`)
    REFERENCES `tblOrder` (`fldOrder_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `productid`
    FOREIGN KEY (`fldProductId`)
    REFERENCES `tblProduct` (`fldProduct_Id`));

CREATE INDEX `orderId_idx` ON `tblOrderItems` (`fldOrderId` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldOrderList_Id_UNIQUE` ON `tblOrderItems` (`fldOrderItem_Id` ASC) VISIBLE;

CREATE INDEX `productid_idx` ON `tblOrderItems` (`fldProductId` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblCart` (
  `fldCart_Id` INT NOT NULL AUTO_INCREMENT,
  `fldUserId` INT NOT NULL,
  `fldProductId` INT NOT NULL,
  `fldQuantity` INT NULL,
  `fldCreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`fldCart_Id`),
  CONSTRAINT `tblCart_userid`
    FOREIGN KEY (`fldUserId`)
    REFERENCES `tblUser` (`fldUser_Id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `tblCart_productId`
    FOREIGN KEY (`fldProductId`)
    REFERENCES `tblProduct` (`fldProduct_Id`));

CREATE INDEX `userid_idx` ON `tblCart` (`fldUserId` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldCart_Id_UNIQUE` ON `tblCart` (`fldCart_Id` ASC) VISIBLE;

CREATE INDEX `productId_idx` ON `tblCart` (`fldProductId` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblProductImages` (
  `fldProductImage_Id` INT NOT NULL AUTO_INCREMENT,
  `fldProductId` INT NOT NULL,
  `fldImageFileName` VARCHAR(128) NULL,
  `fldDefaultImage` TINYINT(1) NOT NULL DEFAULT 0,
  `fldActive` TINYINT(1) NOT NULL DEFAULT 1,
  `fldCreatedBy` INT NOT NULL,
  `fldCreatedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `fldDeactivatedBy` INT NULL,
  `fldDeactivatedDate` DATETIME NULL,
  PRIMARY KEY (`fldProductImage_Id`),
  CONSTRAINT `tblProductImages_productId`
    FOREIGN KEY (`fldProductId`)
    REFERENCES `tblProduct` (`fldProduct_Id`),
  CONSTRAINT `tblProductImages_createdBy`
    FOREIGN KEY (`fldCreatedBy` )
    REFERENCES `tblUser` (`fldUser_Id`),
     CONSTRAINT `tblProductImages_DeactivatedBy`
    FOREIGN KEY (`fldDeactivatedBy`)
    REFERENCES `tblUser` (`fldUser_Id`));

CREATE INDEX `productId_idx` ON `tblProductImages` (`fldProductId` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldImage_Id_UNIQUE` ON `tblProductImages` (`fldProductImage_Id` ASC) VISIBLE;

CREATE INDEX `createdBy_idx` ON `tblProductImages` (`fldCreatedBy` ASC, `fldDeactivatedBy` ASC) VISIBLE;


INSERT INTO `tblBrands` (`fldBrand_Id`, `fldBrandName`, `fldActive`) VALUES (1, 'Samsung', 1);
INSERT INTO `tblBrands` (`fldBrand_Id`, `fldBrandName`, `fldActive`) VALUES (2, 'Sony', 1);

INSERT INTO `tblRole` (`fldRole_Id`, `fldRoleName`) VALUES (1, 'Admin');
INSERT INTO `tblRole` (`fldRole_Id`, `fldRoleName`) VALUES (2, 'User');
