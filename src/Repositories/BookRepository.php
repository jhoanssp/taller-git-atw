<?php  declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Book;
use App\Entities\Author;
use PDO;

class BookRepository implements RepositoryInterface{
    private PDO $db;
    private AuthorRepository $authorRepo;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->authorRepo = new AuthorRepository();
    }

    public function findAll():array 
    {
        $stmt = $this->db->query("CALL sp_book_list();");
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $out = [];
        foreach ($rows as $r) {
            $out[] = $this->hydrate($r);
        }

        return $out;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Book) 
        {
            throw new \InvalidArgumentException("Book expected");
        }

        $stmt = $this->db->prepare("CALL sp_create_book(:t, :d, :dt, :aid, :i, :g, :ed);");
        $ok = $stmt->execute(
            [
                ':t'   => $entity->getTitle(),
                ':d'   => $entity->getDescription(),
                ':dt'  => $entity->getPublicationDate()->format('Y-m-d'),
                ':aid' => $entity->getAuthor()->getId(),
                ':i'   => $entity->getIsbn(),
                ':g'   => $entity->getGenre(),
                ':ed'  => $entity->getEdition()
            ]
        );
        if ($ok){
            $stmt -> fetch();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_find_book(:id);");
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
        
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Book) 
        {
            throw new \InvalidArgumentException("Book expected");
        }

        $stmt = $this->db->prepare("CALL sp_update_book(:p_id, :t, :d, :dt, :aid, :i, :g, :ed);");
        $ok = $stmt->execute(
            [
                ':p_id'   => $entity->getId(),
                ':t'      => $entity->getTitle(),
                ':d'      => $entity->getDescription(),
                ':dt'     => $entity->getPublicationDate()->format('Y-m-d'),
                ':aid'    => $entity->getAuthor()->getId(),
                ':i'      => $entity->getIsbn(),
                ':g'      => $entity->getGenre(),
                ':ed'     => $entity->getEdition()
            ]
        );

        if ($ok){
            $stmt -> fetch();
        }
        $stmt->closeCursor();
        return $ok;
    
    }

    public function delete(int $id): bool
    {   
        $stmt = $this->db->prepare("CALL sp_delete_book(:id);");
        $ok = $stmt->execute([':id' => $id]);

        if ($ok){
            $stmt -> fetch();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function hydrate(array $row): Book
    {
        $author = new Author(
            (int) ($row['id'] ?? 0),
            $row['first_name'] ?? '',
            $row['second_name'] ?? '',
            $row['username'] ?? '',
            $row['email'] ?? '',
            'temporal',
            $row['orcid'] ?? '',
            $row['affiliation'] ?? ''
        );

        // Reemplazar hash sin regenerar solo si existe password
        if (isset($row['password'])) {
            $ref = new \ReflectionClass($author);
            $property = $ref->getProperty('password');
            $property->setAccessible(true);
            $property->setValue($author, $row['password']);
        }
        
        $publicationId = isset($row['publication_id']) ? (int) $row['publication_id'] : 0;

        return new Book(
            $publicationId,
            $row['title'] ?? '',
            $row['description'] ?? '',
            new \DateTime($row['publication_date'] ?? 'now'),
            $author,
            $row['isbn'] ?? '',
            $row['genre'] ?? '',
            (int) ($row['edition'] ?? 0)
        );
    }
}
