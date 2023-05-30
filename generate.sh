#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")"

if [ "$#" -ne 6 ]; then
    echo "Need exactly 6 arguments: name, matriculation number (optional; can be left empty), title, place, date, signature (path)"
fi

name="$1"
matriculation_number="$2"
title="$3"
place="$4"
date="$5"
signature="$6"

fields=(
  "Name VornameLast Name First Name"
  "Matrikelnummer freiwillige Angabe"
  "Titel"
  "Ort DatumCity Date"
  "Ort DatumCity Date_2"
)
values=(
  "$name"
  "$matriculation_number"
  "$title"
  "$place, $date"
  "$place, $date"
)
form="eidesstattliche-versicherung.pdf"

data="$(pdftk "$form" generate_fdf output -)"

# Replace the form values
for i in "${!fields[@]}"; do
  field="${fields[$i]}"
  value="${values[$i]}"
  data="$(echo "$data" | sed -z "s/\/T ($field)\n\/V ()/\/T ($field)\n\/V ($value)/")"
done

# Generate signature images
convert "$signature" "/tmp/signature.pdf"
# TODO: Figure out how to use signature of any size (currently roughly 1200x300 works)
pdfjam --paper "a4paper" --scale 0.2 --offset "2.5cm -0.5cm" --outfile "/tmp/stamp1.pdf" "/tmp/signature.pdf"
pdfjam --paper "a4paper" --scale 0.2 --offset "2.5cm -11.75cm" --outfile "/tmp/stamp2.pdf" "/tmp/signature.pdf"

# Insert signature images
cp "$form" "/tmp/form.pdf"
pdftk "/tmp/form.pdf" stamp "/tmp/stamp1.pdf" output "/tmp/form1.pdf"
pdftk "/tmp/form1.pdf" stamp "/tmp/stamp2.pdf" output "/tmp/form2.pdf"

# Fill out form
echo "$data" | pdftk "/tmp/form2.pdf" fill_form - output "Eidesstattliche_Versicherung_${title}_${name}.pdf" flatten
