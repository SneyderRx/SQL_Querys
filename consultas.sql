--!Consultas básicas
--Consulta todos los datos de la tabla usuarios para ver la lista completa de clientes.
SELECT * FROM usuarios;

--Muestra los nombres y correos electrónicos de todos los clientes que residen en la ciudad de Madrid.
SELECT nombre, email
FROM usuarios
WHERE tipo_id=1;

--Obtén una lista de productos con un precio mayor a $100.000, mostrando solo el nombre y el precio.
SELECT nombre, precio
FROM productos
WHERE precio > 100000;

--Encuentra todos los empleados que tienen un salario superior a $2.500.000, mostrando su nombre, puesto y salario.
SELECT u.nombre, e.puesto, e.salario
FROM empleados AS e
JOIN usuarios AS u ON e.usuario_id=u.usuario_id
WHERE salario > 2500000;

--Lista los nombres de los productos en la categoría "Electrónica", ordenados alfabéticamente.
SELECT nombre
FROM productos
WHERE categoria='Electrónica'
ORDER BY nombre ASC;

--Muestra los detalles de los pedidos que están en estado "Pendiente", incluyendo el ID del pedido, el ID del cliente y la fecha del pedido.
SELECT p.pedido_id, p.cliente_id, p.fecha_pedido, dp.*
FROM pedidos AS p
JOIN detalles_pedidos AS dp ON p.pedido_id=dp.pedido_id;

--Encuentra el nombre y el precio del producto más caro en la base de datos.
SELECT (
    (SELECT MAX(pp.precio) AS precio
    FROM productos AS pp
    WHERE pp.nombre = p.nombre)
) AS precio_max, p.nombre AS nombre
FROM productos AS p
GROUP BY nombre
LIMIT 1; -- Lo dejaré para acordarme de la otra forma

SELECT nombre, MAX(precio) AS precio
FROM productos
GROUP BY nombre
LIMIT 1;

--Obtén el total de pedidos realizados por cada cliente, mostrando el ID del cliente y el total de pedidos.
SELECT cliente_id, COUNT(pedido_id) AS 'cantidad de pedidos'
FROM pedidos
GROUP BY cliente_id;

--Calcula el promedio de salario de todos los empleados en la empresa.
SELECT AVG(salario) AS 'promedio salarial'
FROM empleados

--Encuentra el número de productos en cada categoría, mostrando la categoría y el número de productos.
SELECT categoria, COUNT(producto_id) AS 'número de productos'
FROM productos
GROUP BY categoria;

--Obtén una lista de productos con un precio mayor a $75 USD, mostrando solo el nombre, el precio y su respectivo precio en USD.
SELECT nombre, precio, (precio/4100) AS 'precio en dolares'
FROM productos
WHERE (precio/4100) > 75;

--Lista todos los proveedores registrados.
SELECT nombre
FROM proveedores;

--!Consultas multitabla joins
--Encuentra los nombres de los clientes y los detalles de sus pedidos.
SELECT u.nombre, dp.*
FROM usuarios AS u
JOIN pedidos AS p ON u.usuario_id = p.cliente_id
JOIN detalles_pedidos AS dp ON p.pedido_id = dp.pedido_id;

--Lista todos los productos pedidos junto con el precio unitario de cada pedido
SELECT p.nombre, dp.precio_unitario
FROM productos AS p
JOIN detalles_pedidos AS dp USING (producto_id);

--Encuentra los nombres de los clientes y los nombres de los empleados que gestionaron sus pedidos
SELECT u.nombre, p.estado
FROM usuarios AS u
JOIN pedidos AS p ON u.usuario_id = p.cliente_id
WHERE estado = 'Entregado';

--Muestra todos los pedidos y, si existen, los productos en cada pedido, incluyendo los pedidos sin productos usando LEFT JOIN
SELECT *
FROM pedidos AS p
LEFT JOIN detalles_pedidos AS dp USING(pedido_id);

--Encuentra los productos y, si existen, los detalles de pedidos en los que no se ha incluido el producto usando RIGHT JOIN.
SELECT *
FROM detalles_pedidos AS dp
RIGHT JOIN pedidos AS p USING(pedido_id);

