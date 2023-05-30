# RWTH eidesstattliche Versicherung

A script to automatically fill out an eidesstattliche Versicherung from the RWTH University.

I was annoyed by having to fill out this form manually every time.  
The effort of creating this script is _definitely_ justified.

## Usage

```bash
./generate.sh \
  "Your name" \
  "Your matriculation number (optional; can be left empty)" \
  "Title of the work" \
  "Place of signing" \
  "Date of signing" \
  "Path to signature image file"
```

## Current limitations

- `pdftk` doesn't seem to support UTF-8 so characters like Umlaute will look ugly.
- The signature image file currently needs to have a resolution of 1200x300. Other sizes might work too, but will be at the wrong size and location in the output PDF
