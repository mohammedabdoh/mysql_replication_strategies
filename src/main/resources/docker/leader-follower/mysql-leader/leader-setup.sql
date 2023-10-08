CREATE USER 'repl'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'repl-password'; -- Adjust the password as needed.
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';