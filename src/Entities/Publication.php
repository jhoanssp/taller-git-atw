<?php declare(strict_types=1);

namespace App\Entities;

abstract class Publication
{
    protected ?int $id;
    protected string $title;
    protected string $description;
    protected \DateTime $publication_date;
    protected Author $author;

    public function __construct(
        ?int $id,
        string $title,
        string $description,
        \DateTime $publication_date,
        Author $author
    ) {
        $this->id = $id;
        $this->title = $title;
        $this->description = $description;
        $this->publication_date = $publication_date;
        $this->author = $author;
    }

    public function getId(): ?int                       { return $this->id; }
    public function getTitle(): string                 { return $this->title; }
    public function getDescription(): string           { return $this->description; }
    public function getPublicationDate(): \DateTime    { return $this->publication_date; }
    public function getAuthor(): Author                { return $this->author; }

    public function setId(int $id): void                                     { $this->id = $id; }
    public function setTitle(string $title): void                            { $this->title = $title; }
    public function setDescription(string $description): void                { $this->description = $description; }
    public function setPublicationDate(\DateTime $publication_date): void    { $this->publication_date = $publication_date; }
    public function setAuthor(Author $author): void                          { $this->author = $author; }
}
