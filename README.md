# Microprocessor-and-Assembly-Language-Lab

--------------------------------
Installation Process
--------------------------------
1. Go to this website https://www.nasm.us/
2. Click on the latest version of nasm X.XX.XX in the stable section
3. Download nasm-X.XX.XX.tar.gz file and extract it. A directory should be created named nasm-X.XX.XX where X.XX.XX is the latest version.
4. Open terminal and type:

    cd nasm-X.XX.XX
    ./configure
    make
    sudo make install
   

5. Now check the version to verify installation:
   
    nasm --version
   


-----------------------------------
How to run code ?
-----------------------------------

1. Create an .asm file for your assembly code
2. Open terminal and type:
  
   Assemble : nasm -f elk64 filename.asm -o filename.o
   Link : gcc -no-pie -o filename filename.o
   Run : ./filename
   
