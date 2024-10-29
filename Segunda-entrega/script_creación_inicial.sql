---- Drop constraints ----
GO
DECLARE @drop_constraints NVARCHAR(max) = ''
SELECT @drop_constraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'
                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)
FROM sys.foreign_keys f

EXEC sp_executesql @drop_constraints;
GO
----

---- Drop tablas ----
declare @drop_tablas NVARCHAR(max) = ''
SELECT @drop_tablas += 'DROP TABLE LOS_SUPERDATADOS.' + QUOTENAME(TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'LOS_SUPERDATADOS' and TABLE_TYPE = 'BASE TABLE'

EXEC sp_executesql @drop_tablas;
GO
----

---- Drop indices ----
DECLARE @drop_indices NVARCHAR(max) = ''
SELECT @drop_indices += 'DROP INDEX ' + QUOTENAME(ix.name) + ' ON ' + QUOTENAME(sc.name) + '.' + QUOTENAME(so.name) + ';' + CHAR(13)
FROM sys.indexes ix
    JOIN sys.objects so ON ix.object_id = so.object_id
    JOIN sys.schemas sc ON so.schema_id = sc.schema_id
WHERE sc.name = 'LOS_SUPERDATADOS'

EXEC sp_executesql @drop_indices;
GO
----

---- Drop procedures ----
DECLARE @drop_procedures NVARCHAR(max) = ''
SELECT @drop_procedures += 'DROP PROCEDURE LOS_SUPERDATADOS.' + QUOTENAME(NAME)
FROM sys.procedures
WHERE schema_id = SCHEMA_ID('LOS_SUPERDATADOS')

EXEC sp_executesql @drop_procedures;
GO
----

---- Drop schema ----
IF EXISTS (SELECT name
FROM sys.schemas
WHERE name = 'LOS_SUPERDATADOS')
	DROP SCHEMA LOS_SUPERDATADOS;
GO
----

---- Create schema ----
CREATE SCHEMA LOS_SUPERDATADOS
	AUTHORIZATION dbo;
GO

--CREACION DE TABLAS
--En la db el unico campo que existe es el nombre del subrubro por lo que creamos una clave subrogada para el mismo
CREATE TABLE LOS_SUPERDATADOS.Provincias
(
    id_provincia DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Nombre_provincia NVARCHAR(25) NOT NULL
);

--En la db el unico campo que existe es el nombre del subrubro por lo que creamos una clave subrogada para el mismo
CREATE TABLE LOS_SUPERDATADOS.Localidades
(
    id_localidad DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Nombre_localidad NVARCHAR(50) NOT NULL,
	id_provincia DECIMAL(18,0) NOT NULL,
	CONSTRAINT ubicacion_id_provincia FOREIGN KEY (id_provincia) REFERENCES LOS_SUPERDATADOS.Provincias(id_provincia)
)

CREATE TABLE LOS_SUPERDATADOS.Ubicaciones
(
    id_ubicacion DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Calle NVARCHAR(150) NOT NULL,
    Numero DECIMAL(18,0) NOT NULL,
    Departamento NVARCHAR(50),
    Piso DECIMAL(18,0),
    Codigo_postal NVARCHAR(50),
    id_localidad DECIMAL(18,0) NOT NULL,
    CONSTRAINT ubicacion_id_localidad FOREIGN KEY (id_localidad) REFERENCES LOS_SUPERDATADOS.Localidades(id_localidad)
);

CREATE TABLE LOS_SUPERDATADOS.Almacenes
(
    id_almacen DECIMAL(18,0) PRIMARY KEY,
    Costo_diario DECIMAL(18,2) NOT NULL,
    id_ubicacion DECIMAL(18,0) NOT NULL,
    CONSTRAINT almacen_id_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES LOS_SUPERDATADOS.Ubicaciones(id_ubicacion)
);

CREATE TABLE LOS_SUPERDATADOS.Clientes
(
    id_cliente DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1), /*NO TENEMOS ID PARA LOS CLIENTES POR LO QUE LE ASIGNAMOS UNO*/
    Nombre_cliente NVARCHAR(50) NOT NULL,
    Apellido NVARCHAR(30) NOT NULL,
    Fecha_de_nacimiento DATE NOT NULL,
    Dni VARCHAR(8) NOT NULL, /*LE SAQUE EL UNIQUE*/
    Mail NVARCHAR(50) /*LE SAQUE EL UNIQUE*/
);

CREATE TABLE LOS_SUPERDATADOS.Vendedores
(
    id_vendedor DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1), /*NO TENEMOS ID PARA LOS VENDEDORES POR LO QUE LE ASIGNAMOS UNO*/
    Razon_social NVARCHAR(50) NOT NULL,
    Cuit VARCHAR(12) NOT NULL,
    Mail NVARCHAR(50)
);

CREATE TABLE LOS_SUPERDATADOS.Usuarios
(
    id_usuario DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Fecha_creacion DATE,
    Nombre_usuario NVARCHAR(50) NOT NULL,
    pass_usuario NVARCHAR(50) NOT NULL,
    id_cliente DECIMAL(18,0) NULL,
    id_vendedor DECIMAL(18,0) NULL,
    CONSTRAINT usuario_id_cliente FOREIGN KEY (id_cliente) REFERENCES LOS_SUPERDATADOS.Clientes(id_cliente),
    CONSTRAINT usuario_id_vendedor FOREIGN KEY (id_vendedor) REFERENCES LOS_SUPERDATADOS.Vendedores(id_vendedor)
);