--Lista todos los empleados junto con los pedidos que han gestionado, si existen, usando LEFT JOIN para ver los empleados sin pedidos.
SELECT u.nombre, e.empleado_id, e.puesto, p.pedido_id, p.fecha_pedido, p.estado
FROM empleados AS e
LEFT JOIN pedidos AS p USING(empleado_id)
LEFT JOIN usuarios AS u USING(usuario_id);

--Encuentra los empleados que no han gestionado ningún pedido usando un LEFT JOIN combinado con WHERE.
SELECT u.nombre, e.empleado_id, e.puesto, p.pedido_id, p.fecha_pedido, p.estado
FROM empleados AS e
LEFT JOIN pedidos AS p USING(empleado_id)
LEFT JOIN usuarios AS u USING(usuario_id)
WHERE p.empleado_id IS NULL; -- No dará ningún resultado debido a que todos los empleados han gestionado al menos un pedido.

--Calcula el total gastado en cada pedido, mostrando el ID del pedido y el total, usando JOIN.
SELECT p.pedido_id, (dp.cantidad * dp.precio_unitario) AS total
FROM pedidos AS p
JOIN detalles_pedidos AS dp USING(pedido_id);

--Realiza un CROSS JOIN entre clientes y productos para mostrar todas las combinaciones posibles de clientes y productos.
SELECT u.nombre AS 'nombre cliente', p.nombre AS 'nombre producto'
FROM usuarios AS u
CROSS JOIN productos AS p
WHERE u.tipo_id = 1
ORDER BY u.nombre;

--Encuentra los nombres de los clientes y los productos que han comprado, si existen, incluyendo los clientes que no han realizado pedidos usando LEFT JOIN.
SELECT u.nombre, pr.nombre AS 'nombre producto'
FROM usuarios AS u
LEFT JOIN pedidos AS p ON u.usuario_id = p.cliente_id
LEFT JOIN detalles_pedidos AS dp USING(pedido_id)
LEFT JOIN productos AS pr USING(producto_id)
WHERE u.tipo_id = 1
ORDER BY u.nombre;

--Listar todos los proveedores que suministran un determinado producto.
SELECT p.nombre, pp.producto_id, pr.nombre
FROM proveedores AS p
JOIN proveedores_productos AS pp USING(proveedor_id)
JOIN productos AS pr USING(producto_id)
WHERE pp.producto_id = 1;

--Obtener todos los productos que ofrece un proveedor específico.
SELECT p.nombre, pr.nombre, pr.categoria
FROM proveedores AS p
JOIN proveedores_productos AS pp USING(proveedor_id)
JOIN productos AS pr USING(producto_id)
WHERE p.nombre = 'Global Components Ltda.';

--Lista los proveedores que no están asociados a ningún producto (es decir, que aún no suministran).
SELECT *
FROM proveedores AS p
LEFT JOIN proveedores_productos AS pp USING(proveedor_id)
WHERE pp.producto_id IS NULL;

--Contar cuántos proveedores tiene cada producto.
SELECT pp.producto_id, pr.nombre AS 'nombre producto', COUNT(pp.proveedor_id) AS 'total proveedores'
FROM proveedores_productos AS pp
JOIN productos AS pr USING(producto_id)
GROUP BY pp.producto_id, pr.nombre

--Para un proveedor determinado (p. ej. proveedor_id = 3), muestra el nombre de todos los productos que suministra.
SELECT pp.proveedor_id, p.nombre
FROM proveedores_productos AS pp
LEFT JOIN productos AS p USING(producto_id)
WHERE pp.proveedor_id = 3

--Para un producto específico (p. ej. producto_id = 1), muestra todos los proveedores que lo distribuyen, con sus datos de contacto.
SELECT pp.producto_id, p.nombre AS 'nombre proveedor', p.email, p.telefono
FROM proveedores_productos AS pp
JOIN proveedores AS p USING(proveedor_id)
WHERE pp.producto_id = 1;

