#!/usr/bin/env bash

createSemVerTag() {
    VERSION=`git describe --abbrev=0 --tags`
    VERSION=`echo -e "${VERSION}" | sed -e 's/^v*//'`

    if [ $? -ne 0 ]; then
         VERSION=0.0.0
    fi
    #replace . with space so can split into an array
    VERSION_BITS=(${VERSION//./ })
    #get number parts and increase last one by 1
    VNUM1=${VERSION_BITS[0]-0}
    VNUM2=${VERSION_BITS[1]-0}
    VNUM3=${VERSION_BITS[2]-0}
    VNUM3=$((VNUM3+1))
    #create new tag
    NEW_TAG="$VNUM1.$VNUM2.$VNUM3"
    #echo "> Maybe from $VERSION to $NEW_TAG"
    #get current hash and see if it already has a tag
    GIT_COMMIT=`git rev-parse HEAD`
    NEEDS_TAG=`git describe --contains $GIT_COMMIT` || true
    # Need tags also if the current tag is not well formatted like 1 or 1.0
    # need x.x.x

    #only tag if no tag already (would be better if the git describe command above could have a silent option)
    if [ -z "$NEEDS_TAG" ]; then
        #echo "< yes, $NEW_TAG (Ignoring fatal:cannot describe - this means commit is untagged) "
        git tag $NEW_TAG > /dev/null
        git push --tags > /dev/null
        echo $NEW_TAG;
        VERSION=$NEW_TAG;
    else
        WELL_FORMATTED=`echo $NEEDS_TAG | grep ".\..\.."`
        RET=$?
        if [ $RET -eq 1 ]; then
            git tag $NEW_TAG > /dev/null
            git push --tags > /dev/null
            echo $NEW_TAG;
            VERSION=$NEW_TAG;
        else
            echo "$VERSION"
            return 1
        fi
    fi
}

git pull origin -t > /dev/null
createSemVerTag