CREATE TABLE LOS_SUPERDATADOS.Domicilios
(
    id_domicilio DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1), /*NO TENEMOS ID PARA LOS DOMICILIOS POR LO QUE LE ASIGNAMOS UNO*/
    id_usuario DECIMAL(18,0) NOT NULL,
    id_ubicacion DECIMAL(18,0) NOT NULL,
    CONSTRAINT domicilio_id_usuario FOREIGN KEY (id_usuario) REFERENCES LOS_SUPERDATADOS.Usuarios(id_usuario), /*ESTABA EN CLIENTE Y LO CAMBIE A USUARIO*/
    CONSTRAINT domicilio_id_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES LOS_SUPERDATADOS.Ubicaciones(id_ubicacion)
);

--En la db el unico campo que existe es el nombre del subrubro por lo que creamos una clave subrogada para el mismo
CREATE TABLE LOS_SUPERDATADOS.Rubros
(
    id_rubro DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Nombre_rubro NVARCHAR(60) NOT NULL
);

--En la db el unico campo que existe es el nombre del subrubro por lo que creamos una clave subrogada para el mismo
CREATE TABLE LOS_SUPERDATADOS.SubRubros
(
    id_subrubro DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Nombre_subrubro NVARCHAR(60) NOT NULL,
    id_rubro DECIMAL(18,0) NOT NULL,
    CONSTRAINT id_rubro FOREIGN KEY (id_rubro) REFERENCES LOS_SUPERDATADOS.Rubros(id_rubro)
);

--En la db el unico campo que existe es el nombre del subrubro por lo que creamos una clave subrogada para el mismo
CREATE TABLE LOS_SUPERDATADOS.Marcas
(
    id_marca DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Nombre_marca NVARCHAR(50) NOT NULL
);

--no subrrogada ya que en la db nos dan la id
CREATE TABLE LOS_SUPERDATADOS.Modelos
(
    id_modelo DECIMAL(18,0) PRIMARY KEY,
    Descripcion_modelo NVARCHAR(50) NOT NULL
);


CREATE TABLE LOS_SUPERDATADOS.Productos
(
    id_producto DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1), /*NO TENEMOS ID PARA LOS PRODUCTOS POR LO QUE LE ASIGNAMOS UNO*/
    Codigo NVARCHAR(50) NOT NULL,
    Descripcion_producto NVARCHAR(255),
	Precio_producto DECIMAL(18,2) NOT NULL, /*AGREGO PRECIO PRODUCTO*/
    id_modelo DECIMAL(18,0) NOT NULL,
    id_subrubro DECIMAL(18,0) NOT NULL,
    id_marca DECIMAL(18,0) NOT NULL,
    CONSTRAINT producto_id_modelo FOREIGN KEY (id_modelo) REFERENCES LOS_SUPERDATADOS.Modelos(id_modelo),
    CONSTRAINT producto_id_subrubro FOREIGN KEY (id_subrubro) REFERENCES LOS_SUPERDATADOS.SubRubros(id_subrubro),
    CONSTRAINT producto_id_marca FOREIGN KEY (id_marca) REFERENCES LOS_SUPERDATADOS.Marcas(id_marca)
);

CREATE TABLE LOS_SUPERDATADOS.Publicaciones
(
    id_publicacion DECIMAL(18,0) PRIMARY KEY,
    Descripcion_publicacion NVARCHAR(50),
    Fecha_inicio DATE NOT NULL,
    Fecha_fin DATE NOT NULL,
    Stock DECIMAL(8,0) NOT NULL,
	Precio_Unitario DECIMAL(18,2) NOT NULL,
    Costo_publicacion DECIMAL(18,2) NOT NULL,
    Comision_venta_ptge DECIMAL(18,2) NOT NULL,
    id_producto DECIMAL(18,0) NOT NULL,
    id_usuario_vendedor DECIMAL(18,0) NOT NULL,
    id_almacen DECIMAL(18,0) NOT NULL,
    CONSTRAINT publicacion_id_producto FOREIGN KEY (id_producto) REFERENCES LOS_SUPERDATADOS.Productos(id_producto),
    CONSTRAINT publicacion_id_usuario_vendedor FOREIGN KEY (id_usuario_vendedor) REFERENCES LOS_SUPERDATADOS.Usuarios(id_usuario),
    CONSTRAINT publicacion_id_almacen FOREIGN KEY (id_almacen) REFERENCES LOS_SUPERDATADOS.Almacenes(id_almacen)
);

CREATE TABLE LOS_SUPERDATADOS.DetallesFacturas
(
    id_detalle_factura DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Precio DECIMAL(18,2) NOT NULL,
    id_publicacion DECIMAL(18,0) NOT NULL,
    CONSTRAINT detalle_factura_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES LOS_SUPERDATADOS.Publicaciones(id_publicacion)
);

CREATE TABLE LOS_SUPERDATADOS.ConceptosFacturacion
(
    id_concepto DECIMAL(18,0) PRIMARY KEY,
    Concepto DECIMAL(18,2) NOT NULL,
    Cantidad INT NOT NULL,
    id_detalle_factura DECIMAL(18,0) NOT NULL,
    CONSTRAINT concepto_id_detalle_factura FOREIGN KEY (id_detalle_factura) REFERENCES LOS_SUPERDATADOS.DetallesFacturas(id_detalle_factura)
);