--Cuenta cuántos proveedores tiene cada producto, listando producto_id, nombre y cantidad_proveedores.
SELECT p.producto_id, p.nombre, COUNT(proveedor_id) AS 'cantidad_proveedores'
FROM productos AS p
LEFT JOIN proveedores_productos AS pp USING(producto_id)
GROUP BY producto_id, nombre;

--Cuenta cuántos productos suministra cada proveedor, mostrando proveedor_id, nombre_proveedor y total_productos.
SELECT proveedor_id, p.nombre AS 'nombre_proveedor', COUNT(producto_id) AS 'total_productos'
FROM proveedores AS p
LEFT JOIN proveedores_productos AS pp USING(proveedor_id)
GROUP BY proveedor_id, 'nombre_proveedor'

--!Subconsultas
--Encuentra los nombres de los clientes que han realizado al menos un pedido de más de $500.000.
SELECT DISTINCT
  u.nombre AS nombre_cliente
FROM usuarios AS u
JOIN pedidos AS p
  ON u.usuario_id = p.cliente_id
JOIN detalles_pedidos AS dp
  ON p.pedido_id = dp.pedido_id
WHERE
  u.tipo_id = (
    SELECT
      tipo_id
    FROM tipos_usuarios
    WHERE
      nombre = 'Cliente'
  ) AND dp.precio_unitario * dp.cantidad > 500000;

--Muestra los productos que nunca han sido pedidos.
SELECT
  p.nombre AS nombre_producto
FROM productos AS p
LEFT JOIN detalles_pedidos AS dp
  ON p.producto_id = dp.producto_id
WHERE
  dp.producto_id IS NULL;

--Lista los empleados que han gestionado pedidos en los últimos 6 meses.
SELECT DISTINCT
  u.nombre AS nombre_empleado
FROM usuarios AS u
JOIN empleados AS e
  ON u.usuario_id = e.usuario_id
JOIN pedidos AS p
  ON e.empleado_id = p.empleado_id
WHERE
  p.fecha_pedido >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH) AND u.tipo_id = (
    SELECT
      tipo_id
    FROM tipos_usuarios
    WHERE
      nombre = 'Empleado'
  );

--Encuentra el pedido con el total de ventas más alto.
SELECT
  p.pedido_id,
  SUM(dp.cantidad * dp.precio_unitario) AS total_venta
FROM pedidos AS p
JOIN detalles_pedidos AS dp
  ON p.pedido_id = dp.pedido_id
GROUP BY
  p.pedido_id
ORDER BY
  total_venta DESC
LIMIT 1;

--Muestra los nombres de los clientes que han realizado más pedidos que el promedio de pedidos de todos los clientes.

--Obtén los productos cuyo precio es superior al precio promedio de todos los productos.
SELECT
  nombre AS nombre_producto,
  precio
FROM productos
WHERE
  precio > (
    SELECT
      AVG(precio)
    FROM productos
  );

--Lista los clientes que han gastado más de $1.000.000 en total.

--Encuentra los empleados que ganan un salario mayor al promedio de la empresa.

--Obtén los productos que generaron ingresos mayores al ingreso promedio por producto.

--Encuentra el nombre del cliente que realizó el pedido más reciente.

--Muestra los productos pedidos al menos una vez en los últimos 3 meses.

--Lista los empleados que no han gestionado ningún pedido.

--Encuentra los clientes que han comprado más de tres tipos distintos de productos.

--Muestra el nombre del producto más caro que se ha pedido al menos cinco veces.

--Lista los clientes cuyo primer pedido fue un año después de su registro.

--Encuentra los nombres de los productos que tienen un stock inferior al promedio del stock de todos los productos.

--Lista los clientes que han realizado menos de tres pedidos.

--Encuentra los nombres de los productos que fueron pedidos por los clientes que registraron en el último año.

--Obtén el nombre del empleado que gestionó el mayor número de pedidos.

--Lista los productos que han sido comprados en cantidades mayores que el promedio de cantidad de compra de todos los productos.

--Proveedores que suministran más productos que el promedio de productos por proveedor.

--Proveedores que solo suministran productos de la categoría "Electrónica".

--Productos que solo tienen proveedores registrados hace más de un año.