# private notes in an public place 

Use git for your notes and back them up in an encrypted state.

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
./openNotes.sh
cd notes
```  

This should install needed dependencies and create needed folders.


Do some notetaking inside of notes-directory.

When finished with notetaking:  

```sh
./closeNotes.sh
```

This encrypts, compresses the files and uploads them to your git origin.  

Enjoy :)  

