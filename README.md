# private notes in an public place 

Use git for your notes and back them up in an encrypted state in github.
Keeps encrypted and compressed files under filesizecap of 50mb.
Uses 7zip implementation of AES-256 encryption.

## Prerequisits  

Linux OS.
__apt__ as packagemanager.

Works with ubuntu 18.04 and 20.04

## How to use  

Fork this repo.  
If using this on github, i advice using a private repo.

Use a branch named __main__

Run:  
```sh
make
```

This installs dependencies, makes `pniap` executable, and shows help.

Open notes (default folder `./notes`):  
```sh
./pniap --open
cd notes
```

Do some notetaking inside of notes-directory.

Close notes (encrypt, compress, commit, push):  
```sh
./pniap --close
```

Custom notes folder:  
```sh
./pniap --open ./my_notes
./pniap --close ./my_notes
```

Selftest:  
```sh
./pniap --selftest
```

Non-interactive git init:  
```sh
PNIAP_YES=1 ./pniap --open
```

Enjoy :)  
