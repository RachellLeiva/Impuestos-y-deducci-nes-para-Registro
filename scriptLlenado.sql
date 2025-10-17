USE [Taller/empleados];
-- Insertar 3 empresas
INSERT INTO organizations (nameOrganizations, isActive) VALUES
('TechSolutions SA', 1),
('Industrias Globales', 1),
('ServiCorp Ltda', 1);

-- Insertar 3 departamentos para cada empresa
INSERT INTO departments(nameDepartment, organizationId, isActive) VALUES
-- Empresa 1
('Desarrollo Software', 1, 1),
('Soporte Técnico', 1, 1),
('Ventas TI', 1, 1),

-- Empresa 2
('Producción', 2, 1),
('Logística', 2, 1),
('Calidad', 2, 1),

-- Empresa 3
('Atención Cliente', 3, 1),
('Operaciones', 3, 1),
('Marketing', 3, 1);

--Insertando periodos
INSERT INTO payrollPeriod (period_number, year, pay_date) VALUES
(1, 2025, '2025-01-01'),
(2, 2025, '2025-01-15'),
(3, 2025, '2025-02-01'),
(4, 2025, '2025-02-15'),
(5, 2025, '2025-03-01'),
(6, 2025, '2025-03-15'),
(7, 2025, '2025-04-01'),
(8, 2025, '2025-04-15'),
(9, 2025, '2025-05-01'),
(10, 2025, '2025-05-15'),
(11, 2025, '2025-06-01'),
(12, 2025, '2025-06-15'),
(13, 2025, '2025-07-01'),
(14, 2025, '2025-07-15'),
(15, 2025, '2025-08-01'),
(16, 2025, '2025-08-15'),
(17, 2025, '2025-09-01'),
(18, 2025, '2025-09-15'),
(19, 2025, '2025-10-01'),
(20, 2025, '2025-10-15'),
(21, 2025, '2025-11-01'),
(22, 2025, '2025-11-15'),
(23, 2025, '2025-12-01'),
(24, 2025, '2025-12-15'),
(25, 2025, '2025-12-18');

-- Insertar empleados tomando datos del Registro Civil y generando datos aleatorios
INSERT INTO Employee (Idcard, FirstName, Lastname1, Lastname2, status, departmentId)
SELECT 
    rc.Cedula AS Idcard,
    rc.nombre AS FirstName,
    rc.apellido1 AS Lastname1,
    rc.apellido2 AS Lastname2,
    1 AS status,
    
    ABS(CHECKSUM(NEWID())) % 9 + 1 AS departmentId
FROM RegistroCivil rc;

--Insertar Salarios Brutos en GrossSalary para cada empleado 
INSERT INTO GrossSalary (employeeId, grossSalary, jobPosition, startDate, endDate, isActive, fiscal)
SELECT 
    e.Idcard AS employeesId,
    -- Salario aleatorio entre 500,000 y 6,000,000
    ROUND(500000 + (ABS(CHECKSUM(NEWID())) % 5500000), 2) AS grossSalary,
    'Gerente' AS jobPosition,
    -- Fecha de inicio aleatoria en los últimos 3 años
    DATEADD(DAY, -FLOOR(RAND() * 1095), GETDATE()) AS startDate,
    NULL AS endDate,
    -- Todos están activos
    1 AS isActive,
	CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 1 ELSE 0 END AS fiscal
FROM Employee e;



--Insertar Deducciones
INSERT INTO deductions (nameDeduction, porcentage, startDate, endDate) VALUES
('SEM', 0.0550, '2024-01-01', NULL),     
('Aporte Banco Popular', 0.0550, '2024-01-01', NULL), 
('IVM', 0.0417, '2024-01-01', NULL);

--Insertar Cargas Patronales
INSERT INTO employerCharge (nameCharge, porcentage, startDate, endDate) VALUES
('SEM', 0.0925, '2024-01-01', NULL),      
('IVM', 0.0542, '2024-01-01', NULL),
('Cuota Banco Popular', 0.0025, '2024-01-01', NULL),      
('Asignaciones Familiares', 0.0500, '2024-01-01', NULL), 
('IMAS', 0.0050, '2024-01-01', NULL),               
('INA', 0.0150, '2024-01-01', NULL),
('Aporte Patrono Banco Popular-LPT', 0.0025, '2024-01-01', NULL),  
('Fondo Capitalización Laboral-LPT', 0.0150, '2024-01-01', NULL),  
('Fondo Pensiones Complementarias-LPT', 0.0200, '2024-01-01', NULL),
('INS-LPT', 0.0100, '2024-01-01', NULL);

--Insertar límites impuestos de renta
INSERT INTO excessTaxRent (startDate, endDate, descripcion, lowerLimit, upperLimit, porcentage, isActive) VALUES
('2024-01-01', NULL, 'Exento', 0.00, 922000.00, 0.00, 1),
('2024-01-01', NULL, 'Escala 10%', 922000.00, 1352000.00, 0.10, 1),
('2024-01-01', NULL, 'Escala 15%', 1352000.00, 2373000.00, 0.15, 1),
('2024-01-01', NULL, 'Escala 20%', 2373000.00, 4745000.00, 0.20, 1),
('2024-01-01', NULL, 'Escala 25%', 4745000.00, NULL, 0.25, 1);

--
INSERT INTO creditFiscalFamily(amount,childrenOrPartner, startDate,endDate, isActive) VALUES
(1720.00, 1,'2024-01-01', NULL, 1),
(2600.00, 2,'2024-01-01', NULL, 1);

INSERT INTO creditFiscalFamilyperEmployee (
    employeeId, startDate, endDate, havePartner, children, totalCredit, isActive
)
SELECT 
    gs.employeeId,
    COALESCE(gs.startDate, GETDATE()) AS startDate,
    NULL AS endDate,
    havePartner,
    children,
    -- Cálculo CORRECTO usando los valores REALES
    (children * 1720.00) + (CASE WHEN havePartner = 1 THEN 2600.00 ELSE 0.00 END) AS totalCredit,
    1 AS isActive
FROM GrossSalary gs
CROSS APPLY (
    SELECT 
        CASE 
            WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 1  -- Tiene partner
            ELSE 0  -- No tiene partner
        END AS havePartner,
        CASE 
            WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN ABS(CHECKSUM(NEWID())) % 4  -- 0-3 hijos
            ELSE 1 + (ABS(CHECKSUM(NEWID())) % 3)  -- 1-3 hijos
        END AS children
) AS family_data
WHERE gs.fiscal = 1;

SELECT * FROM creditFiscalFamilyperEmployee