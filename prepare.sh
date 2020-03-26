#!/bin/bash

fsizes=(4 8 12 44 44 56 280 284 308 464 2116 3944 36156)
numdirs=20


last=$(git branch -l --format='%(refname:short)' | grep '^branch[0-9]*$' | tail -n1 | sed 's/^branch//')
branch="branch$(($last+1))"

git checkout -b "$branch"

mkdir 1
for i in ${!fsizes[*]}; do
    dd if=/dev/urandom of=1/$i bs=1k count=${fsizes[$i]}
done

for (( dir=2; dir <= $numdirs; dir++ )); do
    mkdir $dir
    cp 1/* $dir/
done

git add `seq 1 $numdirs`
git commit -m "add binary files"

git push --set-upstream origin "$branch"

git checkout -b "${branch}-link"

mkdir files

cp 1/* files/

git add files

for i in `seq 1 $numdirs`; do rm $i/*; done

for (( dir=1; dir<=$numdirs; dir++ )); do
    for i in ${!fsizes[*]}; do
        ln -s files/$i $dir/$i
    done
done

git commit -m "replace files with symlinks" -a

git push --set-upstream origin "${branch}-link"

git checkout master

