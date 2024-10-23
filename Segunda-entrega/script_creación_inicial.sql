--CREACION DE TABLAS

CREATE TABLE Provincias (
    id_provincia DECIMAL(18,0) PRIMARY KEY,
    Nombre_provincia NVARCHAR(25)
);

CREATE TABLE Localidades (
    id_localidad DECIMAL(18,0) PRIMARY KEY,
    Nombre_localidad NVARCHAR(50)
)

CREATE TABLE Ubicaciones (
    id_ubicacion DECIMAL(18,0) PRIMARY KEY,
    Calle NVARCHAR(150),
    Numero DECIMAL(18,0),
    Departamento NVARCHAR(50),
    Piso DECIMAL(18,0),
    Codigo_postal NVARCHAR(50),
    CONSTRAINT id_provincia FOREIGN KEY (id_provincia) REFERENCES Provincias(id_provincia),
    CONSTRAINT id_localidad FOREIGN KEY (id_localidad) REFERENCES Localidades(id_localidad)
);

CREATE TABLE Almacenes (
    id_almacen DECIMAL(18,0) PRIMARY KEY,
    Costo_diario DECIMAL(18,2),
    CONSTRAINT id_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id_ubicacion)
);

CREATE TABLE Domicilios (
    id_domicilio DECIMAL(18,0) PRIMARY KEY,
    CONSTRAINT id_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT id_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id_ubicacion)
);

CREATE TABLE Clientes (
    id_cliente DECIMAL(18,0) PRIMARY KEY,
    Nombre_cliente NVARCHAR(50),
    Apellido NVARCHAR(30),
    Fecha_de_nacimiento DATE,
    Dni VARCHAR(8) UNIQUE,
    Mail NVARCHAR(50) UNIQUE
);

CREATE TABLE Vendedores (
    id_vendedor DECIMAL(18,0) PRIMARY KEY,
    Razon_social NVARCHAR(50),
    Cuit VARCHAR(11),
    Mail NVARCHAR(50) UNIQUE
);

CREATE TABLE Usuarios (
    id_usuario DECIMAL(18,0) PRIMARY KEY,
    Fecha_creacion DATE,
    Nombre_usuario NVARCHAR(50),
    pass_usuario NVARCHAR(50),
    id_cliente DECIMAL(18,0) NULL,
    id_vendedor DECIMAL(18,0) NULL,
    CONSTRAINT id_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT id_vendedor FOREIGN KEY (id_vendedor) REFERENCES Vendedores(id_vendedor)
);

CREATE TABLE ConceptosFacturacion (
    id_concepto DECIMAL(18,0) PRIMARY KEY,
    Concepto DECIMAL(18,2),
    Cantidad INT,
    CONSTRAINT id_detalle_factura FOREIGN KEY (id_detalle_factura) REFERENCES DetallesFacturas(id_detalle_factura)
);

CREATE TABLE DetallesFacturas (
    id_detalle_factura DECIMAL(18,0) PRIMARY KEY,
    Precio DECIMAL(18,2),
    CONSTRAINT id_publicacion FOREIGN KEY (id_publicacion) REFERENCES Publicaciones(id_publicacion)
);

CREATE TABLE Facturas (
    id_facturas DECIMAL(18,0) PRIMARY KEY,
    Fecha_emision DATE,
    Importe_total DECIMAL(18,2),   
    Total_factura DECIMAL(18,2),
    Subtotal_factura DECIMAL(18,2),
    CONSTRAINT id_publicacion FOREIGN KEY (id_publicacion) REFERENCES Publicaciones(id_publicacion),
    CONSTRAINT id_detalle_factura FOREIGN KEY (id_detalle_factura) REFERENCES DetallesFacturas(id_detalle_factura)
);

CREATE TABLE MediosDePago(
    id_medio_pago DECIMAL(10,0) PRIMARY KEY,
    Tipo NVARCHAR(30)
);

CREATE TABLE DetallesPagosTarjeta (
    id_detalle_pago DECIMAL(18,0) PRIMARY KEY,
    Numero_tarjeta NVARCHAR(16),
    Fecha_vencimiento DATE,
    Cant_cuotas DECIMAL(18,0),
    Tipo_tarjeta NVARCHAR(50)
);

CREATE TABLE Pagos (
    id_pago DECIMAL(18,0) PRIMARY KEY,
    Importe DECIMAL(14,2),
    Fecha_pago DATE,
    id_detalle_pago NULL,
    CONSTRAINT id_detalle_pago FOREIGN KEY (id_detalle_pago) REFERENCES DetallesPagosTarjeta(id_detalle_pago),
    CONSTRAINT id_medio_pago FOREIGN KEY (id_medio_pago) REFERENCES MediosDePago(id_medio_pago),
    CONSTRAINT id_venta FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta)
);