CREATE TABLE LOS_SUPERDATADOS.Facturas
(
    id_facturas DECIMAL(18,0) PRIMARY KEY,
    Fecha_emision DATE,
    Importe_total DECIMAL(18,2) NOT NULL,
    Total_factura DECIMAL(18,2) NOT NULL,
    Subtotal_factura DECIMAL(18,2) NOT NULL,
    id_publicacion DECIMAL(18,0) NOT NULL,
    id_detalle_factura DECIMAL(18,0) NOT NULL,
    CONSTRAINT facturas_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES LOS_SUPERDATADOS.Publicaciones(id_publicacion),
    CONSTRAINT facturas_id_detalle_factura FOREIGN KEY (id_detalle_factura) REFERENCES LOS_SUPERDATADOS.DetallesFacturas(id_detalle_factura)
);

CREATE TABLE LOS_SUPERDATADOS.MediosDePago
(
    id_medio_pago DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Tipo NVARCHAR(30) NOT NULL
);

CREATE TABLE LOS_SUPERDATADOS.DetallesPagosTarjeta
(
    id_detalle_pago DECIMAL(18,0) PRIMARY KEY,
    Numero_tarjeta NVARCHAR(16) NOT NULL,
    Fecha_vencimiento DATE NOT NULL,
    Cant_cuotas DECIMAL(18,0),
    Tipo_tarjeta NVARCHAR(50) NOT NULL
);


CREATE TABLE LOS_SUPERDATADOS.DetallesVentas
(
    id_detalle_venta DECIMAL(18,0) PRIMARY KEY,
    Precio DECIMAL(18,2) NOT NULL,
    Cant_vendida DECIMAL(18,0) NOT NULL,
    Subtotal DECIMAL(18,2) NOT NULL,
    id_publicacion DECIMAL(18,0) NOT NULL,
    CONSTRAINT detalle_venta_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES LOS_SUPERDATADOS.Publicaciones(id_publicacion)
);

CREATE TABLE LOS_SUPERDATADOS.Ventas
(
    id_venta DECIMAL(18,0) PRIMARY KEY,
    Fecha_hora_venta DATETIME,
    Total_venta DECIMAL(18,2) NOT NULL,
    id_usuario_cliente DECIMAL(18,0) NOT NULL,
    id_detalle_venta DECIMAL(18,0) NOT NULL,
    CONSTRAINT venta_id_usuario_cliente FOREIGN KEY (id_usuario_cliente) REFERENCES LOS_SUPERDATADOS.Usuarios(id_usuario),
    CONSTRAINT venta_id_detalle_venta FOREIGN KEY (id_detalle_venta) REFERENCES LOS_SUPERDATADOS.DetallesVentas(id_detalle_venta),
);

CREATE TABLE LOS_SUPERDATADOS.Pagos
(
    id_pago DECIMAL(18,0) PRIMARY KEY,
    Importe DECIMAL(14,2) NOT NULL,
    Fecha_pago DATE,
    id_detalle_pago DECIMAL(18,0) NULL,
    id_medio_pago DECIMAL(18,0) NOT NULL,
    id_venta DECIMAL(18,0) NOT NULL,
    CONSTRAINT pago_id_detalle_pago FOREIGN KEY (id_detalle_pago) REFERENCES LOS_SUPERDATADOS.DetallesPagosTarjeta(id_detalle_pago),
    CONSTRAINT pago_id_medio_pago FOREIGN KEY (id_medio_pago) REFERENCES LOS_SUPERDATADOS.MediosDePago(id_medio_pago),
    CONSTRAINT pago_id_venta FOREIGN KEY (id_venta) REFERENCES LOS_SUPERDATADOS.Ventas(id_venta)
);


CREATE TABLE LOS_SUPERDATADOS.MediosDeEnvio
(
    id_medio_envio DECIMAL(18,0) PRIMARY KEY IDENTITY(1,1),
    Tipo NVARCHAR(30)
);

CREATE TABLE LOS_SUPERDATADOS.Envios
(
    id_envio DECIMAL(18,0) PRIMARY KEY,
    Fecha_programada DATE NOT NULL,
    Hora_inicio TIME NOT NULL,
    Hora_fin TIME NOT NULL,
    Costo_envio DECIMAL(18,2) NOT NULL,
    Fecha_hora_entregado DATETIME,
    id_venta DECIMAL(18,0) NOT NULL,
    id_domicilio DECIMAL(18,0) NOT NULL,
    id_medio_envio DECIMAL(18,0) NOT NULL,
    CONSTRAINT envio_id_venta FOREIGN KEY (id_venta) REFERENCES LOS_SUPERDATADOS.Ventas(id_venta),
    CONSTRAINT envio_id_domicilio FOREIGN KEY (id_domicilio) REFERENCES LOS_SUPERDATADOS.Domicilios(id_domicilio),
    CONSTRAINT envio_id_medio_envio FOREIGN KEY (id_medio_envio) REFERENCES LOS_SUPERDATADOS.MediosDeEnvio(id_medio_envio)
);

--TRIGGERS Y CONSTRAINTS
GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_ValidarDatos
    @precio DECIMAL(18,2) = NULL,
    @subtotal DECIMAL(18,2) = NULL,
    @importe DECIMAL(18,2) = NULL,
    @stock DECIMAL(18,0) = NULL,
    @cantidad DECIMAL(18,0) = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL
AS
BEGIN

    IF @precio IS NOT NULL AND @precio <= 0
    BEGIN
        RAISERROR('El precio debe ser mayor que 0.', 16, 1);
        RETURN;
    END;

    IF @subtotal IS NOT NULL AND @subtotal <= 0
    BEGIN
        RAISERROR('El subtotal debe ser mayor que 0.', 16, 1);
        RETURN;
    END;

    IF @importe IS NOT NULL AND @importe <= 0
    BEGIN
        RAISERROR('El importe debe ser mayor que 0.', 16, 1);
        RETURN;
    END;

    IF @stock IS NOT NULL AND @stock < 0
    BEGIN
        RAISERROR('El stock debe ser mayor que 0.', 16, 1);
        RETURN;
    END;

    IF @cantidad IS NOT NULL AND @cantidad <= 0
    BEGIN
        RAISERROR('La cantidad debe ser mayor que 0.', 16, 1);
        RETURN;
    END;

    IF @fecha_inicio IS NOT NULL AND @fecha_inicio > GETDATE()
    BEGIN
        RAISERROR('La fecha de inicio no puede ser mayor que la fecha actual.', 16, 1);
        RETURN;
    END;

    IF @fecha_fin IS NOT NULL AND @fecha_fin > GETDATE()
    BEGIN
        RAISERROR('La fecha de fin no puede ser mayor que la fecha actual.', 16, 1);
        RETURN;
    END;
END;
GO

GO
CREATE TRIGGER trg_VerificarPublicaciones
ON LOS_SUPERDATADOS.Publicaciones
AFTER INSERT, UPDATE
AS
BEGIN

    DECLARE @precio DECIMAL(18,2),
            @stock DECIMAL(18,0)

    BEGIN TRY
		SELECT @precio = Costo_publicacion,
        @stock = Stock

    FROM inserted;

		EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
			@precio = @precio, 
			@stock = @stock
		
	END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION;
        
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
	END CATCH

END;
GO

GO
CREATE TRIGGER LOS_SUPERDATADOS.trg_VerificarAlmacenes
ON LOS_SUPERDATADOS.Almacenes
AFTER INSERT, UPDATE
AS
BEGIN

    DECLARE @precio DECIMAL(18,2);
    BEGIN TRY
		SELECT @precio = Costo_diario
    FROM inserted;

		EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
			@precio = @precio;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
        
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END;
GO

GO
CREATE TRIGGER LOS_SUPERDATADOS.trg_VerificarClientes
ON LOS_SUPERDATADOS.Clientes
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        DECLARE @fecha_fin DATE;

        SELECT @fecha_fin = Fecha_de_nacimiento
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @fecha_fin = @fecha_fin;
        END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

END;
GO

GO
CREATE TRIGGER trg_VerificarUsuarios
ON LOS_SUPERDATADOS.Usuarios
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        DECLARE @fecha_fin DATE;

        SELECT @fecha_fin = Fecha_creacion
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @fecha_fin = @fecha_fin;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

GO
CREATE TRIGGER trg_VerificarConceptosFacturacion
ON LOS_SUPERDATADOS.ConceptosFacturacion
AFTER INSERT, UPDATE
AS
BEGIN

    BEGIN TRY
        DECLARE @precio DECIMAL(18,2),
                @cantidad DECIMAL(18,0);

        SELECT @precio = Concepto,
        @cantidad = Cantidad
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @precio = @precio, 
            @cantidad = @cantidad;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

    EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
        @cantidad = @cantidad;

END;
GO

GO
CREATE TRIGGER trg_VerificarDetallesFacturas
ON LOS_SUPERDATADOS.DetallesFacturas
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        DECLARE @precio DECIMAL(18,2);

        SELECT @precio = Precio
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @precio = @precio;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

GO
CREATE TRIGGER trg_VerificarFacturas
ON LOS_SUPERDATADOS.Facturas
AFTER INSERT, UPDATE
AS
BEGIN

    BEGIN TRY
        DECLARE @precio DECIMAL(18,2),
                @subtotal DECIMAL(18,2),
                @importe DECIMAL(18,2),
                @fecha_fin DATE;

        SELECT @precio = Total_factura,
        @subtotal = Subtotal_factura,
        @importe = Importe_total,
        @fecha_fin = Fecha_emision
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @precio = @precio, 
            @subtotal = @subtotal, 
            @importe = @importe, 
            @fecha_fin = @fecha_fin;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

END;
GO

GO
CREATE TRIGGER trg_VerificarDetallesPagosTarjeta
ON LOS_SUPERDATADOS.DetallesPagosTarjeta
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        DECLARE @cantidad DECIMAL(18,0),
                @fecha_fin DATE;

        SELECT @cantidad = Cant_cuotas,
        @fecha_fin = Fecha_vencimiento
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @cantidad = @cantidad, 
            @fecha_fin = @fecha_fin;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

GO
CREATE TRIGGER trg_VerificarPagos
ON LOS_SUPERDATADOS.Pagos
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        DECLARE @importe DECIMAL(18,2),
                @fecha_fin DATE;

        SELECT @importe = Importe,
        @fecha_fin = Fecha_pago
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @importe = @importe, 
            @fecha_fin = @fecha_fin;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

END;
GO

GO
CREATE TRIGGER trg_VerificarDetallesVentas
ON LOS_SUPERDATADOS.DetallesVentas
AFTER INSERT, UPDATE
AS
BEGIN

    BEGIN TRY
        DECLARE @precio DECIMAL(18,2),
            @cantidad DECIMAL(18,0),
            @subtotal DECIMAL(18,2);

        SELECT @precio = Precio,
        @cantidad = Cant_vendida,
        @subtotal = Subtotal
    FROM inserted;

        EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
            @precio = @precio, 
            @cantidad = @cantidad, 
            @subtotal = @subtotal;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

