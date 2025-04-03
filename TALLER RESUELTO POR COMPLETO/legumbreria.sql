-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-04-2025 a las 05:24:37
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `legumbreria`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarStock` (IN `pedido_id` INT)   BEGIN
    UPDATE productos p
    JOIN detalles_pedido dp ON p.id_producto = dp.id_producto
    SET p.stock = p.stock - dp.cantidad
    WHERE dp.id_pedido = pedido_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `BloquearUsuario` (IN `usuario_id` INT)   BEGIN
    UPDATE usuario SET bloqueado = TRUE WHERE id = usuario_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DesbloquearUsuario` (IN `usuario_id` INT)   BEGIN
    UPDATE usuario SET bloqueado = FALSE, intentos_fallidos = 0 WHERE id = usuario_id;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `estado_producto` (`id_producto` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE stock_actual INT;
    
    SELECT stock INTO stock_actual
    FROM productos
    WHERE productos.id_producto = id_producto;
    
    IF stock_actual > 10 THEN
        RETURN 'Disponible';
    ELSEIF stock_actual BETWEEN 1 AND 10 THEN
        RETURN 'Pocas Unidades';
    ELSE
        RETURN 'Agotado';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `precio_promedio_productos` () RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE promedio DECIMAL(10,2);
    
    SELECT AVG(precio) INTO promedio FROM productos;
    
    RETURN IFNULL(promedio, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_compras_cliente` (`cliente_id` INT) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE total DECIMAL(10,2);
    
    SELECT SUM(total) INTO total FROM ventas WHERE id_cliente = cliente_id;
    
    RETURN IFNULL(total, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_compras_proveedor` (`id_proveedor` INT) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE total DECIMAL(10,2);
    
    SELECT SUM(total) INTO total
    FROM registro_compras
    WHERE registro_compras.id_proveedor = id_proveedor;
    
    RETURN IFNULL(total, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_gasto_cliente` (`id_cliente` INT) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE total DECIMAL(10,2);
    
    SELECT SUM(total) INTO total
    FROM ventas
    WHERE ventas.id_cliente = id_cliente;
    
    RETURN IFNULL(total, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_stock` () RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE total INT;
    
    SELECT SUM(stock) INTO total FROM productos;
    
    RETURN IFNULL(total, 0);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_stock`
--

CREATE TABLE `auditoria_stock` (
  `id_auditoria` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `stock_anterior` int(11) DEFAULT NULL,
  `stock_nuevo` int(11) DEFAULT NULL,
  `fecha_cambio` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria_stock`
--

INSERT INTO `auditoria_stock` (`id_auditoria`, `id_producto`, `stock_anterior`, `stock_nuevo`, `fecha_cambio`) VALUES
(1, 1, 100, 94, '2024-03-25 15:15:00'),
(2, 2, 85, 80, '2024-03-26 16:30:00'),
(3, 3, 50, 46, '2024-03-27 14:45:00'),
(4, 4, 60, 57, '2024-03-28 19:20:00'),
(5, 5, 42, 39, '2024-03-29 21:10:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombre`, `apellido`, `telefono`, `direccion`, `correo`) VALUES
(1, 'Juan', 'Pérez', '123456789', 'Calle 1 #23-45', 'juan.perez@email.com'),
(2, 'María', 'Gómez', '987654321', 'Carrera 2 #34-56', 'maria.gomez@email.com'),
(3, 'Carlos', 'López', '321654987', 'Avenida 3 #12-34', 'carlos.lopez@email.com'),
(4, 'Sofía', 'Díaz', '876543210', 'Calle 4 #10-11', 'sofia.diaz@email.com'),
(5, 'Ricardo', 'Torres', '765432109', 'Carrera 5 #22-33', 'ricardo.torres@email.com'),
(6, 'Laura', 'Martínez', '654321098', 'Diagonal 6 #44-55', 'laura.martinez@email.com'),
(7, 'Andrés', 'Hernández', '543210987', 'Calle 7 #66-77', 'andres.hernandez@email.com'),
(8, 'Valeria', 'Fernández', '432109876', 'Carrera 8 #88-99', 'valeria.fernandez@email.com'),
(9, 'Miguel', 'Ortega', '321098765', 'Avenida 9 #12-23', 'miguel.ortega@email.com'),
(10, 'Paula', 'Castro', '210987654', 'Transversal 10 #34-45', 'paula.castro@email.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_compras`
--

CREATE TABLE `detalles_compras` (
  `id_detalle` int(11) NOT NULL,
  `id_compra` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_compra` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalles_compras`
--

INSERT INTO `detalles_compras` (`id_detalle`, `id_compra`, `id_producto`, `cantidad`, `precio_compra`, `subtotal`) VALUES
(1, 1, 1, 10, 3000.00, 30000.00),
(2, 2, 3, 5, 5000.00, 25000.00),
(3, 3, 5, 7, 7000.00, 35000.00),
(4, 4, 7, 8, 10000.00, 40000.00),
(5, 5, 9, 6, 5000.00, 28000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_pedido`
--

CREATE TABLE `detalles_pedido` (
  `id_detalle` int(11) NOT NULL,
  `id_pedido` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalles_pedido`
--

INSERT INTO `detalles_pedido` (`id_detalle`, `id_pedido`, `id_producto`, `cantidad`, `precio_unitario`) VALUES
(1, 1, 1, 5, 5000.00),
(2, 1, 3, 2, 5500.00),
(3, 2, 6, 10, 4000.00),
(4, 3, 7, 1, 12000.00),
(5, 4, 2, 3, 6000.00),
(6, 5, 9, 4, 9000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_ventas`
--

CREATE TABLE `detalles_ventas` (
  `id_detalle` int(11) NOT NULL,
  `id_venta` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalles_ventas`
--

INSERT INTO `detalles_ventas` (`id_detalle`, `id_venta`, `id_producto`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1, 1, 2, 5000.00, 10000.00),
(2, 1, 2, 1, 5000.00, 5000.00),
(3, 2, 3, 2, 5500.00, 11000.00),
(4, 3, 4, 3, 5000.00, 15000.00),
(5, 4, 5, 1, 7000.00, 7000.00),
(6, 6, 1, 3, 5000.00, 15000.00),
(7, 6, 3, 2, 5500.00, 11000.00);

--
-- Disparadores `detalles_ventas`
--
DELIMITER $$
CREATE TRIGGER `actualizar_stock_despues_venta` AFTER INSERT ON `detalles_ventas` FOR EACH ROW BEGIN
    UPDATE productos 
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `evitar_venta_sin_stock` BEFORE INSERT ON `detalles_ventas` FOR EACH ROW BEGIN
    DECLARE stock_actual INT;
    
    -- Obtener stock actual del producto
    SELECT stock INTO stock_actual
    FROM productos
    WHERE id_producto = NEW.id_producto;
    
    -- Si el stock es insuficiente, genera un error
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock para esta venta';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `reducir_stock_venta` AFTER INSERT ON `detalles_ventas` FOR EACH ROW BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verificar_stock_antes_venta` BEFORE INSERT ON `detalles_ventas` FOR EACH ROW BEGIN
    DECLARE stock_actual INT;
    
    -- Obtener el stock del producto
    SELECT stock INTO stock_actual FROM productos WHERE id_producto = NEW.id_producto;
    
    -- Verificar si hay suficiente stock
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No hay suficiente stock disponible para este producto.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `cargo` varchar(50) DEFAULT NULL,
  `salario` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `nombre`, `apellido`, `telefono`, `cargo`, `salario`) VALUES
(1, 'Pedro', 'Martínez', '555123456', 'Cajero', 1200000.00),
(2, 'Ana', 'Rodríguez', '555654321', 'Vendedor', 1300000.00),
(3, 'Luis', 'García', '555987654', 'Administrador', 2000000.00),
(4, 'Diana', 'Jiménez', '555246813', 'Cajero', 1250000.00),
(5, 'Miguel', 'Ortega', '555369147', 'Vendedor', 1350000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_cambios`
--

CREATE TABLE `historial_cambios` (
  `id_historial` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `precio_anterior` decimal(10,2) NOT NULL,
  `precio_nuevo` decimal(10,2) NOT NULL,
  `fecha_cambio` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial_cambios`
--

INSERT INTO `historial_cambios` (`id_historial`, `id_producto`, `precio_anterior`, `precio_nuevo`, `fecha_cambio`) VALUES
(1, 1, 2.50, 2.80, '2024-04-01 05:00:00'),
(2, 2, 1.20, 1.50, '2024-04-02 05:00:00'),
(3, 3, 0.90, 1.00, '2024-04-03 05:00:00'),
(4, 4, 1.10, 1.30, '2024-04-04 05:00:00'),
(5, 5, 1.50, 1.70, '2024-04-05 05:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_precios`
--

CREATE TABLE `historial_precios` (
  `id_historial` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `precio_anterior` decimal(10,2) DEFAULT NULL,
  `precio_nuevo` decimal(10,2) DEFAULT NULL,
  `fecha_cambio` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial_precios`
--

INSERT INTO `historial_precios` (`id_historial`, `id_producto`, `precio_anterior`, `precio_nuevo`, `fecha_cambio`) VALUES
(1, 1, 4800.00, 5000.00, '2024-03-15 05:00:00'),
(2, 2, 5800.00, 6000.00, '2024-03-16 05:00:00'),
(3, 3, 5300.00, 5500.00, '2024-03-17 05:00:00'),
(4, 4, 4900.00, 5000.00, '2024-03-18 05:00:00'),
(5, 5, 6800.00, 7000.00, '2024-03-19 05:00:00'),
(6, 6, 3900.00, 4000.00, '2024-03-20 05:00:00'),
(7, 7, 11500.00, 12000.00, '2024-03-21 05:00:00'),
(8, 8, 14500.00, 15000.00, '2024-03-22 05:00:00'),
(9, 9, 8700.00, 9000.00, '2024-03-23 05:00:00'),
(10, 10, 6300.00, 6500.00, '2024-03-24 05:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_stock`
--

CREATE TABLE `historial_stock` (
  `id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `cantidad_anterior` int(11) NOT NULL,
  `cantidad_nueva` int(11) NOT NULL,
  `fecha_cambio` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historial_stock`
--

INSERT INTO `historial_stock` (`id`, `producto_id`, `cantidad_anterior`, `cantidad_nueva`, `fecha_cambio`) VALUES
(1, 1, 100, 94, '2024-04-01 15:00:00'),
(2, 2, 90, 80, '2024-04-01 16:30:00'),
(3, 3, 50, 46, '2024-04-02 14:45:00'),
(4, 4, 60, 57, '2024-04-02 19:10:00'),
(5, 5, 45, 39, '2024-04-03 13:20:00'),
(6, 6, 95, 90, '2024-04-03 20:45:00'),
(7, 7, 40, 30, '2024-04-04 17:10:00'),
(8, 8, 25, 20, '2024-04-04 21:30:00'),
(9, 9, 55, 50, '2024-04-05 15:00:00'),
(10, 10, 75, 70, '2024-04-05 23:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedidos`
--

CREATE TABLE `pedidos` (
  `id_pedido` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_pedido` timestamp NOT NULL DEFAULT current_timestamp(),
  `direccion_ip` varchar(45) DEFAULT NULL,
  `estado` enum('Pendiente','Completado','Cancelado') DEFAULT 'Pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pedidos`
--

INSERT INTO `pedidos` (`id_pedido`, `id_usuario`, `fecha_pedido`, `direccion_ip`, `estado`) VALUES
(1, 201, '2024-04-01 05:00:00', '192.168.1.10', 'Pendiente'),
(2, 202, '2024-04-02 05:00:00', '192.168.1.11', 'Completado'),
(3, 203, '2024-04-03 05:00:00', '192.168.1.12', 'Cancelado'),
(4, 204, '2024-04-04 05:00:00', '192.168.1.13', 'Pendiente'),
(5, 205, '2024-04-05 05:00:00', '192.168.1.14', 'Completado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precio`
--

CREATE TABLE `precio` (
  `id_historial` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `precio_anterior` decimal(10,2) NOT NULL,
  `precio_nuevo` decimal(10,2) NOT NULL,
  `fecha_cambio` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `precio`
--

INSERT INTO `precio` (`id_historial`, `id_producto`, `precio_anterior`, `precio_nuevo`, `fecha_cambio`) VALUES
(1, 1, 2.50, 2.80, '2024-04-01 05:00:00'),
(2, 2, 1.20, 1.50, '2024-04-02 05:00:00'),
(3, 3, 0.90, 1.00, '2024-04-03 05:00:00'),
(4, 4, 1.10, 1.30, '2024-04-04 05:00:00'),
(5, 5, 1.50, 1.70, '2024-04-05 05:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `categoria` varchar(50) DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `estado` enum('Bueno','Malo','Regular') NOT NULL DEFAULT 'Bueno',
  `id_proveedor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `nombre`, `categoria`, `precio`, `stock`, `estado`, `id_proveedor`) VALUES
(1, 'Lentejas', 'Legumbres', 5000.00, 94, 'Bueno', 1),
(2, 'Frijoles', 'Legumbres', 6000.00, 80, 'Bueno', 1),
(3, 'Garbanzos', 'Legumbres', 5500.00, 46, 'Regular', 2),
(4, 'Arvejas', 'Legumbres', 5000.00, 57, 'Malo', 3),
(5, 'Habas', 'Legumbres', 7000.00, 39, 'Bueno', 2),
(6, 'Maíz', 'Cereales', 4000.00, 90, 'Regular', 4),
(7, 'Quinua', 'Cereales', 12000.00, 30, 'Bueno', 3),
(8, 'Chía', 'Semillas', 15000.00, 20, 'Malo', 4),
(9, 'Linaza', 'Semillas', 9000.00, 50, 'Regular', 5),
(10, 'Soya', 'Legumbres', 6500.00, 70, 'Bueno', 1);

--
-- Disparadores `productos`
--
DELIMITER $$
CREATE TRIGGER `auditar_cambios_stock` AFTER UPDATE ON `productos` FOR EACH ROW BEGIN
    IF OLD.stock <> NEW.stock THEN
        INSERT INTO auditoria_stock (id_producto, stock_anterior, stock_nuevo)
        VALUES (NEW.id_producto, OLD.stock, NEW.stock);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `auditoria_stock` AFTER UPDATE ON `productos` FOR EACH ROW BEGIN
    INSERT INTO historial_stock (producto_id, cantidad_anterior, cantidad_nueva, fecha_cambio)
    VALUES (OLD.id_producto, OLD.stock, NEW.stock, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `evitar_eliminar_productos` BEFORE DELETE ON `productos` FOR EACH ROW BEGIN
    IF (SELECT COUNT(*) FROM detalles_pedido dp 
        JOIN pedidos p ON dp.id_pedido = p.id_pedido
        WHERE dp.id_producto = OLD.id_producto AND p.estado = 'Pendiente') > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un producto con pedidos pendientes';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `registrar_cambio_precio` BEFORE UPDATE ON `productos` FOR EACH ROW BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO historial_precios (id_producto, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (OLD.id_producto, OLD.precio, NEW.precio, NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id_proveedor` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id_proveedor`, `nombre`, `telefono`, `direccion`, `correo`) VALUES
(1, 'Proveedor A', '111222333', 'Zona Industrial 1', 'contacto@proveedora.com'),
(2, 'Proveedor B', '444555666', 'Zona Comercial 2', 'contacto@proveedorb.com'),
(3, 'Proveedor C', '777888999', 'Zona Industrial 3', 'contacto@proveedorc.com'),
(4, 'Proveedor D', '222333444', 'Zona Comercial 4', 'contacto@proveedord.com'),
(5, 'Proveedor E', '555666777', 'Zona Rural 5', 'contacto@proveedore.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro_compras`
--

CREATE TABLE `registro_compras` (
  `id_compra` int(11) NOT NULL,
  `fecha_compra` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_proveedor` int(11) DEFAULT NULL,
  `id_empleado` int(11) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `registro_compras`
--

INSERT INTO `registro_compras` (`id_compra`, `fecha_compra`, `id_proveedor`, `id_empleado`, `total`) VALUES
(1, '2025-03-26 03:18:42', 1, 1, 30000.00),
(2, '2025-03-26 03:18:42', 2, 2, 25000.00),
(3, '2025-03-26 03:29:32', 3, 3, 35000.00),
(4, '2025-03-26 03:29:32', 4, 4, 40000.00),
(5, '2025-03-26 03:29:32', 5, 5, 28000.00);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `reporte_ventas_mensuales`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `reporte_ventas_mensuales` (
`año` int(4)
,`mes` int(2)
,`total_ventas` decimal(42,2)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles_permisos`
--

CREATE TABLE `roles_permisos` (
  `id_permiso` int(11) NOT NULL,
  `rol` enum('Cliente','Vendedor','Administrador') NOT NULL,
  `permiso` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles_permisos`
--

INSERT INTO `roles_permisos` (`id_permiso`, `rol`, `permiso`) VALUES
(1, 'Administrador', 'Gestionar usuarios'),
(2, 'Administrador', 'Gestionar productos'),
(3, 'Administrador', 'Ver reportes'),
(4, 'Vendedor', 'Registrar ventas'),
(5, 'Vendedor', 'Actualizar stock'),
(6, 'Vendedor', 'Consultar precios'),
(7, 'Cliente', 'Realizar pedidos'),
(8, 'Cliente', 'Ver historial de compras');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `clave` varbinary(255) NOT NULL,
  `rol` enum('Cliente','Vendedor','Administrador') NOT NULL,
  `intentos_fallidos` int(11) DEFAULT 0,
  `bloqueado` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre`, `email`, `clave`, `rol`, `intentos_fallidos`, `bloqueado`) VALUES
(201, 'Juan Pérez', 'juan@example.com', 0x35616330383532653737303530366463643830663161333664323062613738373862663832323434623833366439333234353933626431346263353664636235, 'Cliente', 0, 0),
(202, 'María Gómez', 'maria@example.com', 0x63613863633966613734373063333163343935633137663237363135326439633961346230366332306563626665636666643635313239663364653962323464, 'Vendedor', 0, 0),
(203, 'Carlos López', 'carlos@example.com', 0x61616631643565363030633464626539356238663436663164376537356631386565323235326135646633643634313431313337643662633663613831316161, 'Administrador', 0, 0),
(204, 'Ana Torres', 'ana@example.com', 0x61653963316436643462353339643763333363613166346233306162303762623763356332393135633338383764643233643231393731376432323437316635, 'Cliente', 0, 0),
(205, 'Luis Ramírez', 'luis@example.com', 0x32393834313330386665396263396136626433376365396564643237613038623365316637393433333730623439356232653936353935613864346437663839, 'Vendedor', 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id_venta` int(11) NOT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_cliente` int(11) DEFAULT NULL,
  `id_empleado` int(11) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id_venta`, `fecha_venta`, `id_cliente`, `id_empleado`, `total`) VALUES
(1, '2025-03-26 03:18:42', 1, 1, 15000.00),
(2, '2025-03-26 03:18:42', 2, 2, 12000.00),
(3, '2025-03-26 03:28:47', 3, 3, 18000.00),
(4, '2025-03-26 03:28:47', 4, 4, 25000.00),
(5, '2025-03-26 03:28:47', 5, 5, 14000.00),
(6, '2025-03-26 03:33:21', 1, 1, 25000.00);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_clientes_frecuentes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_clientes_frecuentes` (
`id_cliente` int(11)
,`nombre` varchar(100)
,`apellido` varchar(100)
,`cantidad_compras` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_compras_recientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_compras_recientes` (
`id_compra` int(11)
,`fecha_compra` timestamp
,`proveedor` varchar(100)
,`empleado` varchar(100)
,`total` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_empleados_mayor_venta`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_empleados_mayor_venta` (
`id_empleado` int(11)
,`nombre` varchar(100)
,`apellido` varchar(100)
,`cargo` varchar(50)
,`cantidad_ventas` bigint(21)
,`total_vendido` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_pedidos_detalles`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_pedidos_detalles` (
`id_pedido` int(11)
,`fecha_pedido` timestamp
,`cliente` varchar(100)
,`producto` varchar(100)
,`cantidad` int(11)
,`precio_unitario` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_bajo_stock`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_bajo_stock` (
`id_producto` int(11)
,`nombre` varchar(100)
,`categoria` varchar(50)
,`stock` int(11)
,`estado` enum('Bueno','Malo','Regular')
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_mas_vendidos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_mas_vendidos` (
`id_producto` int(11)
,`producto` varchar(100)
,`categoria` varchar(50)
,`total_vendido` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_proveedores_productos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_proveedores_productos` (
`id_proveedor` int(11)
,`proveedor` varchar(100)
,`id_producto` int(11)
,`producto` varchar(100)
,`categoria` varchar(50)
,`precio` decimal(10,2)
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ventas_por_cliente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ventas_por_cliente` (
`id_cliente` int(11)
,`nombre` varchar(100)
,`apellido` varchar(100)
,`total_ventas` bigint(21)
,`monto_total` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `reporte_ventas_mensuales`
--
DROP TABLE IF EXISTS `reporte_ventas_mensuales`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `reporte_ventas_mensuales`  AS SELECT year(`p`.`fecha_pedido`) AS `año`, month(`p`.`fecha_pedido`) AS `mes`, sum(`dp`.`cantidad` * `dp`.`precio_unitario`) AS `total_ventas` FROM (`pedidos` `p` join `detalles_pedido` `dp` on(`p`.`id_pedido` = `dp`.`id_pedido`)) WHERE `p`.`estado` = 'Completado' GROUP BY year(`p`.`fecha_pedido`), month(`p`.`fecha_pedido`) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_clientes_frecuentes`
--
DROP TABLE IF EXISTS `vista_clientes_frecuentes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_clientes_frecuentes`  AS SELECT `c`.`id_cliente` AS `id_cliente`, `c`.`nombre` AS `nombre`, `c`.`apellido` AS `apellido`, count(`v`.`id_venta`) AS `cantidad_compras` FROM (`clientes` `c` join `ventas` `v` on(`c`.`id_cliente` = `v`.`id_cliente`)) GROUP BY `c`.`id_cliente`, `c`.`nombre`, `c`.`apellido` HAVING `cantidad_compras` > 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_compras_recientes`
--
DROP TABLE IF EXISTS `vista_compras_recientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_compras_recientes`  AS SELECT `c`.`id_compra` AS `id_compra`, `c`.`fecha_compra` AS `fecha_compra`, `p`.`nombre` AS `proveedor`, `e`.`nombre` AS `empleado`, `c`.`total` AS `total` FROM ((`registro_compras` `c` join `proveedores` `p` on(`c`.`id_proveedor` = `p`.`id_proveedor`)) join `empleados` `e` on(`c`.`id_empleado` = `e`.`id_empleado`)) WHERE `c`.`fecha_compra` >= curdate() - interval 30 day ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_empleados_mayor_venta`
--
DROP TABLE IF EXISTS `vista_empleados_mayor_venta`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_empleados_mayor_venta`  AS SELECT `e`.`id_empleado` AS `id_empleado`, `e`.`nombre` AS `nombre`, `e`.`apellido` AS `apellido`, `e`.`cargo` AS `cargo`, count(`v`.`id_venta`) AS `cantidad_ventas`, sum(`v`.`total`) AS `total_vendido` FROM (`empleados` `e` left join `ventas` `v` on(`e`.`id_empleado` = `v`.`id_empleado`)) GROUP BY `e`.`id_empleado`, `e`.`nombre`, `e`.`apellido`, `e`.`cargo` ORDER BY sum(`v`.`total`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_pedidos_detalles`
--
DROP TABLE IF EXISTS `vista_pedidos_detalles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_pedidos_detalles`  AS SELECT `p`.`id_pedido` AS `id_pedido`, `p`.`fecha_pedido` AS `fecha_pedido`, `u`.`nombre` AS `cliente`, `pr`.`nombre` AS `producto`, `dp`.`cantidad` AS `cantidad`, `dp`.`precio_unitario` AS `precio_unitario` FROM (((`pedidos` `p` join `usuario` `u` on(`p`.`id_usuario` = `u`.`id_usuario`)) join `detalles_pedido` `dp` on(`p`.`id_pedido` = `dp`.`id_pedido`)) join `productos` `pr` on(`dp`.`id_producto` = `pr`.`id_producto`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_bajo_stock`
--
DROP TABLE IF EXISTS `vista_productos_bajo_stock`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_bajo_stock`  AS SELECT `productos`.`id_producto` AS `id_producto`, `productos`.`nombre` AS `nombre`, `productos`.`categoria` AS `categoria`, `productos`.`stock` AS `stock`, `productos`.`estado` AS `estado` FROM `productos` WHERE `productos`.`stock` <= 10 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_mas_vendidos`
--
DROP TABLE IF EXISTS `vista_productos_mas_vendidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_mas_vendidos`  AS SELECT `p`.`id_producto` AS `id_producto`, `p`.`nombre` AS `producto`, `p`.`categoria` AS `categoria`, sum(`dv`.`cantidad`) AS `total_vendido` FROM (`productos` `p` join `detalles_ventas` `dv` on(`p`.`id_producto` = `dv`.`id_producto`)) GROUP BY `p`.`id_producto`, `p`.`nombre`, `p`.`categoria` ORDER BY sum(`dv`.`cantidad`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_proveedores_productos`
--
DROP TABLE IF EXISTS `vista_proveedores_productos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_proveedores_productos`  AS SELECT `p`.`id_proveedor` AS `id_proveedor`, `p`.`nombre` AS `proveedor`, `pr`.`id_producto` AS `id_producto`, `pr`.`nombre` AS `producto`, `pr`.`categoria` AS `categoria`, `pr`.`precio` AS `precio`, `pr`.`stock` AS `stock` FROM (`proveedores` `p` join `productos` `pr` on(`p`.`id_proveedor` = `pr`.`id_proveedor`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ventas_por_cliente`
--
DROP TABLE IF EXISTS `vista_ventas_por_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ventas_por_cliente`  AS SELECT `c`.`id_cliente` AS `id_cliente`, `c`.`nombre` AS `nombre`, `c`.`apellido` AS `apellido`, count(`v`.`id_venta`) AS `total_ventas`, sum(`v`.`total`) AS `monto_total` FROM (`clientes` `c` left join `ventas` `v` on(`c`.`id_cliente` = `v`.`id_cliente`)) GROUP BY `c`.`id_cliente`, `c`.`nombre`, `c`.`apellido` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_stock`
--
ALTER TABLE `auditoria_stock`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- Indices de la tabla `detalles_compras`
--
ALTER TABLE `detalles_compras`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_compra` (`id_compra`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `detalles_pedido`
--
ALTER TABLE `detalles_pedido`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_pedido` (`id_pedido`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `detalles_ventas`
--
ALTER TABLE `detalles_ventas`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_venta` (`id_venta`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`);

--
-- Indices de la tabla `historial_cambios`
--
ALTER TABLE `historial_cambios`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `historial_stock`
--
ALTER TABLE `historial_stock`
  ADD PRIMARY KEY (`id`),
  ADD KEY `producto_id` (`producto_id`);

--
-- Indices de la tabla `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id_pedido`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `precio`
--
ALTER TABLE `precio`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `id_proveedor` (`id_proveedor`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- Indices de la tabla `registro_compras`
--
ALTER TABLE `registro_compras`
  ADD PRIMARY KEY (`id_compra`),
  ADD KEY `id_proveedor` (`id_proveedor`),
  ADD KEY `id_empleado` (`id_empleado`);

--
-- Indices de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD PRIMARY KEY (`id_permiso`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `id_empleado` (`id_empleado`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria_stock`
--
ALTER TABLE `auditoria_stock`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `detalles_compras`
--
ALTER TABLE `detalles_compras`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `detalles_pedido`
--
ALTER TABLE `detalles_pedido`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `detalles_ventas`
--
ALTER TABLE `detalles_ventas`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `historial_cambios`
--
ALTER TABLE `historial_cambios`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `historial_stock`
--
ALTER TABLE `historial_stock`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id_pedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `precio`
--
ALTER TABLE `precio`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `registro_compras`
--
ALTER TABLE `registro_compras`
  MODIFY `id_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria_stock`
--
ALTER TABLE `auditoria_stock`
  ADD CONSTRAINT `auditoria_stock_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `detalles_compras`
--
ALTER TABLE `detalles_compras`
  ADD CONSTRAINT `detalles_compras_ibfk_1` FOREIGN KEY (`id_compra`) REFERENCES `registro_compras` (`id_compra`),
  ADD CONSTRAINT `detalles_compras_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `detalles_pedido`
--
ALTER TABLE `detalles_pedido`
  ADD CONSTRAINT `detalles_pedido_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`),
  ADD CONSTRAINT `detalles_pedido_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `detalles_ventas`
--
ALTER TABLE `detalles_ventas`
  ADD CONSTRAINT `detalles_ventas_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`),
  ADD CONSTRAINT `detalles_ventas_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `historial_cambios`
--
ALTER TABLE `historial_cambios`
  ADD CONSTRAINT `historial_cambios_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE;

--
-- Filtros para la tabla `historial_precios`
--
ALTER TABLE `historial_precios`
  ADD CONSTRAINT `historial_precios_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `historial_stock`
--
ALTER TABLE `historial_stock`
  ADD CONSTRAINT `historial_stock_ibfk_1` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE;

--
-- Filtros para la tabla `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `precio`
--
ALTER TABLE `precio`
  ADD CONSTRAINT `precio_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE;

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`);

--
-- Filtros para la tabla `registro_compras`
--
ALTER TABLE `registro_compras`
  ADD CONSTRAINT `registro_compras_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`),
  ADD CONSTRAINT `registro_compras_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
