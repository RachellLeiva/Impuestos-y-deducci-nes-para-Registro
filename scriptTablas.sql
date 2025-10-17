USE [Taller/empleados];

CREATE TABLE Employee (
    Idcard VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(60) NOT NULL,
    Lastname VARCHAR(60) NOT NULL,
    status BIT DEFAULT 1
);

CREATE TABLE GrossSalary (
    employeesId VARCHAR(20) NOT NULL,
    grossSalary DECIMAL(12,2) NOT NULL,
    jobPosition VARCHAR(50) NOT NULL,
    startDate DATETIME NOT NULL,
    endDate DATETIME NULL,
    isActive BIT DEFAULT 1,
    CONSTRAINT FK_GrossSalary_Employee FOREIGN KEY (employeesId) 
    REFERENCES Employee(Idcard)
);

CREATE TABLE payrollPeriod (
    id INT PRIMARY KEY,
    period_number TINYINT NOT NULL,
    year SMALLINT NOT NULL,
    pay_date DATETIME NOT NULL}
);

ALTER TABLE payrollPeriod 
ADD CONSTRAINT CheckPeriodNumber CHECK (period_number BETWEEN 1 AND 25);

CREATE TABLE PaymentSheet (
    grossSalaryId INT NOT NULL,
    periodId INT NOT NULL,
    totalDeductions DECIMAL(12,2) DEFAULT 0.00,
    calculationDate DATETIME NOT NULL,
    net_salary DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_PaymentSheet PRIMARY KEY (grossSalaryId, periodId),
    CONSTRAINT FK_PaymentSheet_GrossSalary FOREIGN KEY (grossSalaryId) 
        REFERENCES GrossSalary(id),
    CONSTRAINT FK_PaymentSheet_Period FOREIGN KEY (periodId) 
        REFERENCES payrollPeriod(id)
);

CREATE TABLE deductions (
    deductionId INT PRIMARY KEY,
    porcentage DECIMAL(5,2) NOT NULL,
    startDate DATETIME NOT NULL,
    endDate DATETIME 
);

CREATE TABLE employeeDeductions (
    deductionId INT NOT NULL,
    paymentSheetId INT NOT NULL,
    amountDeduc DECIMAL(10,2) NOT NULL,
    periodId INT NOT NULL,
    CONSTRAINT PK_EmployeeDeductions PRIMARY KEY (deductionId, paymentSheetId),
    CONSTRAINT FK_EmployeeDeductions_Deduction FOREIGN KEY (deductionId) 
        REFERENCES deductions(deductionId),
    CONSTRAINT FK_EmployeeDeductions_PaymentSheet FOREIGN KEY (paymentSheetId) 
        REFERENCES PaymentSheet(grossSalaryId),
    CONSTRAINT FK_EmployeeDeductions_Period FOREIGN KEY (periodId) 
        REFERENCES payrollPeriod(id)
);

CREATE TABLE employerCharge (
    id INT PRIMARY KEY,
    porcentage DECIMAL(5,2) NOT NULL,
    startDate DATETIME NOT NULL,
    endDate DATETIME
);

CREATE TABLE deductionByEmployerCharge (
    employerChargeld INT NOT NULL,
    periodId INT NOT NULL,
    totalDeduction DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_DeductionByEmployerCharge PRIMARY KEY (employerChargeld, periodId),
    CONSTRAINT FK_DeductionByEmployerCharge_Charge FOREIGN KEY (employerChargeld) 
        REFERENCES employerCharge(id),
    CONSTRAINT FK_DeductionByEmployerCharge_Period FOREIGN KEY (periodId) 
        REFERENCES payrollPeriod(id)
);