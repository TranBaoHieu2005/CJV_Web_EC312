<?php
// /app/config/Database.php

class Database {
    private $host = "localhost";
    private $db_name = "cjv_dev_hieu"; // TÊN DATABASE MÀ CÁC BẠN TỰ ĐẶT
    private $username = "root";       // THÔNG TIN USER CỦA XAMPP/WAMP
    private $password = "";           // THÔNG TIN PASSWORD CỦA XAMPP/WAMP
    public $conn;

    // Hàm kết nối Database
    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password);
            $this->conn->exec("set names utf8");
        } catch(PDOException $exception) {
            echo "Connection error: " . $exception->getMessage();
        }
        return $this->conn;
    }
}
?>