END;
GO

GO
CREATE TRIGGER trg_VerificarVentas
ON LOS_SUPERDATADOS.Ventas
AFTER INSERT, UPDATE
AS
BEGIN

    DECLARE @precio DECIMAL(18,2),
            @fecha_fin DATE;

    BEGIN TRY
    SELECT @precio = Total_venta,
        @fecha_fin = Fecha_hora_venta
    FROM inserted;

    EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
        @precio = @precio, 
        @fecha_fin = @fecha_fin;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END;
GO

GO
CREATE TRIGGER trg_VerificarEnvios
ON LOS_SUPERDATADOS.Envios
AFTER INSERT, UPDATE
AS
BEGIN

    DECLARE @precio DECIMAL(18,2),
            @fecha_inicio DATE,
            @fecha_fin DATE;

    BEGIN TRY
    SELECT @precio = Costo_envio,
        @fecha_inicio = Fecha_programada,
        @fecha_fin = Fecha_hora_entregado
    FROM inserted;

    EXEC LOS_SUPERDATADOS.sp_ValidarDatos 
        @precio = @precio, 
        @fecha_inicio = @fecha_inicio, 
        @fecha_fin = @fecha_fin;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END;
GO

-- EJECUTAR MIGRACION DE DATOS
GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigracionProvincias
AS
BEGIN
    INSERT INTO LOS_SUPERDATADOS.Provincias
        (Nombre_provincia)
    SELECT provincia
    FROM (
		SELECT VEN_USUARIO_DOMICILIO_PROVINCIA AS provincia
            FROM GD2C2024.gd_esquema.Maestra
        UNION
            SELECT CLI_USUARIO_DOMICILIO_PROVINCIA AS provincia
            FROM GD2C2024.gd_esquema.Maestra
        UNION
            SELECT ALMACEN_PROVINCIA AS provincia
            FROM GD2C2024.gd_esquema.Maestra
	) AS provincias
    WHERE provincia IS NOT NULL;
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigracionProvincias
GO

GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigracionLocalidades
AS
BEGIN
    INSERT INTO LOS_SUPERDATADOS.Localidades
        (Nombre_localidad, id_provincia)
    SELECT Localidad, id_provincia
    FROM (
		SELECT VEN_USUARIO_DOMICILIO_LOCALIDAD AS Localidad, VEN_USUARIO_DOMICILIO_PROVINCIA AS Provincia 
            FROM GD2C2024.gd_esquema.Maestra
        UNION
            SELECT CLI_USUARIO_DOMICILIO_LOCALIDAD, CLI_USUARIO_DOMICILIO_PROVINCIA 
            FROM GD2C2024.gd_esquema.Maestra
        UNION
            SELECT ALMACEN_Localidad, ALMACEN_PROVINCIA 
            FROM GD2C2024.gd_esquema.Maestra
	) AS l
	INNER JOIN LOS_SUPERDATADOS.Provincias AS p
	ON
	p.Nombre_provincia = l.Provincia
    WHERE Localidad IS NOT NULL;
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigracionLocalidades
GO


GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigracionUbicaciones 
AS
BEGIN
    INSERT INTO LOS_SUPERDATADOS.Ubicaciones
        (Calle, Numero, Piso, Departamento, Codigo_postal, id_localidad)
    SELECT Calle, Numero, Piso, Departamento, Codigo_postal, id_localidad
	FROM (
		SELECT DISTINCT VEN_USUARIO_DOMICILIO_CALLE AS Calle, 
		VEN_USUARIO_DOMICILIO_NRO_CALLE AS Numero, 
		VEN_USUARIO_DOMICILIO_PISO AS Piso, 
		VEN_USUARIO_DOMICILIO_DEPTO AS Departamento, 
		VEN_USUARIO_DOMICILIO_CP AS Codigo_postal, 
		VEN_USUARIO_DOMICILIO_LOCALIDAD AS Localidad,
		VEN_USUARIO_DOMICILIO_PROVINCIA AS Provincia
            FROM GD2C2024.gd_esquema.Maestra WHERE VEN_USUARIO_DOMICILIO_CALLE IS NOT NULL
        UNION
        SELECT DISTINCT CLI_USUARIO_DOMICILIO_CALLE AS Calle, 
		CLI_USUARIO_DOMICILIO_NRO_CALLE AS Numero, 
		CLI_USUARIO_DOMICILIO_PISO AS Piso,
		CLI_USUARIO_DOMICILIO_DEPTO AS Departamento, 
		CLI_USUARIO_DOMICILIO_CP AS Codigo_postal, 
		CLI_USUARIO_DOMICILIO_LOCALIDAD AS Localidad,
		CLI_USUARIO_DOMICILIO_PROVINCIA AS Provincia
            FROM GD2C2024.gd_esquema.Maestra WHERE CLI_USUARIO_DOMICILIO_CALLE IS NOT NULL
        UNION
        SELECT DISTINCT ALMACEN_CALLE AS Calle, 
		ALMACEN_NRO_CALLE AS Numero, 
		NULL AS Piso, 
		NULL AS Departamento, 
		NULL AS Codigo_postal,  
		ALMACEN_Localidad AS Localidad,
		ALMACEN_PROVINCIA AS Provincia
            FROM GD2C2024.gd_esquema.Maestra
	) AS u
	INNER JOIN LOS_SUPERDATADOS.Provincias AS p
	ON
	u.Provincia = p.Nombre_provincia
	INNER JOIN LOS_SUPERDATADOS.Localidades AS l
	ON
	p.id_provincia = l.id_provincia
	AND u.Localidad = l.Nombre_localidad
	WHERE Calle IS NOT NULL
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigracionUbicaciones 
GO

