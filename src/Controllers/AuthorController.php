<?php declare(strict_types=1);

namespace App\Controllers;

use App\Entities\Author;
use App\Repositories\AuthorRepository;
use Exception;

class AuthorController
{
    private AuthorRepository $authorRepository;

    public function __construct()
    {
        $this->authorRepository = new AuthorRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json');
        $method = $_SERVER['REQUEST_METHOD'];

        if ($method === 'GET') {
            if (isset($_GET['id'])) {
                $author = $this->authorRepository->findById((int)$_GET['id']);
                echo json_encode($author ? $this->authorToArray($author) : null);
                return;
            } else {
                $list = array_map(
                    [$this, 'authorToArray'],
                    $this->authorRepository->findAll()
                );
                echo json_encode($list);
            }
            return;
        }

        $payload = json_decode(file_get_contents('php://input'), true);
        
        if ($method === 'POST') {
            try {
                $author = new Author(
                    null,
                    $payload['firstName'],
                    $payload['secondName'],
                    $payload['username'],
                    $payload['email'],
                    $payload['password'],
                    $payload['orcid'],
                    $payload['affiliation']
                );
                echo json_encode(['success' => $this->authorRepository->create($author)]);
            } catch (Exception $e) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid data provided: ' . $e->getMessage()]);
            }
            return;
        }

        if ($method === 'PUT') {
            $id = (int)($payload['id'] ?? 0);
            $existing = $this->authorRepository->findById($id);

            if (!$existing) {
                http_response_code(404);
                echo json_encode(['error' => 'Author not found']);
                return;
            }

            if (isset($payload['firstName'])) $existing->setFirstName($payload['firstName']);
            if (isset($payload['secondName'])) $existing->setSecondName($payload['secondName']);
            if (isset($payload['username'])) $existing->setUsername($payload['username']);
            if (isset($payload['email'])) $existing->setEmail($payload['email']);
            if (isset($payload['password'])) $existing->setPassword($payload['password']);
            if (isset($payload['orcid'])) $existing->setOrcid($payload['orcid']);
            if (isset($payload['affiliation'])) $existing->setAffiliation($payload['affiliation']); // Nombre corregido

            echo json_encode(['success' => $this->authorRepository->update($existing)]);
            return;
        }

        if ($method === 'DELETE') {
            $id = (int)($payload['id'] ?? 0);
            if ($id === 0) {
                http_response_code(400);
                echo json_encode(['error' => 'ID not provided']);
                return;
            }
            echo json_encode(['success' => $this->authorRepository->delete($id)]);
            return;
        }

        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
    }

    public function authorToArray(Author $author): array
    {
        return [
            'id' => $author->getId(),
            'firstName' => $author->getFirstName(),
            'secondName' => $author->getSecondName(),
            'username' => $author->getUsername(),
            'email' => $author->getEmail(),
            'password' => $author->getPassword(),
            'orcid' => $author->getOrcid(),
            'affiliation' => $author->getAffiliation() // Nombre del método corregido
        ];
    }
}