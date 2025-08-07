-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3307
-- Tiempo de generación: 07-08-2025 a las 17:29:28
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `atw`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_article_list` ()   BEGIN
    SELECT
        p.id AS publication_id,
        p.title,
        p.description,
        p.publication_date,
        p.author_id,
        a.DOI,
        a.abstract,
        a.keywords,
        a.indexation,
        a.magazine,
        a.aknowledge_are,
        a.DOI AS doi,
        a.abstract AS abstract,
        a.keywords AS keywords,
        a.indexation AS indexation,
        a.magazine AS magazine,
        a.aknowledge_are AS area,
        auth.id AS id,
        auth.first_name,
        auth.second_name,
        auth.username,
        auth.email,
        auth.password,
        auth.orcid,
        auth.affiliation
    FROM
        publication p
    JOIN
        article a ON p.id = a.publication_id
    JOIN
        author auth ON p.author_id = auth.id
    WHERE
        p.type = 'article';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_author_list` ()   BEGIN
    SELECT
        id,
        first_name,
        second_name,
        username,
        email,
        password,
        orcid,
        affiliation
    FROM
        author;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_book_list` ()   BEGIN
    SELECT
        p.id AS publication_id,
        p.title,
        p.description,
        p.publication_date,
        p.author_id,
        b.isbn,
        b.genre,
        b.edition,
        auth.id AS author_id_author,
        auth.first_name,
        auth.second_name,
        auth.username,
        auth.email,
        auth.password,
        auth.orcid,
        auth.affiliation
    FROM
        publication p
    JOIN
        book b ON p.id = b.publication_id
    JOIN
        author auth ON p.author_id = auth.id
    WHERE
        p.type = 'book';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_article` (IN `p_title` VARCHAR(100), IN `p_description` VARCHAR(100), IN `p_publication_date` DATE, IN `p_author_id` INT, IN `p_DOI` VARCHAR(20), IN `p_abstract` VARCHAR(300), IN `p_keywords` VARCHAR(50), IN `p_indexation` VARCHAR(20), IN `p_magazine` VARCHAR(50), IN `p_aknowledge_are` VARCHAR(100))   BEGIN
    DECLARE v_new_publication_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transacción al crear el artículo.';
    END;

    START TRANSACTION;

    INSERT INTO publication (
        title,
        description,
        publication_date,
        author_id,
        type
    ) VALUES (
        p_title,
        p_description,
        p_publication_date,
        p_author_id,
        'article'
    );

    SET v_new_publication_id = LAST_INSERT_ID();

    INSERT INTO article (
        publication_id,
        DOI,
        abstract,
        keywords,
        indexation,
        magazine,
        aknowledge_are
    ) VALUES (
        v_new_publication_id,
        p_DOI,
        p_abstract,
        p_keywords,
        p_indexation,
        p_magazine,
        p_aknowledge_are
    );

    COMMIT;

    SELECT v_new_publication_id AS new_article_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_author` (IN `p_first_name` VARCHAR(50), IN `p_second_name` VARCHAR(50), IN `p_username` VARCHAR(50), IN `p_email` VARCHAR(50), IN `p_password` VARCHAR(255), IN `p_orcid` VARCHAR(20), IN `p_affiliation` VARCHAR(100))   BEGIN
    INSERT INTO author (
        first_name,
        second_name,
        username,
        email,
        password,
        orcid,
        affiliation
    ) VALUES (
        p_first_name,
        p_second_name,
        p_username,
        p_email,
        p_password,
        p_orcid,
        p_affiliation
    );

    SELECT LAST_INSERT_ID() AS new_author_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_book` (IN `p_title` VARCHAR(100), IN `p_description` VARCHAR(100), IN `p_publication_date` DATE, IN `p_author_id` INT, IN `p_isbn` VARCHAR(20), IN `p_genre` VARCHAR(20), IN `p_edition` INT)   BEGIN
    DECLARE v_new_publication_id INT;

    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transacci�n al crear el libro.';
    END;

    START TRANSACTION;

    
    INSERT INTO publication (
        title,
        description,
        publication_date,
        author_id,
        type
    ) VALUES (
        p_title,
        p_description,
        p_publication_date,
        p_author_id,
        'book'
    );

    
    SET v_new_publication_id = LAST_INSERT_ID();

    
    
    
    
    
    INSERT INTO book (
        publication_id,
        isbn,
        genre,
        edition
    ) VALUES (
        v_new_publication_id, 
        p_isbn,
        p_genre,
        p_edition
    );

    
    COMMIT;

    
    SELECT v_new_publication_id AS new_book_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_article` (IN `p_id` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transacción al eliminar el artículo.';
    END;

    START TRANSACTION;

    DELETE FROM publication
    WHERE id = p_id AND type = 'article';

    COMMIT;

    SELECT 1 AS OK;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_author` (IN `p_id` INT)   BEGIN
    DELETE FROM author
    WHERE id = p_id;
    
    SELECT 1 AS OK;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_book` (IN `p_id` INT)   BEGIN
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transacci�n al eliminar el libro.';
    END;

    START TRANSACTION;

    
    
    DELETE FROM publication
    WHERE id = p_id AND type = 'book';

    COMMIT;

    
    SELECT 1 AS OK;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_article` (IN `p_publication_id` INT)   BEGIN
    SELECT
        p.id AS publication_id,
        p.title,
        p.description,
        p.publication_date,
        p.author_id,
        a.DOI AS doi,
        a.abstract AS abstract,
        a.keywords AS keywords,
        a.indexation AS indexation,
        a.magazine AS magazine,
        a.aknowledge_are AS area,
        auth.id AS id,
        auth.first_name,
        auth.second_name,
        auth.username,
        auth.email,
        auth.password,
        auth.orcid,
        auth.affiliation
    FROM
        publication p
    JOIN
        article a ON p.id = a.publication_id
    JOIN
        author auth ON p.author_id = auth.id
    WHERE
        p.id = p_publication_id AND p.type = 'article';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_author` (IN `p_id` INT)   BEGIN
    SELECT
        id,
        first_name,
        second_name,
        username,
        email,
        password,
        orcid,
        affiliation
    FROM
        author
    WHERE
        id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_book` (IN `p_publication_id` INT)   BEGIN
    SELECT
        p.id AS publication_id,
        p.title,
        p.description,
        p.publication_date,
        p.author_id,
        b.isbn,
        b.genre,
        b.edition,
        auth.id AS author_id_author,
        auth.first_name,
        auth.second_name,
        auth.username,
        auth.email,
        auth.password,
        auth.orcid,
        auth.affiliation
    FROM
        publication p
    JOIN
        book b ON p.id = b.publication_id
    JOIN
        author auth ON p.author_id = auth.id
    WHERE
        p.id = p_publication_id AND p.type = 'book';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_article` (IN `p_publication_id` INT, IN `p_title` VARCHAR(100), IN `p_description` VARCHAR(100), IN `p_publication_date` DATE, IN `p_author_id` INT, IN `p_DOI` VARCHAR(20), IN `p_abstract` VARCHAR(300), IN `p_keywords` VARCHAR(50), IN `p_indexation` VARCHAR(20), IN `p_magazine` VARCHAR(50), IN `p_aknowledge_are` VARCHAR(100))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transacción al actualizar el artículo.';
    END;

    START TRANSACTION;

    UPDATE publication
    SET
        title = p_title,
        description = p_description,
        publication_date = p_publication_date,
        author_id = p_author_id
    WHERE
        id = p_publication_id AND type = 'article';

    UPDATE article
    SET
        DOI = p_DOI,
        abstract = p_abstract,
        keywords = p_keywords,
        indexation = p_indexation,
        magazine = p_magazine,
        aknowledge_are = p_aknowledge_are
    WHERE
        publication_id = p_publication_id;

    COMMIT;

    SELECT 1 AS OK;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_author` (IN `p_id` INT, IN `p_first_name` VARCHAR(50), IN `p_second_name` VARCHAR(50), IN `p_username` VARCHAR(50), IN `p_email` VARCHAR(50), IN `p_password` VARCHAR(255), IN `p_orcid` VARCHAR(20), IN `p_affiliation` VARCHAR(100))   BEGIN
    UPDATE author
    SET
        first_name = p_first_name,
        second_name = p_second_name,
        username = p_username,
        email = p_email,
        password = p_password,
        orcid = p_orcid,
        affiliation = p_affiliation
    WHERE
        id = p_id;

    SELECT 1 AS OK;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_book` (IN `p_id` INT, IN `p_title` VARCHAR(255), IN `p_description` TEXT, IN `p_publication_date` DATE, IN `p_author_id` INT, IN `p_isbn` VARCHAR(13), IN `p_genre` VARCHAR(50), IN `p_edition` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transacción al actualizar el libro.';
    END;

    START TRANSACTION;

    UPDATE publication
    SET
        title = p_title,
        description = p_description,
        publication_date = p_publication_date,
        author_id = p_author_id
    WHERE
        id = p_id AND type = 'book';

    UPDATE book
    SET
        isbn = p_isbn,
        genre = p_genre,
        edition = p_edition
    WHERE
        publication_id = p_id;

    COMMIT;
    
    SELECT 1 AS OK;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_book_v2` (IN `p_id` INT, IN `p_title` VARCHAR(255), IN `p_description` TEXT, IN `p_publication_date` DATE, IN `p_author_id` INT, IN `p_isbn` VARCHAR(13), IN `p_genre` VARCHAR(50), IN `p_edition` INT)   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transacción al actualizar el libro.';
    END;

    START TRANSACTION;

    UPDATE publication
    SET
        title = p_title,
        description = p_description,
        publication_date = p_publication_date,
        author_id = p_author_id
    WHERE
        id = p_id AND type = 'book';

    UPDATE book
    SET
        isbn = p_isbn,
        genre = p_genre,
        edition = p_edition
    WHERE
        publication_id = p_id;

    COMMIT;
    
    SELECT 1 AS OK;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `article`