GO 
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarAlmacenes
AS
BEGIN 
	INSERT INTO LOS_SUPERDATADOS.Almacenes
        (id_almacen, Costo_diario, id_ubicacion)
    SELECT DISTINCT O.ALMACEN_CODIGO, O.ALMACEN_COSTO_DIA_AL, u.id_ubicacion
    FROM GD2C2024.gd_esquema.Maestra AS O 
    INNER JOIN LOS_SUPERDATADOS.Provincias AS p
	ON 
	p.Nombre_provincia = O.ALMACEN_PROVINCIA
	INNER JOIN LOS_SUPERDATADOS.Localidades AS l
	ON
	l.id_provincia = p.id_provincia
	AND l.Nombre_localidad = O.ALMACEN_Localidad
	INNER JOIN LOS_SUPERDATADOS.Ubicaciones AS u
	ON
	u.id_localidad = l.id_localidad
	AND u.Numero = O.ALMACEN_NRO_CALLE
	AND  u.Calle = O.ALMACEN_CALLE


	END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarAlmacenes
GO

GO 
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarClientes
AS
BEGIN 
	INSERT INTO LOS_SUPERDATADOS.Clientes
        (Nombre_cliente, Apellido, Fecha_de_nacimiento, Dni, Mail)
    SELECT DISTINCT O.CLIENTE_NOMBRE, O.CLIENTE_APELLIDO, O.CLIENTE_FECHA_NAC, O.CLIENTE_DNI, O.CLIENTE_MAIL
    FROM GD2C2024.gd_esquema.Maestra AS O 
	WHERE O.CLIENTE_NOMBRE IS NOT NULL
	END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarClientes
GO

GO 
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarVendedores
AS
BEGIN 
	INSERT INTO LOS_SUPERDATADOS.Vendedores
        (Razon_social, Cuit, Mail)
    SELECT DISTINCT O.VENDEDOR_RAZON_SOCIAL, O.VENDEDOR_CUIT, O.VENDEDOR_MAIL
    FROM GD2C2024.gd_esquema.Maestra AS O 
	WHERE O.VENDEDOR_RAZON_SOCIAL IS NOT NULL 
	END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarVendedores
GO

GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarUsuarios
as
begin
insert into LOS_SUPERDATADOS.Usuarios
	(Nombre_usuario, pass_usuario, Fecha_creacion, id_vendedor, id_cliente)
SELECT 
    nombre, 
    pass, 
    fecha,
    id_vendedor,
    id_cliente
FROM (
    SELECT DISTINCT 
        CLI_USUARIO_NOMBRE AS nombre,
        CLI_USUARIO_PASS AS pass,
        CLI_USUARIO_FECHA_CREACION AS fecha,
        V.id_vendedor,         
        C.id_cliente
    FROM [GD2C2024].[gd_esquema].[Maestra] AS M
    LEFT JOIN LOS_SUPERDATADOS.Vendedores AS V
        ON M.VENDEDOR_RAZON_SOCIAL = V.Razon_social 
        AND M.VENDEDOR_MAIL = V.Mail 
        AND M.VENDEDOR_CUIT = V.Cuit
    LEFT JOIN LOS_SUPERDATADOS.Clientes AS C
        ON M.CLIENTE_NOMBRE = C.Nombre_cliente 
        AND M.CLIENTE_APELLIDO = C.Apellido 
        AND M.CLIENTE_DNI = C.Dni 
        AND M.CLIENTE_MAIL = C.Mail 
        AND M.CLIENTE_FECHA_NAC = C.Fecha_de_nacimiento

    UNION ALL

    SELECT DISTINCT 
        VEN_USUARIO_NOMBRE AS nombre,
        VEN_USUARIO_PASS AS pass,
        VEN_USUARIO_FECHA_CREACION AS fecha,
        V.id_vendedor,         
        C.id_cliente
    FROM [GD2C2024].[gd_esquema].[Maestra] AS M
    LEFT JOIN LOS_SUPERDATADOS.Vendedores AS V
        ON M.VENDEDOR_RAZON_SOCIAL = V.Razon_social 
        AND M.VENDEDOR_MAIL = V.Mail 
        AND M.VENDEDOR_CUIT = V.Cuit
    LEFT JOIN LOS_SUPERDATADOS.Clientes AS C
        ON M.CLIENTE_NOMBRE = C.Nombre_cliente 
        AND M.CLIENTE_APELLIDO = C.Apellido 
        AND M.CLIENTE_DNI = C.Dni 
        AND M.CLIENTE_MAIL = C.Mail 
        AND M.CLIENTE_FECHA_NAC = C.Fecha_de_nacimiento
) AS Usuarios_unicos
where nombre is not null;
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarUsuarios
GO

GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarDomicilios
as
begin
-- INSERT DE LOS CLIENTES
insert into LOS_SUPERDATADOS.Domicilios
		(id_usuario, id_ubicacion)
		select distinct Us.id_usuario , Ub.id_ubicacion
		from [GD2C2024].[gd_esquema].[Maestra] as M
		join LOS_SUPERDATADOS.Clientes as C
		ON
			M.CLIENTE_NOMBRE = C.Nombre_cliente and
			M.CLIENTE_APELLIDO = C.Apellido and
			M.CLIENTE_DNI = C.Dni and
			M.CLIENTE_FECHA_NAC = C.Fecha_de_nacimiento and
			M.CLIENTE_MAIL = C.Mail
		join LOS_SUPERDATADOS.Ubicaciones as Ub
		ON
			M.CLI_USUARIO_DOMICILIO_CALLE = Ub.Calle and
			M.CLI_USUARIO_DOMICILIO_NRO_CALLE = Ub.Numero and
			M.CLI_USUARIO_DOMICILIO_DEPTO = Ub.Departamento and
			M.CLI_USUARIO_DOMICILIO_CP = Ub.Codigo_postal and
			M.CLI_USUARIO_DOMICILIO_PISO = Ub.Piso
		join LOS_SUPERDATADOS.Localidades as L
		ON
			M.CLI_USUARIO_DOMICILIO_LOCALIDAD = L.Nombre_localidad and
			Ub.id_localidad = L.id_localidad
		join LOS_SUPERDATADOS.Provincias as P
		ON
			M.CLI_USUARIO_DOMICILIO_PROVINCIA = P.Nombre_provincia and
			L.id_provincia = P.id_provincia
		join LOS_SUPERDATADOS.Usuarios as Us
		ON
			M.CLI_USUARIO_NOMBRE = Us.Nombre_usuario and
			M.CLI_USUARIO_PASS = Us.pass_usuario and
			M.CLI_USUARIO_FECHA_CREACION = Us.Fecha_creacion and
			C.id_cliente = Us.id_cliente;

-- INSERT DE LOS VENDEDORES
insert into LOS_SUPERDATADOS.Domicilios
		(id_usuario, id_ubicacion)
		select distinct Us.id_usuario , Ub.id_ubicacion
		from [GD2C2024].[gd_esquema].[Maestra] as M
		join LOS_SUPERDATADOS.Vendedores as V
		ON
			M.VENDEDOR_RAZON_SOCIAL = V.Razon_social and
			M.VENDEDOR_CUIT = V.Cuit and
			M.VENDEDOR_MAIL = V.Mail
		join LOS_SUPERDATADOS.Ubicaciones as Ub
		ON
			M.VEN_USUARIO_DOMICILIO_CALLE = Ub.Calle and
			M.VEN_USUARIO_DOMICILIO_NRO_CALLE = Ub.Numero and
			M.VEN_USUARIO_DOMICILIO_DEPTO = Ub.Departamento and
			M.VEN_USUARIO_DOMICILIO_CP = Ub.Codigo_postal and
			M.VEN_USUARIO_DOMICILIO_PISO = Ub.Piso
		join LOS_SUPERDATADOS.Localidades as L
		ON
			M.VEN_USUARIO_DOMICILIO_LOCALIDAD = L.Nombre_localidad and
			Ub.id_localidad = L.id_localidad
		join LOS_SUPERDATADOS.Provincias as P
		ON
			M.VEN_USUARIO_DOMICILIO_PROVINCIA = P.Nombre_provincia and
			L.id_provincia = P.id_provincia
		join LOS_SUPERDATADOS.Usuarios as Us
		ON

			M.VEN_USUARIO_NOMBRE = Us.Nombre_usuario and
			M.VEN_USUARIO_PASS = Us.pass_usuario and
			M.VEN_USUARIO_FECHA_CREACION = Us.Fecha_creacion and
			V.id_vendedor = Us.id_vendedor;
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarDomicilios
GO

CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarRubros
as
begin
	insert into LOS_SUPERDATADOS.Rubros
		(Nombre_rubro)
	select distinct PRODUCTO_RUBRO_DESCRIPCION
	from [GD2C2024].[gd_esquema].[Maestra]
	where PRODUCTO_RUBRO_DESCRIPCION is not null;
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarRubros
GO

CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarSubRubros
as
begin
	insert into LOS_SUPERDATADOS.SubRubros
		(Nombre_subrubro, id_rubro)
	select distinct M.PRODUCTO_SUB_RUBRO, R.id_rubro
	from [GD2C2024].[gd_esquema].[Maestra] as M
	join LOS_SUPERDATADOS.Rubros AS R
	ON
		M.PRODUCTO_RUBRO_DESCRIPCION = R.Nombre_rubro
	where PRODUCTO_SUB_RUBRO is not null;
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarSubRubros
GO

CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarMarcas
as
begin
	insert into LOS_SUPERDATADOS.Marcas
		(Nombre_marca)
	select distinct M.PRODUCTO_MARCA 
	from [GD2C2024].[gd_esquema].[Maestra] as M
	where M.PRODUCTO_MARCA is not null
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarMarcas
GO

CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarModelos
as
begin
	insert into LOS_SUPERDATADOS.Modelos
		(id_modelo, Descripcion_modelo)
	select distinct M.PRODUCTO_MOD_CODIGO, M.PRODUCTO_MOD_DESCRIPCION
	from [GD2C2024].[gd_esquema].[Maestra] as M
	where M.PRODUCTO_MOD_CODIGO is not null
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarModelos
GO

GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarProductos
AS 
BEGIN
	INSERT INTO  LOS_SUPERDATADOS.Productos
		(Codigo, Descripcion_producto, Precio_producto, id_modelo, id_subrubro, id_marca)
	SELECT DISTINCT O.PRODUCTO_CODIGO, O.PRODUCTO_DESCRIPCION, O.PRODUCTO_PRECIO, mo.id_modelo, s.id_subrubro, ma.id_marca
	FROM GD2C2024.gd_esquema.Maestra AS O
	INNER JOIN LOS_SUPERDATADOS.Modelos AS mo
	ON 
	mo.id_modelo = O.PRODUCTO_MOD_CODIGO
	AND mo.Descripcion_modelo = O.PRODUCTO_MOD_DESCRIPCION
	INNER JOIN LOS_SUPERDATADOS.Rubros AS r
	ON
	r.Nombre_rubro = O.PRODUCTO_RUBRO_DESCRIPCION
	INNER JOIN LOS_SUPERDATADOS.SubRubros AS s
	ON
	s.id_rubro = r.id_rubro
	AND s.Nombre_subrubro = O.PRODUCTO_SUB_RUBRO
	INNER JOIN LOS_SUPERDATADOS.Marcas AS ma
	ON
	ma.Nombre_marca = O.PRODUCTO_MARCA

END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarProductos
GO

GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarPublicaciones
AS
BEGIN
    insert into LOS_SUPERDATADOS.Publicaciones
        (id_publicacion,
        Descripcion_publicacion,
        Fecha_inicio,
        Fecha_fin,
        Stock,
        Precio_Unitario,
        Costo_publicacion,
        Comision_venta_ptge,
        id_producto,
        id_usuario_vendedor,
        id_almacen)
    select distinct M.PUBLICACION_CODIGO,
                    M.PUBLICACION_DESCRIPCION,
                    M.PUBLICACION_FECHA,
                    M.PUBLICACION_FECHA_V,
                    M.PUBLICACION_STOCK,
                    M.PUBLICACION_PRECIO,
                    M.PUBLICACION_COSTO,
                    M.PUBLICACION_PORC_VENTA,
					P.id_producto,
					Us.id_usuario,
					A.id_almacen
    from [GD2C2024].[gd_esquema].[Maestra] AS M
    JOIN LOS_SUPERDATADOS.Productos AS P
    ON 
		M.PRODUCTO_CODIGO = P.Codigo and
		M.PRODUCTO_DESCRIPCION = P.Descripcion_producto and
		M.PRODUCTO_PRECIO = p.Precio_producto
	JOIN LOS_SUPERDATADOS.Marcas AS Ma
	ON
		M.PRODUCTO_MARCA = Ma.Nombre_marca and
		P.id_marca = Ma.id_marca
	join LOS_SUPERDATADOS.Modelos Mo
	ON
		M.PRODUCTO_MOD_CODIGO = Mo.id_modelo and
		M.PRODUCTO_MOD_DESCRIPCION = Mo.Descripcion_modelo
	join LOS_SUPERDATADOS.SubRubros as SubR
	ON
		M.PRODUCTO_SUB_RUBRO = SubR.Nombre_subrubro
	join LOS_SUPERDATADOS.Rubros as Ru
	ON
		M.PRODUCTO_RUBRO_DESCRIPCION = Ru.Nombre_rubro and
		SubR.id_rubro = Ru.id_rubro
    JOIN LOS_SUPERDATADOS.Usuarios AS us
    ON
    M.VEN_USUARIO_NOMBRE = us.Nombre_usuario
	AND M.VEN_USUARIO_PASS = us.pass_usuario
	AND us.Fecha_creacion = M.VEN_USUARIO_FECHA_CREACION
	JOIN LOS_SUPERDATADOS.Vendedores AS V
	ON
	V.id_vendedor = us.id_vendedor
	JOIN LOS_SUPERDATADOS.Ubicaciones AS ub
	ON
	M.ALMACEN_CALLE = ub.Calle and
	M.ALMACEN_NRO_CALLE = ub.Numero
	join LOS_SUPERDATADOS.Localidades as Lo
	ON
	M.ALMACEN_Localidad = Lo.Nombre_localidad
	join LOS_SUPERDATADOS.Provincias as Pr
	ON
	M.ALMACEN_PROVINCIA = Pr.Nombre_provincia and
	Lo.id_provincia = Pr.id_provincia
	JOIN LOS_SUPERDATADOS.Almacenes AS a
	ON
	a.id_ubicacion = ub.id_ubicacion
WHERE
	VENDEDOR_RAZON_SOCIAL is not null and
	PUBLICACION_CODIGO is not null and
	PRODUCTO_CODIGO is not null and
	ALMACEN_CODIGO is not null
END;

GO
EXEC LOS_SUPERDATADOS.sp_MigrarPublicaciones
GO

GO
CREATE PROCEDURE LOS_SUPERDATADOS.sp_MigrarDetallesFacturas
AS
BEGIN
	INSERT INTO LOS_SUPERDATADOS.DetallesFacturas
		(Precio, id_publicacion)
	SELECT DISTINCT O.FACTURA_DET_PRECIO, p.id_publicacion
	FROM GD2C2024.gd_esquema.Maestra AS O
	INNER JOIN LOS_SUPERDATADOS.Publicaciones AS p
	ON
	p.Precio_unitario = O.FACTURA_DET_PRECIO
END;
GO
EXEC LOS_SUPERDATADOS.sp_MigrarDetallesFacturas
GO

