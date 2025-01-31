# nanog93-hackathon
scenarios and challenges associated with the NANOG92 hackathon 


## network-XX configuration

- clone the repo into the target AMI
- assumes that the base of the repository is placed within `/opt/clab` symlink
  or place accordingly.
- delete the following diretories
    - `network-01-baseline`
    - `network-02-baseline`

```bash
rm -rf network-01-baseline
rm -rf network-02-baseline
rm -rf .git  # removes the git repo references
# rm README.md - if we want to be really clean.
```
## required images

```bash
% docker images
REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
nanog92-ubuntu   latest    14e7a19ef223   2 days ago      220MB
ceos             4.32.2F   351f077b2dd5   4 weeks ago     2.45GB
ceos             latest    351f077b2dd5   4 weeks ago     2.45GB << this matches the image referenced in the containerlab topology files
hello-world      latest    d2c94e258dcb   17 months ago   13.3kB
```

the following builds and installs the `nanog93-ubuntu` image.

```bash
make build-dockerfile
```
