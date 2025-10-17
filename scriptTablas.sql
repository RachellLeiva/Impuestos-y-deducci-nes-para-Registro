USE [Taller/empleados];

CREATE TABLE organizations (
	id  INT PRIMARY KEY IDENTITY(1,1),
	nameOrganizations VARCHAR(30), 
	isActive BIT DEFAULT 1
);
CREATE TABLE departments (
	id  INT PRIMARY KEY IDENTITY(1,1),
	nameDepartment VARCHAR(30), 
	organizationId INT,
	isActive BIT DEFAULT 1
	CONSTRAINT FK_departments_organizations FOREIGN KEY (organizationId) 
    REFERENCES organizations(id),
);
CREATE TABLE Employee (
    Idcard VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(60),
    Lastname1 VARCHAR(30),
	Lastname2 VARCHAR(30) ,
    status BIT DEFAULT 1,
	departmentId INT,
	CONSTRAINT FK_Employee_departments FOREIGN KEY (departmentId) 
    REFERENCES departments(id),
);

CREATE TABLE GrossSalary (
	id INT PRIMARY KEY IDENTITY(1,1),
    employeeId VARCHAR(10) NOT NULL,
    grossSalary DECIMAL(12,2) NOT NULL,
    jobPosition VARCHAR(50) NOT NULL,
    startDate DATETIME NOT NULL,
    endDate DATETIME NULL,
    isActive BIT DEFAULT 1,
	fiscal BIT,
    CONSTRAINT FK_GrossSalary_Employee FOREIGN KEY (employeeId) 
    REFERENCES Employee(Idcard),
);

CREATE TABLE payrollPeriod (
    id INT PRIMARY KEY IDENTITY(1,1),
    period_number TINYINT NOT NULL,
    year SMALLINT NOT NULL,
    pay_date DATETIME NOT NULL
);

ALTER TABLE payrollPeriod 
ADD CONSTRAINT CheckPeriodNumber CHECK (period_number BETWEEN 1 AND 25);

CREATE TABLE PaymentSheet (
    grossSalaryId INT NOT NULL,
    periodId INT NOT NULL,
    totalDeductions DECIMAL(12,2) DEFAULT 0.00,
	totalTaxRent DECIMAL(12,2) DEFAULT 0.00,
    calculationDate DATETIME NOT NULL,
    net_salary DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_PaymentSheet PRIMARY KEY (grossSalaryId, periodId),
    CONSTRAINT FK_PaymentSheet_GrossSalary FOREIGN KEY (grossSalaryId) 
        REFERENCES GrossSalary(id),
    CONSTRAINT FK_PaymentSheet_Period FOREIGN KEY (periodId) 
        REFERENCES payrollPeriod(id)
);

CREATE TABLE deductions (
    deductionId INT PRIMARY KEY IDENTITY(1,1),
	nameDeduction VARCHAR(40),
    porcentage DECIMAL(7,4) NOT NULL,
    startDate DATETIME NOT NULL,
    endDate DATETIME 
);

CREATE TABLE employeeDeductions (
    deductionId INT NOT NULL,
    grossSalaryId INT NOT NULL,    
    periodId INT NOT NULL, 
    amountDeduc DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_EmployeeDeductions PRIMARY KEY (deductionId, grossSalaryId, periodId),
    CONSTRAINT FK_EmployeeDeductions_Deduction FOREIGN KEY (deductionId) 
        REFERENCES deductions(deductionId),
    CONSTRAINT FK_EmployeeDeductions_PaymentSheet FOREIGN KEY (grossSalaryId, periodId) 
        REFERENCES PaymentSheet(grossSalaryId, periodId),
);

CREATE TABLE employerCharge (
    id INT PRIMARY KEY IDENTITY(1,1),
	nameCharge VARCHAR(40),
    porcentage DECIMAL(7,4) NOT NULL,
    startDate DATETIME NOT NULL,
    endDate DATETIME
);

CREATE TABLE deductionByEmployerCharge (
    employerChargeld INT NOT NULL,
    periodId INT NOT NULL,
    totalDeduction DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_DeductionByEmployerCharge PRIMARY KEY (employerChargeld, periodId),
    CONSTRAINT FK_DeductionByEmployerCharge_Charge FOREIGN KEY (employerChargeld) 
        REFERENCES employerCharge(id),
    CONSTRAINT FK_DeductionByEmployerCharge_Period FOREIGN KEY (periodId) 
        REFERENCES payrollPeriod(id)
);

CREATE TABLE excessTaxRent (
    id INT PRIMARY KEY IDENTITY(1,1),
	startDate DATETIME,
	endDate DATETIME,
    descripcion VARCHAR(100) NOT NULL,
    lowerLimit DECIMAL(15,2) NOT NULL,
    upperLimit DECIMAL(15,2) NULL,
    porcentage DECIMAL(5,2) NOT NULL,
    isActive BIT DEFAULT 1
);

CREATE TABLE taxRentEmployee (
	employeeId VARCHAR(10),
	excessTaxRentId INT,
	periodId INT NOT NULL,
	isUpper BIT NOT NULL,
	amount DECIMAL(15,2) NOT NULL,
	 CONSTRAINT PK_taxRentEmployee PRIMARY KEY (employeeId, periodId,excessTaxRentId),
	 CONSTRAINT FK_taxRentEmployee_Period FOREIGN KEY (periodId) 
      REFERENCES payrollPeriod(id),
	   CONSTRAINT FK_taxRentEmployee_Employee FOREIGN KEY (employeeId) 
    REFERENCES Employee(Idcard),
	CONSTRAINT FK_taxRentEmployee_excessTaxRent FOREIGN KEY (excessTaxRentId) 
    REFERENCES excessTaxRent (id)
	);

CREATE TABLE creditFiscalFamily(
	id INT PRIMARY KEY IDENTITY(1,1),
	amount DECIMAL(7,2) NOT NULL,
	childrenOrPartner BIT NOT NULL, --1 para hijos 0 para cónyuge
	startDate DATETIME NOT NULL,
	endDate DATETIME,
	isActive BIT DEFAULT 1
	);

CREATE TABLE creditFiscalFamilyperEmployee(
	employeeId VARCHAR(10),
	startDate DATETIME NOT NULL,
	endDate DATETIME,
	havePartner BIT,
	children TINYINT,
	totalCredit DECIMAL (7,2),
	isActive BIT DEFAULT 1,
	CONSTRAINT PK_creditFiscalFamilyperEmployee PRIMARY KEY (employeeId, startDate),
	CONSTRAINT FK_creditFiscalFamilyperEmployee_Employee FOREIGN KEY (employeeId) 
    REFERENCES Employee(Idcard),
	);
	