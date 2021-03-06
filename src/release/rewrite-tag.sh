#!/bin/bash

set -u
cd "${project.basedir}"

echo "Reading current HEAD..."
OLD_HEAD="`git symbolic-ref HEAD 2>/dev/null`"
if [ $? -eq 0 ] ; then
    echo "Stored HEAD $OLD_HEAD."
else
    OLD_HEAD=''
    echo "Detected detached HEAD."
fi

set -e # No errors allowed from here to end

echo Reading settings from $1
declare -r SCM_TAG=`sed -rn 's|\\\\||g; s|^scm\.tag=||p' $1`
declare -r TAG_REF=refs/tags/"$SCM_TAG"
declare -r NEW_ANNOTATION="Faunus $SCM_TAG"
echo Read SCM_TAG: "$SCM_TAG"

echo Showing $TAG_REF '(before)'...
git show "$TAG_REF"

echo Checking out $TAG_REF...
git checkout "$TAG_REF"
echo Deleting tag $SCM_TAG...
git tag -d "$SCM_TAG"
echo "Creating unsigned tag \"$SCM_TAG\" with annotation \"$NEW_ANNOTATION\"..."
git tag "$SCM_TAG" -m "$NEW_ANNOTATION"

[ -n "$OLD_HEAD" ] && {
    echo "Returning to HEAD $OLD_HEAD...";
    git checkout "$OLD_HEAD";
}

echo Showing $TAG_REF '(after)'...
git show "$TAG_REF"
