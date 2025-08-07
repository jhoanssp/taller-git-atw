<?php declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Article;
use App\Entities\Author;
use PDO;

class ArticleRepository implements RepositoryInterface {
    private PDO $db;
    private AuthorRepository $authorRepo;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->authorRepo = new AuthorRepository();
    }

    public function findAll(): array
    {
        $stmt = $this->db->query("CALL sp_article_list();");
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
        if (!$entity instanceof Article) {
            throw new \InvalidArgumentException("Article expected");
        }

        $stmt = $this->db->prepare("CALL sp_create_article(?, ?, ?, ?, ?, ?, ?, ?, ?, ?);");
        $stmt->bindValue(1, $entity->getTitle());
        $stmt->bindValue(2, $entity->getDescription());
        $stmt->bindValue(3, $entity->getPublicationDate()->format('Y-m-d'));
        $stmt->bindValue(4, $entity->getAuthor()->getId());
        $stmt->bindValue(5, $entity->getDoi());
        $stmt->bindValue(6, $entity->getAbstract());
        $stmt->bindValue(7, $entity->getKeywords());
        $stmt->bindValue(8, $entity->getIndexation());
        $stmt->bindValue(9, $entity->getMagazine());
        $stmt->bindValue(10, $entity->getArea());


        $result = $stmt->execute();
        $stmt->closeCursor();
        return $result;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_find_article(?);");
        $stmt->bindValue(1, $id);
        $stmt->execute();

        $row = $stmt->fetch();
        $stmt->closeCursor();

        if (!$row) {
            return null;
        }

        return $this->hydrate($row);
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Article) {
            throw new \InvalidArgumentException("Article expected");
        }

        $stmt = $this->db->prepare("CALL sp_update_article(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);");
        $stmt->bindValue(1, $entity->getId());
        $stmt->bindValue(2, $entity->getTitle());
        $stmt->bindValue(3, $entity->getDescription());
        $stmt->bindValue(4, $entity->getPublicationDate()->format('Y-m-d'));
        $stmt->bindValue(5, $entity->getAuthor()->getId());
        $stmt->bindValue(6, $entity->getDoi());
        $stmt->bindValue(7, $entity->getAbstract());
        $stmt->bindValue(8, $entity->getKeywords());
        $stmt->bindValue(9, $entity->getIndexation());
        $stmt->bindValue(10, $entity->getMagazine());
        $stmt->bindValue(11, $entity->getArea());

        $result = $stmt->execute();
        $stmt->closeCursor();
        return $result;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_delete_article(?);");
        $stmt->bindValue(1, $id);

        $result = $stmt->execute();
        $stmt->closeCursor();
        return $result;
    }

    public function hydrate(array $row): Article
    {
        $author = new Author(
            (int)$row['id'],
            $row['first_name'],
            $row['second_name'],
            $row['username'],
            $row['email'],
            'temporal', // Placeholder, será reemplazado por Reflection
            $row['orcid'],
           $row['affiliation']
        );

        if (isset($row['password'])) {
            $ref = new \ReflectionClass($author);
            $property = $ref->getProperty('password');
            $property->setAccessible(true);
            $property->setValue($author, $row['password']);
        }

        return new Article(
            (int)$row['publication_id'],
            $row['title'],
            $row['description'],
            new \DateTime($row['publication_date']),
            $author,
            $row['doi'],
            $row['abstract'],
            $row['keywords'],
            $row['indexation'],
            $row['magazine'],
            $row['area']
        );
    }
}
