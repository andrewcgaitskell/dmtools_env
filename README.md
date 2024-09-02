# dmtools_env

the api approach did not work

the github api does not retrieve the value, only the name of the secret

# encrypt the file?

## generate the key

    openssl rand -base64 32 > my_secret_key.key

## encrypt the file

    openssl enc -aes-256-cbc -salt -in mastersecrets.txt -out encrypted.txt.enc -pass file:./my_secret_key.key

## decrypt the file

    openssl enc -d -aes-256-cbc -in encrypted.txt.enc -out decrypted_mastersecrets.txt -pass file:./my_secret_key.key