CREATE TABLE DetallesVentas (
    id_detalle_venta DECIMAL(18,0) PRIMARY KEY,
    Precio DECIMAL(18,2),
    Cant_vendida DECIMAL(18,0),
    Subtotal DECIMAL(18,2),
    CONSTRAINT id_publicacion FOREIGN KEY (id_publicacion) REFERENCES Publicaciones(id_publicacion)
);

CREATE TABLE Ventas (
    id_venta DECIMAL(18,0) PRIMARY KEY,
    Fecha_hora_venta DATETIME,
    Total_venta DECIMAL(18,2),
    CONSTRAINT id_usuario_cliente FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    CONSTRAINT id_detalle_venta FOREIGN KEY (id_detalle_venta) REFERENCES DetallesVentas(id_detalle_venta),
);

CREATE TABLE MediosDeEnvio (
    id_medio_envio DECIMAL(18,0) PRIMARY KEY,
    Tipo NVARCHAR(30)
);

CREATE TABLE Envios (
    id_envio DECIMAL(18,0) PRIMARY KEY,
    Fecha_programada DATE,
    Hora_inicio TIME,
    Hora_fin TIME,
    Costo_envio DECIMAL(18,2),
    Fecha_hora_entregado DATETIME NULL,
    CONSTRAINT id_venta FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    CONSTRAINT id_domicilio FOREIGN KEY (id_domicilio) REFERENCES Domicilios(id_domicilio),
    CONSTRAINT id_medio_envio FOREIGN KEY (id_medio_envio) REFERENCES MediosDeEnvio(id_medio_envio)
);

CREATE TABLE Rubros (
    id_rubro DECIMAL(18,0) PRIMARY KEY,
    Nombre_rubro NVARCHAR(60),
    Descripcion_rubro NVARCHAR(50)
);

CREATE TABLE SubRubros (
    id_subrubro DECIMAL(18,0) PRIMARY KEY,
    Nombre_subrubro NVARCHAR(60),
    CONSTRAINT id_rubro FOREIGN KEY (id_rubro) REFERENCES Rubros(id_rubro)
);

CREATE TABLE Marcas (
    id_marca DECIMAL(18,0) PRIMARY KEY,
    Nombre_marca NVARCHAR(50)
);

CREATE TABLE Modelos (
    id_modelo DECIMAL(18,0) PRIMARY KEY,
    Descripcion_modelo NVARCHAR(50)
);

CREATE TABLE Productos (
    id_producto DECIMAL(18,0) PRIMARY KEY,
    Codigo NVARCHAR(50),
    Descripcion_producto NVARCHAR(255),
    CONSTRAINT id_modelo FOREIGN KEY (id_modelo) REFERENCES Modelos(id_modelo),
    CONSTRAINT id_subrubro FOREIGN KEY (id_subrubro) REFERENCES SubRubros(id_subrubro),
    CONSTRAINT id_marca FOREIGN KEY (id_marca) REFERENCES Marcas(id_marca)
);

CREATE TABLE Publicaciones (
    id_publicacion DECIMAL(18,0) PRIMARY KEY,
    Descripcion_publicacion NVARCHAR(50),
    Fecha_inicio DATE,
    Fecha_fin DATE,
    Stock DECIMAL(8,0),
    Precio_unitario DECIMAL(18,2),
    Costo_publicacion DECIMAL(18,2),
    Comision_venta_ptge DECIMAL(18,2), --Que era ptge??? O lei mal???
    CONSTRAINT id_producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    CONSTRAINT id_usuario_vendedor FOREIGN KEY (id_usuario) REFERENCES Usuarioss(id_usuario),
    CONSTRAINT id_almacen FOREIGN KEY (id_almacen) REFERENCES Almacenes(id_almacen)
);

--TRIGGERS Y CONSTRAINTS

CREATE PROCEDURE sp_ValidarDatos
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

CREATE TRIGGER trg_VerificarPublicaciones
ON Publicaciones
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @precio DECIMAL(18,2),
            @stock DECIMAL(18,0),
            @fecha_inicio DATE,
            @fecha_fin DATE;

    SELECT @precio = Precio_unitario, 
           @stock = Stock, 
           @fecha_inicio = Fecha_inicio, 
           @fecha_fin = Fecha_fin
    FROM inserted;

    EXEC sp_ValidarDatos 
        @precio = @precio, 
        @stock = @stock, 
        @fecha_inicio = @fecha_inicio, 
        @fecha_fin = @fecha_fin;

