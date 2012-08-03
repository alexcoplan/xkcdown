# xkcdown

A downloader for [xkcd](http://xkcd.com).

## Quickstart (download all comics)

```
git clone git://github.com/alexcoplan/xkcdown.git
cd xkcdown
ruby xkcdown.rb
```

## Usage

```
ruby xkcdown.rb [id] [range] [options] [directory]
```

`range` must be in the format x-y where x and y are integers e.g. (2-34) and denotes the range of comic IDs to download.
`id` must be an integer, and denotes a single comic ID to download.

Options are denoted by a hyphen followed by a list of options, e.g. `-it` or `-i -t`.
 - The option `-i` tells xkcdown to name files using the ID of the comic (default).
 - The option `-t` tells xkcdown to name files using the name of the remote image.
 - Both options (`-it`) will name files in the format "id name".

Any argument that does not match any of these expected formats (range, id or option) will be assumed to be the directory name in which you wish to store the images, and xkcdown will attempt to create this directory if it does not exist. By default, the directory name is images.

All arguments are optional, the order of arguments does not matter, but if multiple arguments conflict with each other (e.g. range and ID arguments), the last argument should override the earlier conflicting arguments.

If no range or ID is provided, xkcdown will attempt to download all comics.