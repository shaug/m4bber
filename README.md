# m4bber

The m4bber (pronounced 'mabber') container is an extension of the
[m4b-tool] for converting folders of audiofiles into m4b audiobooks ready for
tagging.

This repo is a fork of [auto-m4b] (which is in turn a fork of
[docker-m4b-tool]), with the goal of limiting the tool to *just* conversion
of incoming audio files to m4b files ready for tagging. It removes orthogonal
functionality (e.g., running as a daemon or sleeping between runs), which are
best handled by other tools (e.g., [cron], [automator]).

[m4b-tool]: https://github.com/sandreas/m4b-tool
[auto-m4b]: https://
[docker-m4b-tool]: https://github.com/9Mad-Max5/docker-m4b-tool
[cron]: https://en.wikipedia.org/wiki/Cron
[automator]: https://support.apple.com/guide/automator/welcome/mac

## Overview

This is a docker container that will scan a folder for books, auto convert any
mp3 audiobooks found to chapterized m4b, and move all m4b books to a specific
output folder. Thypically, this output folder is where the [beets.io audible
plugin] will look for audiobooks and use the Audible API to tag and organize
your books.

[beets.io audible plugin]: https://github.com/Neurrone/beets-audible

## Intended Use

When run, this tool will scan a specified folder for new audiobooks and will
automatically convert them to chapterized m4b audiobooks. Typically, this tool
will be configured as part of some system to be triggered automatically, either
via a cron job or through some filesystem trigger.

* Install via docker-compose 
* Save new audiobooks to the `/audiobooks/new` folder.
* All multifile m4b/mp3/m4a/ogg books will be converted to a chapterized m4b
  and saved to an `/output` folder  
* When run, this script will look for files in `/audiobooks/new` and
  automatically move mp3 books to `/audiobooks/merge`, then automatically put
  all m4b's in the output folder `/audiobooks/output`.  It also optionally
  makes a backup of the files first in case something goes wrong.

Use the [beets.io audible plugin] to finish the tagging and sorting.

## Known Limitations

* The chapters are based on the mp3 tracks. A single mp3 file will become a
  single m4b with 1 chapter, also if the mp3 filenames are garbarge then your
  m4b chapternames will be terrible as well.  See section on Chapters below
  for how to manually adjust.  
* The conversion process actually strips some tags and covers from the files,
  which is why you need to use a tagger (mp3tag or beets.io) before adding to
  Plex.

## Need ARM Support?

Change the image to `spencermksmith/m4bber`

## Using torrents and need to preserve seeding?

In the settings of your client add this line to `Run external program on
torrent completion`, it will copy all finished torrent files to your "new"
folder:

* `cp -r "%F" "path/to/audiobooks/new"`

## How to use
This docker assumes the following folder structure:

```sh
temp
│
└───new # Input folder Add new books here
│     │     book1.m4b
│     |     book2.mp3
|     └─────book3
│           │   01-book3.mp3
│           │   ... 
└───merge # folder the script uses to combine mp3's
│     └─────book2
│           │   01-book2.mp3
│           │   ...
└───output # Output folder where all m4b's wait to be tagged
│     └─────book4
│           │   book4.m4b
└───backup # Backups incase anything goes wrong
      └─────book2
            │   01-book2.mp3
            │   ... 
```

### Installation

1. Create a `temp` folder and keep the location in mind for Step 6 
2. [Install docker] 
3. [Manage docker as non-root] 
4. [Install docker-compose] 
5. Copy `docker-compose-example.yml` to `docker-compose.yml` and edit with the
   volume mount location, plus any other options you want to change.
6. Put a test mp3 in the `/audiobooks/new` directory.
7. Start the docker (It should convert the mp3 and leave it in your
   `/audiobooks/output` directory): `docker-compose run tool`


[Install docker]: https://docs.docker.com/engine/install/
[Manage docker as non-root]: https://docs.docker.com/engine/install/linux-postinstall/
[Install docker-compose]: https://docs.docker.com/compose/install/


### Example docker-compose.yml

* Replace the `/path/to/...` with your actual folder locations, but leave the
  `:` and everything after:  

#### docker-compose.yml

The m4bber tool can be customized with command-line arguments.


```yaml
services:
  m4bber:
    image: shaug/m4bber
    container_name: m4bber
    volumes:
      - /path/to/audiobooks:/audiobooks
    command:
      - --jobs
      - 2
      - --backup-dir
      - backup
      - --chapter-detection
```

Or it can customized with environment variables.

```yaml
services:
  m4bber:
    image: shaug/m4bber
    container_name: m4bber
    volumes:
      - /path/to/audiobooks:/audiobooks
    environment:
      - M4BBER_JOBS=2
      - M4BBER_BACKUP_DIR=backup
      - M4BBER_CHAPTER_DETECTION=true
```

Or a combination of both.

```yaml
services:
  m4bber:
    image: shaug/m4bber
    container_name: m4bber
    volumes:
      - /path/to/audiobooks:/audiobooks
    command:
      - --jobs
      - 2
      - --backup-dir
      - backup
    environment:
      - M4BBER_CHAPTERS=true
```

When using both, the command-line arguments will override the environment
variables.


## To Manually Set Chapters:

1. Put a folder with mp3's in the `/audiobooks/new` and let the script 
   process the book like normal
2. In the output folder ( `/audiobooks/output` ) there will be a book folder
   that includes the recently converted `*.m4b` and a `*.chapters.txt` file.
3. Open the chapters file and edit/add/rename, then save
4. Move the book folder (which contains the m4b and chapters.txt files) to 
   `/audiobooks/merge`
5. When the script runs it will re-chapterize the m4b and move it back to 
   `/audiobooks/output`

## Advanced Options

#### CPU Cores

The script will automatically use all CPU cores available, to change the
amount of cpu cores for the converting change the `--jobs` flag in the
`m4b-tool` command, but do not set it higher than the amount of cores
available.  

#### Backup Foldehttps://github.com/Neurrone/beets-audible

Files can be backed up to a folder in case something goes wrong. THis is also
useful when the original files are being

#### More Reading

More m4b-tool options https://github.com/sandreas/m4b-tool#reference