END;

CREATE TRIGGER trg_VerificarAlmacenes
ON Almacenes
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @precio DECIMAL(18,2);

    SELECT @precio = Costo_diario, 
    FROM inserted;

    EXEC sp_ValidarDatos 
        @precio = @precio, 

END;

CREATE TRIGGER trg_VerificarClientes
ON Clientes
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @fecha_fin DATE;

    SELECT  @fecha_fin = Fecha_de_nacimiento
    FROM inserted;

    EXEC sp_ValidarDatos 
        @fecha_fin = @fecha_fin;

END;

CREATE TRIGGER trg_VerificarUsuarios
ON Usuarios
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @fecha_fin DATE;

    SELECT @fecha_fin = Fecha_creacion
    FROM inserted;

    EXEC sp_ValidarDatos 
         @fecha_fin = @fecha_fin;

END;

CREATE TRIGGER trg_VerificarConceptosFacturacion
ON ConceptosFacturacion
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @cantidad;

    SELECT @cantidad = Cantidad
    FROM inserted;

    EXEC sp_ValidarDatos 
        @cantidad = @cantidad;

END;

CREATE TRIGGER trg_VerificarDetallesFacturas
ON DetallesFacturas
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @precio DECIMAL(18,2);

    SELECT @precio = Precio
    FROM inserted;

    EXEC sp_ValidarDatos 
        @precio = @precio;

END;

CREATE TRIGGER trg_VerificarFacturas
ON Facturas
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @precio DECIMAL(18,2),
            @subtotal DECIMAL(18,2),
            @importe DECIMAL(18,2),
            @fecha_fin DATE;

    SELECT @precio = Total_factura, 
           @subtotal = Subtotal_factura, 
           @importe = Importe_total, 
           @fecha_fin = Fecha_emision
    FROM inserted;

    EXEC sp_ValidarDatos 
        @precio = @precio, 
        @subtotal = @subtotal, 
        @importe = @importe, 
        @fecha_fin = @fecha_fin;

END;

CREATE TRIGGER trg_VerificarDetallesPagosTarjeta
ON DetallesPagosTarjeta
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @cantidad DECIMAL(18,0),
            @fecha_fin DATE;

    SELECT @cantidad = Cant_cuotas, 
           @fecha_fin = Fecha_vencimiento
    FROM inserted;

    EXEC sp_ValidarDatos 
        @cantidad = @cantidad, 
        @fecha_fin = @fecha_fin;

END;

CREATE TRIGGER trg_VerificarPagos
ON Pagos
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @importe DECIMAL(18,2),
            @fecha_fin DATE;

    SELECT @importe = Importe,  
           @fecha_fin = Fecha_pago
    FROM inserted;

    EXEC sp_ValidarDatos 
        @importe = @importe, 
        @fecha_fin = @fecha_fin;

END;

CREATE TRIGGER trg_VerificarDetallesVentas
ON DetallesVentas
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @precio DECIMAL(18,2),
            @cantidad DECIMAL(18,0),
            @subtotal DECIMAL(18,2);

    SELECT @precio = Precio, 
           @cantidad = Cant_vendida,  
           @subtotal = Subtotal
    FROM inserted;

    EXEC sp_ValidarDatos 
        @precio = @precio, 
        @cantidad = @cantidad, 
        @subtotal = @subtotal;

END;

CREATE TRIGGER trg_VerificarVentas
ON Ventas
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @precio DECIMAL(18,2),
            @fecha_fin DATE;

    SELECT @precio = Total_venta, 
           @fecha_fin = Fecha_hora_venta
    FROM inserted;

    EXEC sp_ValidarDatos 
        @precio = @precio, 
        @fecha_fin = @fecha_fin;

END;

CREATE TRIGGER trg_VerificarEnvios
ON Envios
BEFORE INSERT, UPDATE
AS
BEGIN
    
    DECLARE @precio DECIMAL(18,2),
            @fecha_inicio DATE,
            @fecha_fin DATE;

    SELECT @precio = Costo_envio, 
           @fecha_inicio = Fecha_programada, 
           @fecha_fin = Fecha_hora_entregado
    FROM inserted;

    EXEC sp_ValidarDatos 
        @precio = @precio, 
        @fecha_inicio = @fecha_inicio, 
        @fecha_fin = @fecha_fin;

END;
