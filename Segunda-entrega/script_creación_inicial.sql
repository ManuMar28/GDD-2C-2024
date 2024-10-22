CREATE TABLE Provincias (
    id_provincia DECIMAL(18,0) PRIMARY KEY,
    Nombre NVARCHAR(25)
);

CREATE TABLE Ubicaciones (
    id_ubicacion DECIMAL(18,0) PRIMARY KEY,
    Calle NVARCHAR(150),
    Altura NVARCHAR(5),
    Departamento NVARCHAR(3),
    CONSTRAINT id_provincia FOREIGN KEY (id_provincia) REFERENCES Provincias(id_provincia)
);

CREATE TABLE Almacenes (
    id_almacen DECIMAL(18,0) PRIMARY KEY,
    CONSTRAINT id_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id_ubicacion)
);

CREATE TABLE Domicilios (
    id_domicilio DECIMAL(18,0) PRIMARY KEY,
    CONSTRAINT id_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT id_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id_ubicacion)
);

CREATE TABLE Clientes (
    id_cliente DECIMAL(18,0) PRIMARY KEY,
    Nombre NVARCHAR(50),
    Apellido NVARCHAR(30),
    Fecha_de_nacimiento DATE,
    Dni VARCHAR(8)
);

CREATE TABLE Vendedores (
    id_vendedor DECIMAL(18,0) PRIMARY KEY,
    Razon_social NVARCHAR(50),
    Cuit VARCHAR(11)
);

CREATE TABLE Usuarios (
    id_usuario DECIMAL(18,0) PRIMARY KEY,
    id_cliente DECIMAL(18,0) NULL,
    id_vendedor DECIMAL(18,0) NULL,
    CONSTRAINT id_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT id_vendedor FOREIGN KEY (id_vendedor) REFERENCES Vendedores(id_vendedor)
);

CREATE TABLE ConceptosFacturacion (
    id_concepto DECIMAL(18,0) PRIMARY KEY,
    Concepto DECIMAL(12,2),
    Cantidad INT,
    CONSTRAINT id_detalle_factura FOREIGN KEY (id_detalle_factura) REFERENCES DetallesFacturas(id_detalle_factura)
);

CREATE TABLE DetallesFacturas (
    id_detalle_factura DECIMAL(18,0) PRIMARY KEY,
    Precio DECIMAL(14,2),
    CONSTRAINT id_publicacion FOREIGN KEY (id_publicacion) REFERENCES Publicaciones(id_publicacion)
);

CREATE TABLE Facturas (
    id_facturas DECIMAL(18,0) PRIMARY KEY,
    Fecha_emision DATE,
    Importe_total DECIMAL(14,2),   
    Total_factura DECIMAL(14,2),
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
    Fecha_vencimiento VARCHAR(5),
    Cant_cuotas INT
);

CREATE TABLE Pagos (
    id_pago DECIMAL(18,0) PRIMARY KEY,
    Importe DECIMAL(14,2),
    CONSTRAINT id_detalle_pago FOREIGN KEY (id_detalle_pago) REFERENCES DetallesPagosTarjeta(id_detalle_pago),
    CONSTRAINT id_medio_pago FOREIGN KEY (id_medio_pago) REFERENCES MediosDePago(id_medio_pago),
    CONSTRAINT id_venta FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta)
);

CREATE TABLE DetallesVentas (
    id_detalle_venta DECIMAL(18,0) PRIMARY KEY,
    Precio DECIMAL(14,2),
    Cant_vendida INT,
    Subtotal DECIMAL(14,2),
    CONSTRAINT id_publicacion FOREIGN KEY (id_publicacion) REFERENCES Publicaciones(id_publicacion)
);

CREATE TABLE Ventas (
    id_venta DECIMAL(18,0) PRIMARY KEY,
    Fecha_hora_venta DATETIME,
    Total_venta DECIMAL(14,2),
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
    Costo_envio DECIMAL(7,2),
    Fecha_hora_entregado DATETIME NULL,
    CONSTRAINT id_venta FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    CONSTRAINT id_domicilio FOREIGN KEY (id_domicilio) REFERENCES Domicilios(id_domicilio),
    CONSTRAINT id_medio_envio FOREIGN KEY (id_medio_envio) REFERENCES MediosDeEnvio(id_medio_envio)
);

CREATE TABLE Rubros (
    id_rubro DECIMAL(18,0) PRIMARY KEY,
    Nombre_rubro NVARCHAR(60)
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

CREATE TABLE Productos (
    id_producto DECIMAL(18,0) PRIMARY KEY,
    Descripcion_producto NVARCHAR(255),
    Modelo NVARCHAR(255),
    CONSTRAINT id_subrubro FOREIGN KEY (id_subrubro) REFERENCES SubRubros(id_subrubro),
    CONSTRAINT id_marca FOREIGN KEY (id_marca) REFERENCES Marcas(id_marca)
);

CREATE TABLE Publicaciones (
    id_publicacion DECIMAL(18,0) PRIMARY KEY,
    Descripcion_publicacion NVARCHAR(255),
    Fecha_inicio DATE,
    Fecha_fin DATE,
    Stock DECIMAL(8,0),
    Precio_unitario DECIMAL(14,2),
    Costo_publicacion DECIMAL(7,2),
    Comision_venta_ptge DECIMAL(5,2), --Que era ptge??? O lei mal???
    CONSTRAINT id_producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    CONSTRAINT id_usuario_vendedor FOREIGN KEY (id_usuario) REFERENCES Usuarioss(id_usuario),
    CONSTRAINT id_almacen FOREIGN KEY (id_almacen) REFERENCES Almacenes(id_almacen)
);
