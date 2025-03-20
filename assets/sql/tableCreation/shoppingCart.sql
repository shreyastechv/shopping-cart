use shoppingCart;
CREATE TABLE IF NOT EXISTS `tblRoles` (
  `fldRole_Id` INT NOT NULL AUTO_INCREMENT,
  `fldRoleName` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`fldRole_Id`));

CREATE UNIQUE INDEX `fld_roleId_UNIQUE` ON `tblRoles` (`fldRole_Id` ASC) VISIBLE;

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
    REFERENCES `tblRoles` (`fldRole_Id`));

CREATE INDEX `fldroleId_idx` ON `tblUser` (`fldRoleId` ASC) VISIBLE;

CREATE UNIQUE INDEX `fld_userid_UNIQUE` ON `tblUser` (`fldUser_Id` ASC) VISIBLE;

CREATE UNIQUE INDEX `fldEmail_UNIQUE` ON `tblUser` (`fldEmail` ASC) VISIBLE;

CREATE TABLE IF NOT EXISTS `tblAddress` (
  `fldAddress_Id` INT NOT NULL AUTO_INCREMENT,
  `fldUserId` INT NOT NULL,
  `fldFirstName` VARCHAR(32) NOT NULL,
  `fldLastName` VARCHAR(32) NULL,
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

-- Insert into brands table
INSERT INTO `tblbrands` VALUES
	(1,'Samsung',1),
	(2,'Sony',1),
	(3,'Others',1),
	(4,'iQOO',1),
	(5,'Apple',1),
	(6,'POCO',1),
	(7,'Motorola',1),
	(8,'OnePlus',1),
	(9,'realme',1),
	(10,'HONOR',1),
	(11,'Redmi',1),
	(12,'HP',1),
	(13,'Lenovo',1),
	(14,'Acer',1),
	(15,'MSI',1),
	(18,'ASUS',1),
	(19,'Epson',1),
	(20,'Canon',1),
	(21,'Brother',1),
	(22,'TSC',1),
	(23,'SHREYANS',1),
	(24,'SEZNIK',1),
	(25,'Amazon Basics',1),
	(26,'Ambrane',1),
	(27,'Zebronics',1),
	(28,'Seagull',1),
	(29,'Portronics',1),
	(30,'Noise',1),
	(31,'boAt',1),
	(32,'Godrej',1),
	(33,'LG',1),
	(34,'KENT',1),
	(35,'SVAAR',1),
	(36,'Milton',1),
	(37,'Lifelong',1),
	(38,'Protinex',1),
	(39,'Jawdrobe',1),
	(40,'Mom\'s Home',1);

INSERT INTO `tblRoles` (`fldRole_Id`, `fldRoleName`) VALUES (1, 'Admin');
INSERT INTO `tblRoles` (`fldRole_Id`, `fldRoleName`) VALUES (2, 'User');

-- Set product id + user id combination as unique so that insert query can be simpler
ALTER TABLE tblCart ADD UNIQUE (fldProductId, fldUserId);

CREATE TABLE `tblsliderimages` (
  `fldImage_Id` INT NOT NULL AUTO_INCREMENT,
  `fldPageName` VARCHAR(32) DEFAULT NULL,
  `fldImageFileName` VARCHAR(300) NOT NULL,
  `fldCreatedDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `fldDeactivatedDate` DATETIME DEFAULT NULL,
  `fldActive` TINYINT(1) DEFAULT '1',
  PRIMARY KEY (`fldImage_Id`)
) ENGINE=INNODB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data for the table `tblsliderimages`
INSERT  INTO `tblsliderimages`(`fldImage_Id`,`fldPageName`,`fldImageFileName`,`fldDeactivatedDate`,`fldActive`) VALUES
(1,'home','homepage-slider-1.jpg',NULL,1),
(2,'home','homepage-slider-2.jpg',NULL,1),
(3,'home','homepage-slider-3.jpg',NULL,1),
(4,'home','homepage-slider-4.jpg',NULL,1),
(5,'home','homepage-slider-5.jpg',NULL,1);