USE [Taller/empleados];

CREATE TABLE RegistroCivil (
    Cedula VARCHAR(10),
    numero_folio VARCHAR(4),
    cedula_padre VARCHAR(9),
    cedula_madre VARCHAR(9),
    codigo_hospital VARCHAR(4),
    hora_suceso VARCHAR(5),
    fecha_suceso VARCHAR(9),
    genero VARCHAR(1),
    nacionalidad VARCHAR(1),
    defuncion VARCHAR(1),
    pais_del_padre VARCHAR(4),
    pais_de_la_madre VARCHAR(4),
    prov_canton_madre VARCHAR(4),
    fecha_naturalizacion VARCHAR(9),
    apellido1 VARCHAR(30),
    apellido2 VARCHAR(30),
    nombre VARCHAR(60),
    nombre_padre VARCHAR(100),
    nombre_madre VARCHAR(100),
    lugar_nacimiento VARCHAR(100)
);

BULK INSERT RegistroCivil
FROM 'C:\Users\Usuario\Documents\REGISTROCIVIL.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    CODEPAGE = '65001'  -- UTF-8
);
