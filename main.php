<?php require_once __DIR__ . '/vendor/autoload.php';

use App\Repositories\BookRepository;
use App\Entites\Book;

// Instanciar repositorio
$bookRepo = new BookRepository();

function menu(): void {
    echo "\n== MENÚ DE GESTIÓN DE LIBROS ==\n";
    echo "1. Crear libro\n";
    echo "2. Listar libros\n";
    echo "3. Buscar libro por ID\n";
    echo "4. Actualizar libro\n";
    echo "5. Eliminar libro\n";
    echo "0. Salir\n";
    echo "Seleccione una opción: ";
}

function leerEntrada(string $mensaje): string {
    echo $mensaje;
    return trim(fgets(STDIN));
}

do {
    menu();
    $opcion = trim(fgets(STDIN));

    switch ($opcion) {
        case '1':
            echo "\n== Crear Libro ==\n";
            $titulo = leerEntrada("Título: ");
            $descripcion = leerEntrada("Descripción: ");
            $isbn = leerEntrada("ISBN: ");
            $genero = leerEntrada("Género: ");
            $edicion = (int) leerEntrada("Edición: ");
            $idAutor = (int) leerEntrada("ID del Autor: ");

            $author = $bookRepo->findById($idAutor)?->getAuthor();
            if (!$author) {
                echo "Autor no encontrado.\n";
                break;
            }

            $nuevoLibro = new Book(
                0,
                $titulo,
                $descripcion,
                new DateTime(),
                $author,
                $isbn,
                $genero,
                $edicion
            );

            if ($bookRepo->create($nuevoLibro)) {
                echo "Libro creado correctamente.\n";
            } else {
                echo "Error al crear el libro.\n";
            }
            break;

        case '2':
            echo "\n== Listar Libros ==\n";
            $libros = $bookRepo->findAll();
            foreach ($libros as $libro) {
                echo "- ID: " . $libro->getId() . PHP_EOL;
                echo "  Título: " . $libro->getTitle() . PHP_EOL;
                echo "  Autor: " . $libro->getAuthor()->getFirstName() . " " . $libro->getAuthor()->getLastName() . PHP_EOL;
                echo "  ISBN: " . $libro->getIsbn() . PHP_EOL;
                echo "  Género: " . $libro->getGenre() . PHP_EOL;
                echo "  Edición: " . $libro->getEdition() . PHP_EOL;
                echo PHP_EOL;
            }
            break;

        case '3':
            echo "\n== Buscar Libro por ID ==\n";
            $idBuscar = (int) leerEntrada("Ingrese el ID del libro: ");
            $libro = $bookRepo->findById($idBuscar);
            if ($libro) {
                echo "Libro encontrado:\n";
                echo "Título: " . $libro->getTitle() . PHP_EOL;
                echo "Autor: " . $libro->getAuthor()->getFirstName() . " " . $libro->getAuthor()->getLastName() . PHP_EOL;
                echo "ISBN: " . $libro->getIsbn() . PHP_EOL;
                echo "Género: " . $libro->getGenre() . PHP_EOL;
                echo "Edición: " . $libro->getEdition() . PHP_EOL;
            } else {
                echo "Libro no encontrado.\n";
            }
            break;

        case '4':
            echo "\n== Actualizar Libro ==\n";
            $idUpdate = (int) leerEntrada("ID del libro a actualizar: ");
            $libro = $bookRepo->findById($idUpdate);

            if (!$libro) {
                echo "Libro no encontrado.\n";
                break;
            }

            $titulo = leerEntrada("Nuevo título [{$libro->getTitle()}]: ") ?: $libro->getTitle();
            $descripcion = leerEntrada("Nueva descripción [{$libro->getDescription()}]: ") ?: $libro->getDescription();
            $isbn = leerEntrada("Nuevo ISBN [{$libro->getIsbn()}]: ") ?: $libro->getIsbn();
            $genero = leerEntrada("Nuevo género [{$libro->getGenre()}]: ") ?: $libro->getGenre();
            $edicion = leerEntrada("Nueva edición [{$libro->getEdition()}]: ") ?: $libro->getEdition();

            $libro->setTitle($titulo);
            $libro->setDescription($descripcion);
            $libro->setIsbn($isbn);
            $libro->setGenre($genero);
            $libro->setEdition((int)$edicion);

            if ($bookRepo->update($libro)) {
                echo "Libro actualizado correctamente.\n";
            } else {
                echo "Error al actualizar libro.\n";
            }
            break;

        case '5':
            echo "\n== Eliminar Libro ==\n";
            $idEliminar = (int) leerEntrada("ID del libro a eliminar: ");
            if ($bookRepo->delete($idEliminar)) {
                echo "Libro eliminado correctamente.\n";
            } else {
                echo "No se pudo eliminar el libro.\n";
            }
            break;

        case '0':
            echo "Saliendo del sistema...\n";
            break;

        default:
            echo "Opción inválida.\n";
            break;
    }
} while ($opcion !== '0');
