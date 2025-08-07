<?php declare(strict_types=1);

namespace App\Config;

use PDO;

class Database
{
    private static ?PDO $instance = null;

    public static function getConnection(): PDO
    {
        if(self::$instance === null)
        {
            $host     = 'localhost';
            $dbName   = 'atw';//project_db
            $username = 'root';
            $password = '';
            $charset  = 'utf8mb4';
            $port     = 3307;


            $dsn = "mysql:host={$host};port={$port};dbname={$dbName};charset={$charset}";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];

            self::$instance = new PDO($dsn, $username, $password, $options);
        }
        return self::$instance;
    }
}