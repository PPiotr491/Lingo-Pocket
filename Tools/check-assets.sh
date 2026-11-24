#!/usr/bin/env bash
# Checks the asset catalog layout and image references. Run from anywhere.
cd "$(dirname "$0")/.." || exit 1
CAT=Lingo/Assets.xcassets
fail=0
bad() { echo "FAIL: $*"; fail=1; }

EXPECTED="Icons/icon-flame Onboarding/onboarding-hero Categories/category-food Categories/category-travel
Categories/category-animals Categories/category-home Lessons/lesson-breakfast Lessons/lesson-cafe
Lessons/lesson-market Lessons/lesson-restaurant Lessons/lesson-groceries Words/word-apple
Video/video-cafe-poster Quiz/quiz-cheese Quiz/quiz-bread Quiz/quiz-banana Quiz/quiz-tomato
Profile/profile-avatar Badges/badge-streak Badges/badge-words Badges/badge-quiz"

# 1. expected imagesets exist with an image file listed in Contents.json
for e in $EXPECTED; do
  dir="$CAT/$e.imageset"
  if [ ! -f "$dir/Contents.json" ]; then bad "missing imageset $e"; continue; fi
  files=$(grep -o '"filename" *: *"[^"]*"' "$dir/Contents.json" | sed 's/.*: *"\(.*\)"/\1/')
  [ -n "$files" ] || { bad "$e: no filename in Contents.json"; continue; }
  for f in $files; do [ -f "$dir/$f" ] || bad "$e: listed file $f not found"; done
done

# 2. every referenced image name has an imageset somewhere
names=$( { grep -o '"imageName" *: *"[^"]*"' Lingo/DataModel/data.json
           grep -rhoE 'Image\("[^"]*"\)|imageName: *"[^"]*"' Lingo --include=*.swift; } \
         | sed -E 's/.*"([^"]*)".*/\1/' | sort -u)
for n in $names; do
  [ -n "$(find "$CAT" -type d -name "$n.imageset")" ] || bad "no imageset for referenced name '$n'"
done

# 3. no legacy sets, no namespaces
for old in $(find "$CAT" -type d \( -name 'img-*.imageset' -o -name 'StreakImg.imageset' \)); do bad "legacy imageset $old"; done
for c in $(find "$CAT" -name Contents.json); do
  grep -q provides-namespace "$c" && bad "provides-namespace in $c"
done

[ $fail -eq 0 ] && echo "ALL PASSED"
exit $fail
