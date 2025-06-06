-- 1. Tabla de tipos de usuarios
CREATE TABLE tipos_usuarios (
    tipo_id   INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(50)    NOT NULL
);

-- 2. Tabla de usuarios (clientes o empleados)
CREATE TABLE usuarios (
    usuario_id     INT AUTO_INCREMENT PRIMARY KEY,
    tipo_id        INT NOT NULL,
    nombre         VARCHAR(50)    NOT NULL,
    email          VARCHAR(50)    NOT NULL UNIQUE,
    telefono       VARCHAR(15),
    direccion      VARCHAR(100),
    ciudad         VARCHAR(50),
    pais           VARCHAR(50),
    fecha_registro DATE           NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_usuarios_tipos
        FOREIGN KEY (tipo_id)
        REFERENCES tipos_usuarios(tipo_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
-- 3. Tabla de productos
CREATE TABLE proveedores (
    proveedor_id   INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100)   NOT NULL,
    email          VARCHAR(100)   UNIQUE,
    telefono       VARCHAR(20),
    direccion      VARCHAR(150),
    ciudad         VARCHAR(50),
    pais           VARCHAR(50),
    fecha_registro DATE           NOT NULL DEFAULT (CURRENT_DATE)
);
-- 4. Tabla de productos
CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(50)    NOT NULL,
    categoria   VARCHAR(50)    NOT NULL,
    precio      DECIMAL(10,2)  NOT NULL  DEFAULT 0.00,
    stock       INT            NOT NULL  DEFAULT 0,
    INDEX idx_productos_categoria (categoria)
);

-- 5. Tabla de proveedores de productos
CREATE TABLE proveedores_productos (
    proveedor_id INT NOT NULL,
    producto_id  INT NOT NULL,
    PRIMARY KEY (proveedor_id, producto_id),
    INDEX idx_pp_proveedor   (proveedor_id),
    INDEX idx_pp_producto    (producto_id),
    CONSTRAINT fk_pp_proveedor
        FOREIGN KEY (proveedor_id) 
        REFERENCES proveedores(proveedor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pp_producto
        FOREIGN KEY (producto_id) 
        REFERENCES productos(producto_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 6. Tabla de empleados, Un empleado está asociado a un registro en 'usuarios'
CREATE TABLE empleados (
    empleado_id       INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id        INT NOT NULL,
    puesto            VARCHAR(50)     NOT NULL,
    fecha_contratacion DATE           NOT NULL,
    salario           DECIMAL(10,2)   NOT NULL  DEFAULT 0.00,
    CONSTRAINT fk_empleados_usuarios
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(usuario_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 7. Tabla de pedidos
CREATE TABLE pedidos (
    pedido_id     INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id    INT NOT NULL,      -- FK a 'usuarios'
    empleado_id   INT NOT NULL,      -- FK a 'empleados' (quién atendió el pedido)
    fecha_pedido  DATE NOT NULL      DEFAULT (CURRENT_DATE),
    estado        ENUM('Pendiente','Procesando','Enviado','Entregado','Cancelado') NOT NULL DEFAULT 'Pendiente',
    INDEX idx_pedidos_fecha (fecha_pedido),
    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES usuarios(usuario_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_pedidos_empleado
        FOREIGN KEY (empleado_id)
        REFERENCES empleados(empleado_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 8. Tabla de detalles_pedidos
CREATE TABLE detalles_pedidos (
    detalle_id      INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id       INT NOT NULL,
    producto_id     INT NOT NULL,
    cantidad        INT NOT NULL     DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    --
    CONSTRAINT fk_detalles_ped_pedido
        FOREIGN KEY (pedido_id)
        REFERENCES pedidos(pedido_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detalles_ped_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(producto_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    INDEX idx_detalles_pedido (pedido_id),
    INDEX idx_detalles_producto (producto_id)
);