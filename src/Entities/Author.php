<?php declare(strict_types=1);

namespace App\Entities;

class Author
{
    private ?int $id;
    private string $first_name;
    private string $second_name;
    private string $username;
    private string $email;
    private string $password;
    private string $orcid;
    private string $affiliation;

    public function __construct(
        ?int $id,
        string $first_name,
        string $second_name,
        string $username,
        string $email,
        string $password,
        string $orcid,
        string $affiliation
    ) {
        $this->id          = $id;
        $this->first_name  = $first_name;
        $this->second_name   = $second_name;
        $this->username    = $username;
        $this->email       = $email;
        $this->password    = $password;
        $this->orcid       = $orcid;
        $this->affiliation = $affiliation;
    }

    // Getters
    public function getId(): int                     { return $this->id; }
    public function getFirstName(): string           { return $this->first_name; }
    public function getSecondName(): string            { return $this->second_name; }
    public function getUsername(): string            { return $this->username; }
    public function getEmail(): string               { return $this->email; }
    public function getPassword(): string            { return $this->password; }
    public function getOrcid(): string               { return $this->orcid; }
    public function getAffiliation(): string         { return $this->affiliation; }

    // Setters
    public function setId(int $id): void                         { $this->id = $id; }
    public function setFirstName(string $first_name): void       { $this->first_name = $first_name; }
    public function setSecondName(string $last_name): void         { $this->second_name = $second_name; }
    public function setUsername(string $username): void          { $this->username = $username; }
    public function setEmail(string $email): void                { $this->email = $email; }
    public function setPassword(string $password): void          { $this->password = password_hash($password, PASSWORD_BCRYPT); }
    public function setOrcid(string $orcid): void                { $this->orcid = $orcid; }
    public function setAffiliation(string $affiliation): void    { $this->affiliation = $affiliation; }
}
