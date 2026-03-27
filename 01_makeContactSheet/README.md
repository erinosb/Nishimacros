# makeContactSheet

## INSTALL

  * Download the repository with git clone
  * To make contact sheets, first execute `makeProjectionsForContactSheet.ijm` in FIJI and then, after, execute `makeContactSheet` on the command line

Using makeProjectionsForContactSheet.ijm:

  * To use `makeProjectionsForContactSheet.ijm`, open FIJI. Select **Plugins** -> **Macros** -> **Edit...**
  * Navigate to the makeProjectionsForContactSheet.ijm and Open
  * Read instructions to modify the code and push **Run**

Installing makeContactSheet.sh 

  * To allow you to use makeContactSheet anywhere in your file structure, add this folder (~/01_makeContactSheet) to your path
  * `makeContactSheet` requires ImageMagick, Ghostscript, and the desired font-path
  * Install ImageMagick and Ghostscript using one of these methods:

### Option #1: Install ImageMagick and GhostScript on MacOS using homebrew

Please execute these commands in  your Mac Terminal:

```
$ brew install imagemagick
$ brew install ghostscript
```

### Option #2: ImageMagick Ghostscript on MacOS using anaconda

Please execute these commands in  your Mac Terminal:

```
$ conda install imagemagick
$ conda install conda-forge::ghostscript
```

### Test installations and get versions

```
$ magick -version
$ gs -v
```

### Modify the makeContactSheet file by adding your desired font path.

To find your path on macOS: Check /Library/Fonts/, /System/Library/Fonts/, or ~/Library/Fonts/. Replace the string with your own desired font. 

## DEMO
