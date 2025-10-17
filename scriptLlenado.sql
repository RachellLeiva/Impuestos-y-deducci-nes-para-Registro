USE [Taller/empleados];
-- Insertar 3 empresas
INSERT INTO organizations (id, nameOrganizations, isActive) VALUES
(1, 'TechSolutions SA', 1),
(2, 'Industrias Globales', 1),
(3, 'ServiCorp Ltda', 1);

-- Insertar 3 departamentos para cada empresa
INSERT INTO departments(id, nameDepartment, organizationId, isActive) VALUES
-- Empresa 1
(1, 'Desarrollo Software', 1, 1),
(2, 'Soporte Técnico', 1, 1),
(3, 'Ventas TI', 1, 1),

-- Empresa 2
(4, 'Producción', 2, 1),
(5, 'Logística', 2, 1),
(6, 'Calidad', 2, 1),

-- Empresa 3
(7, 'Atención Cliente', 3, 1),
(8, 'Operaciones', 3, 1),
(9, 'Marketing', 3, 1);

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
	--status siempre 1
	 1 AS status,
    -- DepartmentId aleatorio entre los 9 departamentos existentes
    FLOOR(1 + (RAND() * 9)) AS departmentId
FROM RegistroCivil rc;

--Insertar Salarios Brutos en GrossSalary para cada empleado 
INSERT INTO GrossSalary (employeesId, grossSalary, jobPosition, startDate, endDate, isActive)
SELECT 
    e.Idcard AS employeesId,
    -- Salario aleatorio entre 500,000 y 6,000,000
    ROUND(500000 + (RAND() * 5500000), 2) AS grossSalary,
    'Gerente' AS jobPosition,
    -- Fecha de inicio aleatoria en los últimos 3 años
    DATEADD(DAY, -FLOOR(RAND() * 1095), GETDATE()) AS startDate,
    NULL AS endDate,
    -- Todos están activos
    1 AS isActive
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