--

CREATE TABLE `article` (
  `publication_id` int(11) NOT NULL,
  `DOI` varchar(20) NOT NULL,
  `abstract` varchar(300) NOT NULL,
  `keywords` varchar(50) NOT NULL,
  `indexation` varchar(20) NOT NULL,
  `magazine` varchar(50) NOT NULL,
  `aknowledge_are` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `article`
--

INSERT INTO `article` (`publication_id`, `DOI`, `abstract`, `keywords`, `indexation`, `magazine`, `aknowledge_are`) VALUES
(4, '10.1039/J18987300057', 'Descubrimiento del polonio y radio.', 'Radiactividad, Polonio, Radio', 'Scopus', 'Le Radium', 'Física y Química'),
(5, '10.1112/plms/s2-42.1', 'Artículo sobre la máquina de Turing.', 'Máquina de Turing, Computabilidad', 'Web of Science', 'Proceedings of the London Mathematical Society', 'Matemáticas y Computación'),
(8, '10.1002/evl3.20165', 'Resumen de la teoría de la selección natural.', 'Evolución, Selección Natural', 'Scopus', 'Journal of Evolutionary Biology', 'Biología'),
(9, '10.1002/andp.1905322', 'Los principios de la relatividad y la física.', 'Relatividad, Espacio-Tiempo', 'arXiv', 'Annalen der Physik', 'Física'),
(10, '10.1016/j.jvb.2008.1', 'Revisión sobre las leyes de Asimov.', 'Robótica, Leyes de Asimov', 'IEEE Xplore', 'IEEE Transactions on Robotics', 'Robótica e IA'),
(12, '10.1007/s00442-019-0', 'Se exploran las principales causas y consecuencias del calentamiento global...', 'cambio climático, ecología, medio ambiente', 'Scopus', 'Journal of Environmental Science', 'Ciencias Ambientales'),
(15, '10.1234/abc.123', 'Resumen del contenido del artículo.', 'ciencia, tecnología, investigación', 'Scopus', 'Nueva Revista Científica', 'Física'),
(19, '10.1234/5678', 'Se analizan los últimos avances en IA y sus aplicaciones en la industria.', 'inteligencia artificial, machine learning, tecnolo', 'Scopus', 'Journal of AI Research', 'Ciencias de la Computación');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `author`
--

CREATE TABLE `author` (
  `id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `second_name` varchar(100) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `orcid` varchar(20) NOT NULL,
  `affiliation` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `author`
--

INSERT INTO `author` (`id`, `first_name`, `second_name`, `username`, `email`, `password`, `orcid`, `affiliation`) VALUES
(1, 'Dmitry', 'Glukhovsky', 'dima_g', 'Dmitry.Glukhovsky@example.com', 'pass123', '0000-0002-1825-0097', 'University URSS'),
(2, 'Jane', 'Austen', 'janeausten', 'jane.austen@gmail.com', 'aust3n', '0000-0002-1647-4952', 'Sociedad Británica de Literatura'),
(3, 'Isaac', 'Asimov', 'iasimov', 'isaac.asimov@gmail.com', 'robotics', '0000-0003-4567-8901', 'Universidad de Columbia'),
(4, 'Marie', 'Curie', 'marie_c', 'marie.curie@gmail.com', 'polonium', '0000-0004-9876-5432', 'Instituto del Radio de París'),
(5, 'Alan', 'Turing', 'turing_a', 'alan.turing@gmail.com', 'enigma', '0000-0005-1357-2468', 'Universidad de Cambridge'),
(7, 'John', 'Doe', 'johndoe', 'john.doe@example.com', 'password123', '0000-0001-2345-6789', 'Universidad de Prueba');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `book`
--

CREATE TABLE `book` (
  `publication_id` int(11) NOT NULL,
  `isbn` varchar(20) NOT NULL,
  `genre` varchar(20) NOT NULL,
  `edition` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `book`
--

INSERT INTO `book` (`publication_id`, `isbn`, `genre`, `edition`) VALUES
(1, '978-3-16-1484', 'Ficción de Ciencia F', 2),
(2, '978-84-204-66', 'Ficción de Ciencia F', 1),
(3, '978-84-450-71', 'Ficción y aventura', 2),
(20, '978-81-450-71', 'Manual', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `publication`
--

CREATE TABLE `publication` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `publication_date` date NOT NULL,
  `author_id` int(11) NOT NULL,
  `type` enum('book','article') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `publication`
--

INSERT INTO `publication` (`id`, `title`, `description`, `publication_date`, `author_id`, `type`) VALUES
(1, 'Metro 2033', 'Una serie de libros de horror espacial', '2015-08-07', 1, 'book'),
(2, 'amar y vivir', 'Una serie de amar', '2015-08-07', 2, 'book'),
(3, 'japon un nuevo mundo', 'Una historieta del nuevo japon', '2010-08-07', 3, 'book'),
(4, 'Investigación sobre el radio', 'Estudio sobre la radiactividad y sus efectos.', '1898-07-18', 4, 'article'),
(5, 'Sobre números computables', 'Artículo que sentó las bases de la computación moderna.', '1936-05-28', 5, 'article'),
(8, 'El origen de las especies', 'Un artículo resumido de la obra de Darwin.', '1859-11-24', 2, 'article'),
(9, 'Teoría de la relatividad', 'Artículo sobre la relatividad especial.', '1905-06-30', 5, 'article'),
(10, 'Leyes de la robótica', 'Análisis de las tres leyes de la robótica.', '1942-03-01', 3, 'article'),
(12, 'Un Análisis sobre el Impacto del Cambio Climático', 'Estudio detallado sobre los efectos del cambio climático en los ecosistemas costeros.', '2024-08-06', 2, 'article'),
(15, 'Título Actualizado del Artículo', 'Descripción del nuevo artículo...', '2025-08-06', 5, 'article'),
(19, 'Un nuevo artículo sobre IA2', 'Una investigación detallada sobre el impacto de la inteligencia artificial.', '2025-08-08', 2, 'article'),
(20, 'router y swithing actualizado', 'Manual tecnico MPLS', '2010-08-07', 2, 'book');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `article`
--
ALTER TABLE `article`
  ADD PRIMARY KEY (`publication_id`);

--
-- Indices de la tabla `author`
--
ALTER TABLE `author`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `book`
--
ALTER TABLE `book`
  ADD PRIMARY KEY (`publication_id`);

--
-- Indices de la tabla `publication`
--
ALTER TABLE `publication`
  ADD PRIMARY KEY (`id`),
  ADD KEY `author_id` (`author_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `author`
--
ALTER TABLE `author`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `publication`
--
ALTER TABLE `publication`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `article`
--
ALTER TABLE `article`
  ADD CONSTRAINT `article_ibfk_1` FOREIGN KEY (`publication_id`) REFERENCES `publication` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `book`
--
ALTER TABLE `book`
  ADD CONSTRAINT `book_ibfk_1` FOREIGN KEY (`publication_id`) REFERENCES `publication` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `publication`
--
ALTER TABLE `publication`
  ADD CONSTRAINT `publication_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `author` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
