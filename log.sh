#! /bin/bash
#
# The MIT License
#
# Copyright (c) 2010 James Rodenkirch <james@rodenkirch.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.



TITLE="Git Log Report by Tag"


#------------------------------------------------>> prompt for parameters  <<---


START=$(whiptail \
    --title "${TITLE}" \
    --inputbox "Date Range (Start)\nYYYY-MM-DD" \
    10 40 2>&1 > /dev/tty)

if [ $? != 0 ]; then
    exit 0
fi


END=$(whiptail \
    --title "${TITLE}" \
    --inputbox "Date Range (End)\nYYYY-MM-DD" \
    10 40 2>&1 > /dev/tty)

if [ $? != 0 ]; then
    exit 0
fi


FILE=$(whiptail \
    --title "${TITLE}" \
    --inputbox "Output File" \
    10 40 2>&1 > /dev/tty)

if [ $? != 0 ]; then
    exit 0
fi


#------------------------------------------------------>> process commits  <<---


# get all hashes in the date range
hashes=($(git log --pretty=format:%h --after="$START" --before="$END"))

{
    counter=0
    total=${#hashes[@]}

    # loop all hashes
    for h in "${hashes[@]}"
    do
        hash=$h

        # find tag for this hash
        tags=($(git tag --contains $h))
        for t in "${tags[@]}"
            do tag=$t; break
        done

        # find message for this hash
        message=$(git log --pretty=format:"%h: %s" | grep "$hash")

        # save date for tag
        hashdate=($(git log --pretty=format:"%h %ad" --date=short | grep "$hash"))
        for d in "${hashdate[@]}"
            do date=$d
        done

        # write file header
        if [ ! -f $tag.gitlog ]
        then
            echo "" >> $tag.gitlog
            echo "" >> $tag.gitlog
            touch $tag.gitlog
            echo "$tag  ($date)" > $tag.gitlog
            echo "---" >> $tag.gitlog
        fi

        # write commit
        echo $message >> $tag.gitlog

        # output progress
        counter=$(($counter + 1))
        echo $(echo "100*$counter/$total" | bc)
    done
} | whiptail --title "${TITLE}" --gauge "Please wait" 5 40 0


#-------------------------------------------->> build report and clean up  <<---


rm $FILE
touch $FILE

FILES=*.gitlog
for f in $FILES
do
    cat $f >> $FILE
    echo >> $FILE
    echo >> $FILE
    echo >> $FILE
done

rm *.gitlog
